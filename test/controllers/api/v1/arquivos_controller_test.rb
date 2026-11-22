require "test_helper"

class Api::V1::ArquivosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @categoria = Categoria.create!(nome: "Arquivos", descricao: "Categoria de arquivos")
    @usuario = Usuario.create!(nome: "Leitor", email: "arquivo@example.com", password: "password123")
    @livro = Livro.create!(titulo: "Livro com arquivo", categoria: @categoria, usuario_cadastro: @usuario)
    @arquivo = ArquivoMaterial.new(livro: @livro, tipo: "texto")
    @arquivo.arquivo.attach(io: StringIO.new("%PDF-1.4"), filename: "livro.pdf", content_type: "application/pdf")
    @arquivo.save!
  end

  test "visitante (sem login) consegue abrir o arquivo" do
    get api_v1_livro_arquivo_url(@livro, @arquivo, modo: "leitura")

    assert_response :redirect
    assert_includes response.location, "/rails/active_storage/blobs/"
  end

  test "redireciona usuário autenticado para URL assinada do arquivo" do
    post api_v1_sessao_url, params: { email: @usuario.email, password: "password123" }
    get api_v1_livro_arquivo_url(@livro, @arquivo)

    assert_response :redirect
    assert_includes response.location, "/rails/active_storage/blobs/"
  end

  test "sem modo, o arquivo é baixado" do
    entrar
    get api_v1_livro_arquivo_url(@livro, @arquivo)

    assert_response :redirect
    assert_includes response.location, "disposition=attachment"
  end

  test "no modo leitura, o arquivo abre no navegador" do
    entrar
    get api_v1_livro_arquivo_url(@livro, @arquivo, modo: "leitura")

    assert_response :redirect
    assert_includes response.location, "disposition=inline"
  end

  test "o link do arquivo vale por 5 minutos" do
    entrar
    get api_v1_livro_arquivo_url(@livro, @arquivo, modo: "leitura")
    link = response.location

    # Dentro do prazo: o Active Storage aceita o link e leva até o arquivo
    travel 4.minutes do
      get link
      assert_response :redirect
    end

    # Depois do prazo: o link venceu
    travel 6.minutes do
      get link
      assert_response :not_found
    end
  end

  test "responde 404 para arquivo que não é do livro" do
    outro_livro = Livro.create!(titulo: "Outro livro", categoria: @categoria, usuario_cadastro: @usuario)
    entrar
    get api_v1_livro_arquivo_url(outro_livro, @arquivo)

    assert_response :not_found
    assert_equal "Arquivo não encontrado", JSON.parse(response.body)["erro"]
  end

  # ===== HU-10 Task 3: registro dos acessos =====

  test "abrir para ler registra uma leitura do usuário logado, uma vez só na mesma sessão" do
    entrar

    assert_difference "AcessoMaterial.where(tipo_acesso: 'leitura').count", 1 do
      get api_v1_livro_arquivo_url(@livro, @arquivo, modo: "leitura")
      get api_v1_livro_arquivo_url(@livro, @arquivo, modo: "leitura", v: 2) # o player renovando o link
    end

    acesso = AcessoMaterial.last
    assert_equal @livro, acesso.livro
    assert_equal @usuario, acesso.usuario
  end

  test "baixar registra um download; visitante fica sem usuário" do
    assert_difference "AcessoMaterial.where(tipo_acesso: 'download').count", 1 do
      get api_v1_livro_arquivo_url(@livro, @arquivo)
    end

    assert_nil AcessoMaterial.last.usuario
  end

  test "arquivo que não existe não registra nada" do
    outro_livro = Livro.create!(titulo: "Outro livro", categoria: @categoria, usuario_cadastro: @usuario)

    assert_no_difference "AcessoMaterial.count" do
      get api_v1_livro_arquivo_url(outro_livro, @arquivo, modo: "leitura")
    end
  end

  private

  def entrar
    post api_v1_sessao_url, params: { email: @usuario.email, password: "password123" }
    assert_response :success
  end
end
