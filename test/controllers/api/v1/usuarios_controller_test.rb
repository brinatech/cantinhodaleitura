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

  test "ignora tipo_usuario enviado pelo navegador" do
    post api_v1_usuarios_url, params: {
      usuario: { nome: "Espertinho", email: "admin@example.com", password: "password123", tipo_usuario: "administrador" }
    }

    assert_response :created
    assert_equal "leitor", Usuario.find_by!(email: "admin@example.com").tipo_usuario
  end

  test "recusa email repetido, mesmo com outra caixa, sem criar segunda conta" do
    Usuario.create!(nome: "Primeira", email: "repetido@example.com", password: "password123")

    assert_no_difference "Usuario.count" do
      post api_v1_usuarios_url, params: {
        usuario: { nome: "Segunda", email: "REPETIDO@example.com", password: "password123" }
      }
    end

    assert_response :unprocessable_entity
    assert_equal [ "já está em uso" ], JSON.parse(response.body).dig("erros", "email")
  end

  test "devolve os erros por campo" do
    post api_v1_usuarios_url, params: { usuario: { nome: "", email: "invalido", password: "curta" } }

    assert_response :unprocessable_entity
    erros = JSON.parse(response.body)["erros"]
    assert erros["nome"].any?
    assert erros["email"].any?
    assert_includes erros["password"], "é muito curto (mínimo de 8 caracteres)"
  end
end
