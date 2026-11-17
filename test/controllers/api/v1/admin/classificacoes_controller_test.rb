require "test_helper"

class Api::V1::Admin::ClassificacoesControllerTest < ActionDispatch::IntegrationTest
  setup do
    categoria = Categoria.create!(nome: "Classificações admin", descricao: "Categoria de teste")
    @leitor = Usuario.create!(nome: "Leitor", email: "leitor-classificacao@example.com", password: "password123")
    @administrador = Usuario.create!(
      nome: "Administrador",
      email: "admin-classificacao@example.com",
      tipo_usuario: "administrador",
      password: "password123"
    )
    @livro = Livro.create!(titulo: "Livro classificado", categoria: categoria, usuario_cadastro: @administrador)
    @outro_livro = Livro.create!(titulo: "Outro livro", categoria: categoria, usuario_cadastro: @administrador)
    @classificacao = Classificacao.create!(livro: @livro, tipo: "faixa_etaria", nome: "6+")
    @classificacao_de_outro = Classificacao.create!(livro: @outro_livro, tipo: "genero", nome: "Fantasia")
  end

  test "visitante não acessa classificações" do
    get api_v1_admin_livro_classificacoes_url(@livro)

    assert_response :unauthorized
  end

  test "leitor não lista, cria nem exclui classificações" do
    entrar_com(@leitor)

    get api_v1_admin_livro_classificacoes_url(@livro)
    assert_response :forbidden

    assert_no_difference "Classificacao.count" do
      post api_v1_admin_livro_classificacoes_url(@livro), params: { classificacao: { tipo: "genero", nome: "Aventura" } }
      assert_response :forbidden

      delete api_v1_admin_livro_classificacao_url(@livro, @classificacao)
      assert_response :forbidden
    end
  end

  test "administrador lista só as classificações do livro" do
    entrar_com(@administrador)
    get api_v1_admin_livro_classificacoes_url(@livro)

    assert_response :success
    resposta = JSON.parse(response.body)
    assert_equal [ @classificacao.id ], resposta.map { |item| item["id"] }
    assert_equal "6+", resposta.first["nome"]
  end

  test "administrador cria classificação no livro da URL" do
    entrar_com(@administrador)

    assert_difference "@livro.classificacoes.count", 1 do
      post api_v1_admin_livro_classificacoes_url(@livro), params: {
        classificacao: { tipo: "acessibilidade", nome: "Audiodescrição", livro_id: @outro_livro.id }
      }
    end

    assert_response :created
    assert_equal "Audiodescrição", JSON.parse(response.body)["nome"]
  end

  test "retorna 422 para classificação inválida" do
    entrar_com(@administrador)
    post api_v1_admin_livro_classificacoes_url(@livro), params: { classificacao: { tipo: "xyz", nome: "" } }

    assert_response :unprocessable_entity
    erros = JSON.parse(response.body)["erros"]
    assert erros["tipo"].any?
    assert erros["nome"].any?
  end

  test "administrador exclui classificação" do
    entrar_com(@administrador)

    assert_difference "Classificacao.count", -1 do
      delete api_v1_admin_livro_classificacao_url(@livro, @classificacao)
    end

    assert_response :no_content
  end

  test "não exclui classificação de outro livro pela URL" do
    entrar_com(@administrador)

    assert_no_difference "Classificacao.count" do
      delete api_v1_admin_livro_classificacao_url(@livro, @classificacao_de_outro)
    end

    assert_response :not_found
  end

  test "retorna 404 para livro inexistente" do
    entrar_com(@administrador)
    get api_v1_admin_livro_classificacoes_url(livro_id: -1)

    assert_response :not_found
    assert_equal "Livro não encontrado", JSON.parse(response.body)["erro"]
  end

  private

  def entrar_com(usuario)
    post api_v1_sessao_url, params: { email: usuario.email, password: "password123" }
    assert_response :success
  end
end
