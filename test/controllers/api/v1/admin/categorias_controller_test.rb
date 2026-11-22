require "test_helper"

class Api::V1::Admin::CategoriasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @leitor = Usuario.create!(nome: "Leitor", email: "leitor-categorias@example.com", password: "password123")
    @administrador = Usuario.create!(
      nome: "Administrador",
      email: "admin-categorias@example.com",
      tipo_usuario: "administrador",
      password: "password123"
    )
  end

  test "visitante não acessa e recebe 401" do
    get api_v1_admin_categorias_url

    assert_response :unauthorized
  end

  test "leitor não acessa e recebe 403" do
    entrar_com(@leitor)

    get api_v1_admin_categorias_url
    assert_response :forbidden

    delete api_v1_admin_categoria_url(categorias(:two))
    assert_response :forbidden
    assert Categoria.exists?(categorias(:two).id)
  end

  test "administrador lista as categorias em ordem alfabética" do
    entrar_com(@administrador)

    get api_v1_admin_categorias_url

    assert_response :success
    nomes = JSON.parse(response.body).map { |categoria| categoria["nome"] }
    assert_equal [ "Fantasia", "Romance" ], nomes
  end

  test "mostra uma categoria e responde 404 quando ela não existe" do
    entrar_com(@administrador)

    get api_v1_admin_categoria_url(categorias(:one))
    assert_response :success
    assert_equal "Fantasia", JSON.parse(response.body)["nome"]

    get api_v1_admin_categoria_url(id: -1)
    assert_response :not_found
    assert_equal "Categoria não encontrada", JSON.parse(response.body)["erro"]
  end

  test "cria categoria" do
    entrar_com(@administrador)

    assert_difference "Categoria.count", 1 do
      post api_v1_admin_categorias_url, params: { categoria: { nome: "Poesia", descricao: "Poemas" } }
    end

    assert_response :created
    assert_equal "Poesia", JSON.parse(response.body)["nome"]
  end

  test "não cria categoria com nome repetido" do
    entrar_com(@administrador)

    assert_no_difference "Categoria.count" do
      post api_v1_admin_categorias_url, params: { categoria: { nome: "fantasia" } }
    end

    assert_response :unprocessable_entity
    assert_includes JSON.parse(response.body).dig("erros", "nome"), "já está em uso"
  end

  test "edita categoria" do
    entrar_com(@administrador)

    patch api_v1_admin_categoria_url(categorias(:two)), params: { categoria: { nome: "Romance juvenil" } }

    assert_response :success
    assert_equal "Romance juvenil", categorias(:two).reload.nome
  end

  test "exclui categoria sem livros" do
    entrar_com(@administrador)
    categoria = Categoria.create!(nome: "Poesia")

    delete api_v1_admin_categoria_url(categoria)

    assert_response :no_content
    assert_not Categoria.exists?(categoria.id)
  end

  test "não exclui categoria com livros e responde 409" do
    entrar_com(@administrador)

    delete api_v1_admin_categoria_url(categorias(:one))

    assert_response :conflict
    assert_equal "Não é possível excluir o registro pois existem livros dependentes",
                 JSON.parse(response.body)["erro"]
    assert Categoria.exists?(categorias(:one).id)
  end

  private

  def entrar_com(usuario)
    post api_v1_sessao_url, params: { email: usuario.email, password: "password123" }
    assert_response :success
  end
end
