require "test_helper"

class Api::V1::RecuperacoesSenhaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @usuario = Usuario.create!(nome: "Leitora", email: "recuperar@example.com", password: "password123")
  end

  test "envia o email de recuperação quando a conta existe" do
    assert_enqueued_emails 1 do
      post api_v1_recuperacao_senha_url, params: { email: " RECUPERAR@example.com " }
    end

    assert_response :no_content
  end

  test "responde igual e não envia nada quando a conta não existe" do
    assert_no_enqueued_emails do
      post api_v1_recuperacao_senha_url, params: { email: "ninguem@example.com" }
    end

    assert_response :no_content
  end

  test "o email traz o link com o token" do
    email = UsuarioMailer.recuperar_senha(@usuario)

    assert_includes email.to, @usuario.email
    assert_includes email.body.to_s, "#/redefinir-senha?token="
  end

  test "troca a senha com o token e o token deixa de valer" do
    token = @usuario.password_reset_token

    patch api_v1_recuperacao_senha_url, params: { token: token, password: "novasenha123" }

    assert_response :no_content
    assert @usuario.reload.authenticate("novasenha123")

    patch api_v1_recuperacao_senha_url, params: { token: token, password: "outrasenha123" }

    assert_response :unprocessable_entity
    assert @usuario.reload.authenticate("novasenha123")
  end

  test "recusa token inválido, senha em branco e senha curta" do
    patch api_v1_recuperacao_senha_url, params: { token: "lixo", password: "novasenha123" }
    assert_response :unprocessable_entity
    assert JSON.parse(response.body).dig("erros", "token").any?

    token = @usuario.password_reset_token
    patch api_v1_recuperacao_senha_url, params: { token: token, password: "" }
    assert_response :unprocessable_entity
    assert JSON.parse(response.body).dig("erros", "password").any?

    patch api_v1_recuperacao_senha_url, params: { token: token, password: "curta" }
    assert_response :unprocessable_entity
    assert @usuario.reload.authenticate("password123")
  end

  test "token expirado não troca a senha" do
    token = @usuario.password_reset_token

    travel 16.minutes do
      patch api_v1_recuperacao_senha_url, params: { token: token, password: "novasenha123" }
    end

    assert_response :unprocessable_entity
    assert @usuario.reload.authenticate("password123")
  end
end
