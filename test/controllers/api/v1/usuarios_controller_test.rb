require "test_helper"

class Api::V1::UsuariosControllerTest < ActionDispatch::IntegrationTest
  test "cadastra usuário sempre como leitor" do
    post api_v1_usuarios_url, params: {
      usuario: {
        nome: "Novo usuário",
        email: "novo@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    assert_response :created
    resposta = JSON.parse(response.body)

    assert_equal "leitor", resposta["tipo_usuario"]
    assert_nil resposta["password_digest"]
    assert Usuario.exists?(email: "novo@example.com")
  end
end