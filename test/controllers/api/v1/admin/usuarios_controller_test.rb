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

  private

  def entrar_com(usuario)
    post api_v1_sessao_url, params: { email: usuario.email, password: "password123" }
    assert_response :success
  end
end
