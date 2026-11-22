require "test_helper"

class Api::V1::FavoritosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ana = Usuario.create!(nome: "Ana", email: "ana-favoritos@example.com", password: "password123")
    @beto = Usuario.create!(nome: "Beto", email: "beto-favoritos@example.com", password: "password123")
    @livro = livros(:one)
    @outro_livro = livros(:two)
  end

  test "visitante não usa favoritos e recebe 401" do
    get api_v1_favoritos_url
    assert_response :unauthorized

    post api_v1_favoritos_url, params: { livro_id: @livro.id }, as: :json
    assert_response :unauthorized

    delete api_v1_favorito_url(@livro.id)
    assert_response :unauthorized
  end

  test "lista só os favoritos de quem está logado, do mais recente para o mais antigo" do
    Favorito.create!(usuario: @ana, livro: @livro, data_favorito: 2.days.ago)
    Favorito.create!(usuario: @ana, livro: @outro_livro, data_favorito: 1.day.ago)
    Favorito.create!(usuario: @beto, livro: @livro) # de outra pessoa: não pode aparecer
    entrar_com(@ana)

    get api_v1_favoritos_url

    assert_response :success
    resposta = JSON.parse(response.body)
    assert_equal [ @outro_livro.id, @livro.id ], resposta.map { |favorito| favorito["livro_id"] }
    assert_equal @outro_livro.titulo, resposta.first.dig("livro", "titulo")
    assert_equal @outro_livro.categoria.nome, resposta.first.dig("livro", "categoria", "nome")
  end

  test "favorita um livro" do
    entrar_com(@ana)

    assert_difference "@ana.favoritos.count", 1 do
      post api_v1_favoritos_url, params: { livro_id: @livro.id }, as: :json
    end

    assert_response :created
    resposta = JSON.parse(response.body)
    assert_equal @livro.id, resposta["livro_id"]
    assert_not_nil resposta["data_favorito"]
  end

  test "ignora um usuario_id mandado pelo navegador" do
    entrar_com(@ana)

    post api_v1_favoritos_url, params: { livro_id: @livro.id, usuario_id: @beto.id }, as: :json

    assert_response :created
    assert @ana.favoritos.exists?(livro: @livro)
    assert_not @beto.favoritos.exists?(livro: @livro)
  end

  test "não favorita o mesmo livro duas vezes e responde 409" do
    Favorito.create!(usuario: @ana, livro: @livro)
    entrar_com(@ana)

    assert_no_difference "Favorito.count" do
      post api_v1_favoritos_url, params: { livro_id: @livro.id }, as: :json
    end

    assert_response :conflict
    assert_equal "Este livro já está nos seus favoritos", JSON.parse(response.body)["erro"]
  end

  test "responde 404 ao favoritar livro que não existe" do
    entrar_com(@ana)

    post api_v1_favoritos_url, params: { livro_id: -1 }, as: :json

    assert_response :not_found
    assert_equal "Livro não encontrado", JSON.parse(response.body)["erro"]
  end

  test "desfavorita um livro" do
    Favorito.create!(usuario: @ana, livro: @livro)
    entrar_com(@ana)

    assert_difference "@ana.favoritos.count", -1 do
      delete api_v1_favorito_url(@livro.id)
    end

    assert_response :no_content
  end

  test "não apaga o favorito de outra pessoa" do
    favorito_do_beto = Favorito.create!(usuario: @beto, livro: @livro)
    entrar_com(@ana)

    delete api_v1_favorito_url(@livro.id)

    assert_response :not_found
    assert_equal "Este livro não está nos seus favoritos", JSON.parse(response.body)["erro"]
    assert Favorito.exists?(favorito_do_beto.id)
  end

  private

  def entrar_com(usuario)
    post api_v1_sessao_url, params: { email: usuario.email, password: "password123" }
    assert_response :success
  end
end
