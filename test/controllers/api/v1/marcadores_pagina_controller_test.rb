require "test_helper"

class Api::V1::MarcadoresPaginaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ana = Usuario.create!(nome: "Ana", email: "ana-marcador@example.com", password: "password123")
    @beto = Usuario.create!(nome: "Beto", email: "beto-marcador@example.com", password: "password123")
    @livro = livros(:one)
  end

  test "visitante não usa marcador e recebe 401" do
    get api_v1_marcadores_pagina_url(@livro.id)
    assert_response :unauthorized

    put api_v1_marcadores_pagina_url(@livro.id), params: { pagina_atual: 3 }, as: :json
    assert_response :unauthorized
  end

  test "sem marcador ainda, devolve null" do
    entrar_com(@ana)

    get api_v1_marcadores_pagina_url(@livro.id)

    assert_response :success
    assert_nil JSON.parse(response.body)
  end

  test "salva a página pela primeira vez" do
    entrar_com(@ana)

    assert_difference "@ana.marcador_paginas.count", 1 do
      put api_v1_marcadores_pagina_url(@livro.id), params: { pagina_atual: 11 }, as: :json
    end

    assert_response :success
    resposta = JSON.parse(response.body)
    assert_equal 11, resposta["pagina_atual"]
    assert_equal @livro.id, resposta["livro_id"]
    assert_not_nil resposta["data_atualizacao"]
  end

  test "salvar de novo atualiza o mesmo marcador" do
    MarcadorPagina.create!(usuario: @ana, livro: @livro, pagina_atual: 4)
    entrar_com(@ana)

    assert_no_difference "MarcadorPagina.count" do
      put api_v1_marcadores_pagina_url(@livro.id), params: { pagina_atual: 12 }, as: :json
    end

    assert_response :success
    assert_equal 12, @ana.marcador_paginas.find_by(livro: @livro).pagina_atual

    get api_v1_marcadores_pagina_url(@livro.id)
    assert_equal 12, JSON.parse(response.body)["pagina_atual"]
  end

  test "ignora usuario_id mandado pelo navegador" do
    entrar_com(@ana)

    put api_v1_marcadores_pagina_url(@livro.id), params: { pagina_atual: 5, usuario_id: @beto.id }, as: :json

    assert_response :success
    assert @ana.marcador_paginas.exists?(livro: @livro)
    assert_not @beto.marcador_paginas.exists?(livro: @livro)
  end

  test "não mostra nem altera o marcador de outra pessoa" do
    MarcadorPagina.create!(usuario: @beto, livro: @livro, pagina_atual: 30)
    entrar_com(@ana)

    get api_v1_marcadores_pagina_url(@livro.id)
    assert_nil JSON.parse(response.body)

    put api_v1_marcadores_pagina_url(@livro.id), params: { pagina_atual: 2 }, as: :json
    assert_equal 30, @beto.marcador_paginas.find_by(livro: @livro).pagina_atual
  end

  test "página inválida devolve 422 com o erro" do
    entrar_com(@ana)

    put api_v1_marcadores_pagina_url(@livro.id), params: { pagina_atual: 0 }, as: :json

    assert_response :unprocessable_entity
    assert_equal [ "deve ser maior que 0" ], JSON.parse(response.body).dig("erros", "pagina_atual")
  end

  test "livro inexistente devolve 404" do
    entrar_com(@ana)

    get api_v1_marcadores_pagina_url(0)
    assert_response :not_found

    put api_v1_marcadores_pagina_url(0), params: { pagina_atual: 1 }, as: :json
    assert_response :not_found
  end

  private

  def entrar_com(usuario)
    post api_v1_sessao_url, params: { email: usuario.email, password: "password123" }
    assert_response :success
  end
end
