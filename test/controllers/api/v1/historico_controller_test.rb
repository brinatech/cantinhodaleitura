require "test_helper"

class Api::V1::HistoricoControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ana = Usuario.create!(nome: "Ana", email: "ana-historico@example.com", password: "password123")
    @beto = Usuario.create!(nome: "Beto", email: "beto-historico@example.com", password: "password123")
    @livro = livros(:one)
  end

  test "visitante não tem histórico e recebe 401" do
    get api_v1_historico_index_url
    assert_response :unauthorized

    put api_v1_historico_url(@livro.id), params: { pagina: 1, total_paginas: 10 }, as: :json
    assert_response :unauthorized
  end

  test "lista só o meu histórico, do lido mais recentemente para o mais antigo, com a página do marcador" do
    outro_livro = livros(:two)
    HistoricoLeitura.create!(usuario: @ana, livro: @livro, data_inicio: 3.days.ago, data_ultima_leitura: 3.days.ago, progresso_percentual: 40)
    HistoricoLeitura.create!(usuario: @ana, livro: outro_livro, data_inicio: 1.day.ago, data_ultima_leitura: 1.day.ago, progresso_percentual: 10)
    HistoricoLeitura.create!(usuario: @beto, livro: @livro, data_inicio: Time.current, data_ultima_leitura: Time.current) # de outra pessoa
    MarcadorPagina.create!(usuario: @ana, livro: @livro, pagina_atual: 11)
    entrar_com(@ana)

    get api_v1_historico_index_url

    assert_response :success
    resposta = JSON.parse(response.body)
    assert_equal [ outro_livro.id, @livro.id ], resposta.map { |item| item["livro_id"] }
    assert_nil resposta.first["pagina_atual"] # sem marcador neste livro
    assert_equal 11, resposta.last["pagina_atual"]
    assert_in_delta 40.0, resposta.last["progresso_percentual"], 0.001
    assert_equal @livro.titulo, resposta.last.dig("livro", "titulo")
    assert_equal @livro.categoria.nome, resposta.last.dig("livro", "categoria", "nome")
  end

  test "sem leituras, a lista vem vazia" do
    entrar_com(@ana)

    get api_v1_historico_index_url

    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end

  test "registra a leitura com o progresso" do
    entrar_com(@ana)

    assert_difference "@ana.historico_leituras.count", 1 do
      put api_v1_historico_url(@livro.id), params: { pagina: 11, total_paginas: 28 }, as: :json
    end

    assert_response :success
    resposta = JSON.parse(response.body)
    assert_equal @livro.id, resposta["livro_id"]
    assert_in_delta 39.29, resposta["progresso_percentual"], 0.001
    assert_not_nil resposta["data_inicio"]
    assert_not_nil resposta["data_ultima_leitura"]
  end

  test "ler de novo atualiza o mesmo registro" do
    entrar_com(@ana)
    put api_v1_historico_url(@livro.id), params: { pagina: 2, total_paginas: 10 }, as: :json

    assert_no_difference "HistoricoLeitura.count" do
      put api_v1_historico_url(@livro.id), params: { pagina: 6, total_paginas: 10 }, as: :json
    end

    assert_response :success
    assert_in_delta 60.0, JSON.parse(response.body)["progresso_percentual"], 0.001
  end

  test "sem página, só marca que abriu o livro" do
    entrar_com(@ana)

    put api_v1_historico_url(@livro.id), as: :json

    assert_response :success
    assert_in_delta 0.0, JSON.parse(response.body)["progresso_percentual"], 0.001
  end

  test "ignora usuario_id mandado pelo navegador" do
    entrar_com(@ana)

    put api_v1_historico_url(@livro.id), params: { pagina: 1, total_paginas: 10, usuario_id: @beto.id }, as: :json

    assert_response :success
    assert @ana.historico_leituras.exists?(livro: @livro)
    assert_not @beto.historico_leituras.exists?(livro: @livro)
  end

  test "página inválida devolve 422" do
    entrar_com(@ana)

    [ { pagina: 0, total_paginas: 10 }, { pagina: 11, total_paginas: 10 }, { pagina: 2.5, total_paginas: 10 },
      { pagina: 3 }, { pagina: 1, total_paginas: 0 } ].each do |corpo|
      put api_v1_historico_url(@livro.id), params: corpo, as: :json

      assert_response :unprocessable_entity, "deveria recusar #{corpo}"
      assert_equal [ "deve estar entre 1 e o total de páginas" ], JSON.parse(response.body).dig("erros", "pagina")
    end
    assert_not @ana.historico_leituras.exists?
  end

  test "livro inexistente devolve 404" do
    entrar_com(@ana)

    put api_v1_historico_url(0), params: { pagina: 1, total_paginas: 10 }, as: :json

    assert_response :not_found
  end

  private

  def entrar_com(usuario)
    post api_v1_sessao_url, params: { email: usuario.email, password: "password123" }
    assert_response :success
  end
end
