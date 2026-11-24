require "test_helper"

class Api::V1::Admin::UsuariosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = Usuario.create!(nome: "Admin Contas", email: "admin-contas@example.com", password: "password123", tipo_usuario: "administrador")
    @leitor = Usuario.create!(nome: "Ana Leitora", email: "ana@example.com", password: "password123")
  end

  test "lista as contas com a data de exclusão e sem senha" do
    entrar_com(@admin)

    get api_v1_admin_usuarios_url

    assert_response :success
    ana = JSON.parse(response.body).find { |usuario| usuario["id"] == @leitor.id }
    assert ana.key?("excluido_em")
    assert_not_includes response.body, "password_digest"
  end

  test "não reativa nem muda o tipo de uma conta excluída pelo próprio usuário (HU-21)" do
    ExcluirConta.call(usuario: @leitor)
    entrar_com(@admin)

    patch api_v1_admin_usuario_url(@leitor), params: { usuario: { ativo: true } }, as: :json
    assert_response :forbidden

    patch api_v1_admin_usuario_url(@leitor), params: { usuario: { tipo_usuario: "administrador" } }, as: :json
    assert_response :forbidden

    @leitor.reload
    assert_not @leitor.ativo
    assert_equal "leitor", @leitor.tipo_usuario
  end

  test "mostra os dados do responsável e não libera conta de menor sem a autorização dele (HU-20)" do
    joao = Usuario.create!(nome: "João", nome_usuario: "joao.leitor", password: "password123", menor: true, ativo: false,
                           responsavel_nome: "Carla", responsavel_email: "carla@example.com")
    entrar_com(@admin)

    get api_v1_admin_usuarios_url
    conta = JSON.parse(response.body).find { |usuario| usuario["id"] == joao.id }
    assert_equal [ true, "joao.leitor", "Carla", nil ], conta.values_at("menor", "nome_usuario", "responsavel_nome", "autorizado_em")

    patch api_v1_admin_usuario_url(joao), params: { usuario: { ativo: true } }, as: :json
    assert_response :forbidden
    assert_not joao.reload.ativo

    joao.update!(ativo: true, autorizado_em: Time.current)
    patch api_v1_admin_usuario_url(joao), params: { usuario: { tipo_usuario: "administrador" } }, as: :json
    assert_response :forbidden
    assert_equal "leitor", joao.reload.tipo_usuario

    patch api_v1_admin_usuario_url(joao), params: { usuario: { ativo: false } }, as: :json
    assert_response :success
    assert_not joao.reload.ativo
  end

  private

  def entrar_com(usuario)
    post api_v1_sessao_url, params: { email: usuario.email, password: "password123" }
    assert_response :success
  end
end
