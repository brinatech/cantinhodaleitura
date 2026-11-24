require "test_helper"

class Api::V1::PerfilControllerTest < ActionDispatch::IntegrationTest
  setup do
    @usuario = Usuario.create!(nome: "Maria", email: "perfil@example.com", password: "password123")
    @outro = Usuario.create!(nome: "Outra", email: "outra@example.com", password: "password123")
  end

  def entrar
    post api_v1_sessao_url, params: { email: @usuario.email, password: "password123" }
  end

  test "exige login em todas as ações" do
    get api_v1_perfil_url
    assert_response :unauthorized
    patch api_v1_perfil_url, params: { usuario: { nome: "X" } }
    assert_response :unauthorized
    patch senha_api_v1_perfil_url, params: { senha_atual: "password123", password: "novasenha123" }
    assert_response :unauthorized
  end

  test "mostra os dados do próprio usuário sem hash de senha" do
    entrar
    get api_v1_perfil_url

    assert_response :success
    resposta = JSON.parse(response.body)
    assert_equal @usuario.id, resposta["id"]
    assert_nil resposta["password_digest"]
  end

  test "atualiza nome e email e ignora tipo_usuario" do
    entrar
    patch api_v1_perfil_url, params: { usuario: { nome: "Maria Souza", email: "NOVO@example.com", tipo_usuario: "administrador" } }

    assert_response :success
    @usuario.reload
    assert_equal "Maria Souza", @usuario.nome
    assert_equal "novo@example.com", @usuario.email
    assert_equal "leitor", @usuario.tipo_usuario
  end

  test "recusa email de outra conta" do
    entrar
    patch api_v1_perfil_url, params: { usuario: { email: @outro.email } }

    assert_response :unprocessable_entity
    assert JSON.parse(response.body).dig("erros", "email").any?
    assert_equal "perfil@example.com", @usuario.reload.email
  end

  test "troca a senha só com a senha atual correta" do
    entrar
    patch senha_api_v1_perfil_url, params: { senha_atual: "errada", password: "novasenha123" }
    assert_response :unprocessable_entity
    assert JSON.parse(response.body).dig("erros", "senha_atual").any?

    patch senha_api_v1_perfil_url, params: { senha_atual: "password123", password: "curta" }
    assert_response :unprocessable_entity

    patch senha_api_v1_perfil_url, params: { senha_atual: "password123", password: "novasenha123" }
    assert_response :no_content
    assert @usuario.reload.authenticate("novasenha123")
  end

  test "excluir a conta exige login e a senha atual" do
    delete api_v1_perfil_url, params: { senha_atual: "password123" }
    assert_response :unauthorized

    entrar
    delete api_v1_perfil_url, params: { senha_atual: "errada" }
    assert_response :unprocessable_entity
    assert JSON.parse(response.body).dig("erros", "senha_atual").any?
    assert_not @usuario.reload.excluido?
  end

  test "exclui a própria conta: anonimiza, encerra a sessão e não deixa entrar de novo" do
    Favorito.create!(usuario: @usuario, livro: livros(:one))
    entrar

    delete api_v1_perfil_url, params: { senha_atual: "password123" }

    assert_response :no_content
    assert response.headers["X-CSRF-Token"].present?
    @usuario.reload
    assert @usuario.excluido?
    assert_equal "Conta excluída", @usuario.nome
    assert_equal 0, @usuario.favoritos.count

    get api_v1_perfil_url
    assert_response :unauthorized

    post api_v1_sessao_url, params: { email: "perfil@example.com", password: "password123" }
    assert_response :unauthorized
  end

  test "só exclui a conta de quem está logado" do
    entrar
    delete api_v1_perfil_url, params: { senha_atual: "password123", id: @outro.id }

    assert @usuario.reload.excluido?
    assert_not @outro.reload.excluido?
    assert_equal "Outra", @outro.nome
  end

  test "administrador não exclui a própria conta por aqui" do
    admin = Usuario.create!(nome: "Admin", email: "admin-perfil@example.com", password: "password123", tipo_usuario: "administrador")
    post api_v1_sessao_url, params: { email: admin.email, password: "password123" }

    delete api_v1_perfil_url, params: { senha_atual: "password123" }

    assert_response :forbidden
    assert_not admin.reload.excluido?
  end
end
