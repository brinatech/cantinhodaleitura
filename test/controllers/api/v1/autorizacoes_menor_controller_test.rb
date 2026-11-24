require "test_helper"

class Api::V1::AutorizacoesMenorControllerTest < ActionDispatch::IntegrationTest
  setup do
    @conta = Usuario.create!(nome: "João", nome_usuario: "joao.leitor", password: "password123", menor: true,
                             responsavel_nome: "Carla", responsavel_email: "carla@example.com")
    @token = @conta.generate_token_for(:autorizacao_responsavel)
  end

  def entrar_como_joao
    post api_v1_sessao_url, params: { email: "joao.leitor", password: "password123" }
  end

  test "mostra o resumo do cadastro sem pedir login" do
    get api_v1_autorizacoes_menor_url(@token)

    assert_response :success
    resposta = JSON.parse(response.body)
    assert_equal [ "João", "joao.leitor", "Carla" ], resposta.values_at("nome", "nome_usuario", "responsavel_nome")
    assert_not_includes response.body, "password_digest"
  end

  test "antes de autorizar a criança não entra; depois de autorizar, entra pelo nome de usuário" do
    entrar_como_joao
    assert_response :forbidden
    assert_match "autorizada", JSON.parse(response.body)["erro"]

    patch api_v1_autorizacoes_menor_url(@token)
    assert_response :success
    assert_not @conta.reload.aguardando_autorizacao?

    entrar_como_joao
    assert_response :success
    assert_equal true, JSON.parse(response.body)["menor"]
  end

  test "o link vale uma resposta só" do
    patch api_v1_autorizacoes_menor_url(@token)

    get api_v1_autorizacoes_menor_url(@token)
    assert_response :not_found
    delete api_v1_autorizacoes_menor_url(@token)
    assert_response :not_found
    assert Usuario.exists?(@conta.id)
  end

  test "recusar apaga o cadastro" do
    delete api_v1_autorizacoes_menor_url(@token)

    assert_response :no_content
    assert_not Usuario.exists?(@conta.id)
  end

  test "link inválido ou vencido devolve 404" do
    get api_v1_autorizacoes_menor_url("token-inventado")
    assert_response :not_found

    travel 8.days do
      get api_v1_autorizacoes_menor_url(@token)
      assert_response :not_found
    end
  end

  test "recuperar a senha pelo nome de usuário manda o link para o responsável" do
    @conta.update!(autorizado_em: Time.current)

    assert_enqueued_emails 1 do
      post api_v1_recuperacao_senha_url, params: { email: "joao.leitor" }
    end

    email = UsuarioMailer.recuperar_senha(@conta)
    assert_equal [ "carla@example.com" ], email.to
  end

  test "cadastro não confirmado em 7 dias é apagado pela limpeza diária" do
    confirmado = Usuario.create!(nome: "Bia", nome_usuario: "bia", password: "password123", menor: true,
                                 responsavel_nome: "Rui", responsavel_email: "rui@example.com", autorizado_em: Time.current)

    travel 8.days do
      LimparCadastrosMenoresPendentesJob.perform_now
    end

    assert_not Usuario.exists?(@conta.id)
    assert Usuario.exists?(confirmado.id)
  end

  test "perfil da criança não troca o e-mail" do
    @conta.update!(autorizado_em: Time.current)
    entrar_como_joao

    patch api_v1_perfil_url, params: { usuario: { nome: "Joãozinho", email: "joao@example.com" } }

    assert_response :success
    @conta.reload
    assert_equal "Joãozinho", @conta.nome
    assert_nil @conta.email
  end
end
