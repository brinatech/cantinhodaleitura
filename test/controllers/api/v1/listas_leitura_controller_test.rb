require "test_helper"

class Api::V1::ListasLeituraControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ana = Usuario.create!(nome: "Ana", email: "ana-listas@example.com", password: "password123")
    @beto = Usuario.create!(nome: "Beto", email: "beto-listas@example.com", password: "password123")
    @livro = livros(:one)
    @outro_livro = livros(:two)
  end

  test "visitante não usa listas e recebe 401" do
    get api_v1_listas_leitura_index_url
    assert_response :unauthorized

    post api_v1_listas_leitura_index_url, params: { nome: "Férias" }, as: :json
    assert_response :unauthorized
  end

  test "lista só as minhas listas, a mexida mais recentemente primeiro, com os livros" do
    antiga = @ana.lista_leituras.create!(nome: "Antiga")
    nova = @ana.lista_leituras.create!(nome: "Nova")
    antiga.lista_leitura_livros.create!(livro: @livro) # mexer na antiga faz ela subir
    @beto.lista_leituras.create!(nome: "Do Beto")
    entrar_com(@ana)

    get api_v1_listas_leitura_index_url

    assert_response :success
    resposta = JSON.parse(response.body)
    assert_equal [ antiga.id, nova.id ], resposta.map { |lista| lista["id"] }
    assert_equal 1, resposta.first["total_livros"]
    assert_equal [ @livro.id ], resposta.first["livro_ids"]
    assert_equal @livro.titulo, resposta.first.dig("capas", 0, "titulo")
  end

  test "cria uma lista minha, ignorando usuario_id do navegador" do
    entrar_com(@ana)

    post api_v1_listas_leitura_index_url, params: { nome: "Dragões", descricao: "Só histórias de dragão", usuario_id: @beto.id }, as: :json

    assert_response :created
    lista = @ana.lista_leituras.find_by(nome: "Dragões")
    assert lista
    assert_equal "Só histórias de dragão", lista.descricao
    assert_empty @beto.lista_leituras
  end

  test "nome vazio devolve 422 com o erro" do
    entrar_com(@ana)

    post api_v1_listas_leitura_index_url, params: { nome: "" }, as: :json

    assert_response :unprocessable_entity
    assert_equal [ "não pode ficar em branco" ], JSON.parse(response.body).dig("erros", "nome")
  end

  test "mostra uma lista com os livros, o adicionado mais recentemente primeiro" do
    lista = @ana.lista_leituras.create!(nome: "Férias")
    lista.lista_leitura_livros.create!(livro: @livro, created_at: 2.days.ago)
    lista.lista_leitura_livros.create!(livro: @outro_livro, created_at: 1.day.ago)
    entrar_com(@ana)

    get api_v1_listas_leitura_url(lista)

    assert_response :success
    resposta = JSON.parse(response.body)
    assert_equal "Férias", resposta["nome"]
    assert_equal [ @outro_livro.id, @livro.id ], resposta["livros"].map { |livro| livro["id"] }
    assert_equal @livro.categoria.nome, resposta["livros"].last.dig("categoria", "nome")
  end

  test "renomeia e apaga uma lista minha" do
    lista = @ana.lista_leituras.create!(nome: "Velho")
    lista.lista_leitura_livros.create!(livro: @livro)
    entrar_com(@ana)

    patch api_v1_listas_leitura_url(lista), params: { nome: "Novo" }, as: :json
    assert_response :success
    assert_equal "Novo", lista.reload.nome

    delete api_v1_listas_leitura_url(lista)
    assert_response :no_content
    assert_not ListaLeitura.exists?(lista.id)
    assert Livro.exists?(@livro.id)
  end

  test "lista de outra pessoa responde 404 e não muda" do
    do_beto = @beto.lista_leituras.create!(nome: "Do Beto")
    entrar_com(@ana)

    get api_v1_listas_leitura_url(do_beto)
    assert_response :not_found

    patch api_v1_listas_leitura_url(do_beto), params: { nome: "Roubada" }, as: :json
    assert_response :not_found

    delete api_v1_listas_leitura_url(do_beto)
    assert_response :not_found

    assert_equal "Do Beto", do_beto.reload.nome
  end

  private

  def entrar_com(usuario)
    post api_v1_sessao_url, params: { email: usuario.email, password: "password123" }
    assert_response :success
  end
end
