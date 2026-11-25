require "test_helper"

class Api::V1::CadastrosMenoresControllerTest < ActionDispatch::IntegrationTest
  DADOS = { nome: "João", nome_usuario: "joao.leitor", password: "password123",
            responsavel_nome: "Carla Souza", responsavel_email: "carla.souza@example.com", autorizo: true }.freeze

  test "cria a conta bloqueada e envia o e-mail para o responsável" do
    assert_enqueued_emails 1 do
      post api_v1_cadastros_menores_url, params: { cadastro_menor: DADOS }, as: :json
    end

    assert_response :created
    resposta = JSON.parse(response.body)
    assert_equal "joao.leitor", resposta["nome_usuario"]
    assert_equal "c***a@example.com", resposta["responsavel_email"]
    assert_includes resposta["link_demonstracao"], "#/autorizar-menor?token="

    conta = Usuario.find_by!(nome_usuario: "joao.leitor")
    assert conta.menor?
    assert conta.aguardando_autorizacao?
    assert_equal "leitor", conta.tipo_usuario
    assert_nil conta.email
  end

  test "exige a declaração do responsável e mostra os erros por campo" do
    assert_no_enqueued_emails do
      post api_v1_cadastros_menores_url,
           params: { cadastro_menor: DADOS.merge(autorizo: false, nome_usuario: "", responsavel_email: "x") }, as: :json
    end

    assert_response :unprocessable_entity
    erros = JSON.parse(response.body)["erros"]
    assert erros["autorizo"].any?
    assert erros["nome_usuario"].any?
    assert erros["responsavel_email"].any?
    assert_equal 0, Usuario.where(menor: true).count
  end

  test "não aceita virar administrador nem nome de usuário repetido" do
    post api_v1_cadastros_menores_url, params: { cadastro_menor: DADOS.merge(tipo_usuario: "administrador") }, as: :json
    assert_equal "leitor", Usuario.find_by!(nome_usuario: "joao.leitor").tipo_usuario

    post api_v1_cadastros_menores_url, params: { cadastro_menor: DADOS }, as: :json
    assert_response :unprocessable_entity
    assert JSON.parse(response.body).dig("erros", "nome_usuario").any?
  end

  test "o e-mail leva o link para a página de autorização" do
    post api_v1_cadastros_menores_url, params: { cadastro_menor: DADOS }, as: :json
    conta = Usuario.find_by!(nome_usuario: "joao.leitor")

    email = UsuarioMailer.autorizar_menor(conta)

    assert_equal [ "carla.souza@example.com" ], email.to
    assert_includes email.body.to_s, "#/autorizar-menor?token="
    assert_includes email.body.to_s, "joao.leitor"
  end
end
