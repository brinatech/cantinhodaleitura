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
end
