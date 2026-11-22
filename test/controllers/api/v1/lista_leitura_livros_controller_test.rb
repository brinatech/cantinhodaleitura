require "test_helper"

class Api::V1::ListaLeituraLivrosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ana = Usuario.create!(nome: "Ana", email: "ana-itens@example.com", password: "password123")
    @beto = Usuario.create!(nome: "Beto", email: "beto-itens@example.com", password: "password123")
    @lista = @ana.lista_leituras.create!(nome: "Férias")
    @livro = livros(:one)
  end

  test "visitante recebe 401" do
    post api_v1_listas_leitura_livros_url(@lista), params: { livro_id: @livro.id }, as: :json
    assert_response :unauthorized

    delete api_v1_listas_leitura_livro_url(@lista, @livro.id)
    assert_response :unauthorized
  end

  test "põe um livro na lista" do
    entrar_com(@ana)

    post api_v1_listas_leitura_livros_url(@lista), params: { livro_id: @livro.id }, as: :json

    assert_response :created
    assert_equal [ @livro.id ], @lista.livros.pluck(:id)
  end

  test "livro repetido na mesma lista devolve 409" do
    @lista.lista_leitura_livros.create!(livro: @livro)
    entrar_com(@ana)

    assert_no_difference "ListaLeituraLivro.count" do
      post api_v1_listas_leitura_livros_url(@lista), params: { livro_id: @livro.id }, as: :json
    end

    assert_response :conflict
    assert_equal "Este livro já está na lista", JSON.parse(response.body)["erro"]
  end

  test "livro inexistente devolve 404" do
    entrar_com(@ana)

    post api_v1_listas_leitura_livros_url(@lista), params: { livro_id: 0 }, as: :json

    assert_response :not_found
  end

  test "tira um livro da lista" do
    @lista.lista_leitura_livros.create!(livro: @livro)
    entrar_com(@ana)

    delete api_v1_listas_leitura_livro_url(@lista, @livro.id)

    assert_response :no_content
    assert_empty @lista.livros
    assert Livro.exists?(@livro.id)
  end

  test "tirar livro que não está na lista devolve 404" do
    entrar_com(@ana)

    delete api_v1_listas_leitura_livro_url(@lista, @livro.id)

    assert_response :not_found
  end

  test "não mexe na lista de outra pessoa" do
    do_beto = @beto.lista_leituras.create!(nome: "Do Beto")
    do_beto.lista_leitura_livros.create!(livro: @livro)
    entrar_com(@ana)

    post api_v1_listas_leitura_livros_url(do_beto), params: { livro_id: livros(:two).id }, as: :json
    assert_response :not_found

    delete api_v1_listas_leitura_livro_url(do_beto, @livro.id)
    assert_response :not_found

    assert_equal [ @livro.id ], do_beto.livros.pluck(:id)
  end

  private

  def entrar_com(usuario)
    post api_v1_sessao_url, params: { email: usuario.email, password: "password123" }
    assert_response :success
  end
end
