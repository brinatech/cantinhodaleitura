require "test_helper"

class Api::V1::SessoesControllerTest < ActionDispatch::IntegrationTest
  test "faz login, atualiza último acesso e retorna usuário atual" do
    usuario = Usuario.create!(
      nome: "Leitor da sessão",
      email: "sessao@example.com",
      tipo_usuario: "leitor",
      password: "password123"
    )

    post api_v1_sessao_url, params: { email: usuario.email, password: "password123" }

    assert_response :success
    assert_not_nil usuario.reload.ultimo_acesso_em

    get api_v1_sessao_url

    assert_response :success
    assert_equal usuario.id, JSON.parse(response.body)["id"]
  end

  test "bloqueia usuário inativo" do
    usuario = Usuario.create!(
      nome: "Leitor bloqueado",
      email: "bloqueado@example.com",
      tipo_usuario: "leitor",
      ativo: false,
      password: "password123"
    )

    post api_v1_sessao_url, params: { email: usuario.email, password: "password123" }

    assert_response :unauthorized
  end

  test "normaliza email no login e rejeita senha inválida" do
    usuario = Usuario.create!(
      nome: "Leitor normalizado",
      email: "normalizado@example.com",
      tipo_usuario: "leitor",
      password: "password123"
    )

    post api_v1_sessao_url, params: { email: " NORMALIZADO@EXAMPLE.COM ", password: "password123" }

    assert_response :success
    assert_equal usuario.id, JSON.parse(response.body)["id"]
    assert_nil JSON.parse(response.body)["password_digest"]

    delete api_v1_sessao_url
    post api_v1_sessao_url, params: { email: usuario.email, password: "senha-incorreta" }

    assert_response :unauthorized
  end

  test "encerra a sessão" do
    usuario = Usuario.create!(
      nome: "Leitor logout",
      email: "logout@example.com",
      tipo_usuario: "leitor",
      password: "password123"
    )
    post api_v1_sessao_url, params: { email: usuario.email, password: "password123" }

    delete api_v1_sessao_url
    get api_v1_sessao_url

    assert_response :unauthorized
  end

  test "devolve o token CSRF novo no header, inclusive depois do login" do
    usuario = Usuario.create!(nome: "Leitor do token", email: "token@example.com", password: "password123")

    get api_v1_sessao_url
    assert_response :unauthorized
    assert response.headers["X-CSRF-Token"].present?

    post api_v1_sessao_url, params: { email: usuario.email, password: "password123" }
    assert response.headers["X-CSRF-Token"].present?
  end
end
