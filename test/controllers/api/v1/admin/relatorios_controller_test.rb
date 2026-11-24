require "test_helper"

class Api::V1::Admin::RelatoriosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = Usuario.create!(nome: "Admin", email: "admin-relatorios@example.com", password: "password123", tipo_usuario: "administrador")
    @leitor = Usuario.create!(nome: "Leitor", email: "leitor-relatorios@example.com", password: "password123")
  end

  test "visitante recebe 401 e leitor recebe 403" do
    get api_v1_admin_relatorios_resumo_url
    assert_response :unauthorized

    entrar_com(@leitor)
    get api_v1_admin_relatorios_resumo_url
    assert_response :forbidden
  end

  test "sem datas, mostra o mês atual" do
    entrar_com(@admin)

    travel_to Time.zone.parse("2026-11-22 15:00:00 -03:00") do
      get api_v1_admin_relatorios_resumo_url
    end

    assert_response :success
    resposta = JSON.parse(response.body)
    assert_equal({ "inicio" => "2026-11-01", "fim" => "2026-11-22" }, resposta["periodo"])
    assert_equal %w[download leitura visualizacao], resposta["acessos"].keys.sort
    assert resposta["livros"].key?("total")
    assert resposta.key?("mais_acessados")
    assert resposta.key?("leitores_cadastrados")
  end

  test "aceita um período escolhido" do
    entrar_com(@admin)

    get api_v1_admin_relatorios_resumo_url, params: { inicio: "2026-10-01", fim: "2026-10-31" }

    assert_response :success
    assert_equal({ "inicio" => "2026-10-01", "fim" => "2026-10-31" }, JSON.parse(response.body)["periodo"])
  end

  test "datas inválidas devolvem 422 com a mensagem" do
    entrar_com(@admin)

    {
      { inicio: "01/10/2026" } => "Use datas no formato AAAA-MM-DD",
      { inicio: "2026-10-31", fim: "2026-10-01" } => "O início precisa ser antes do fim",
      { inicio: "2025-01-01", fim: "2026-10-01" } => "O período pode ter no máximo 1 ano"
    }.each do |params, mensagem|
      get api_v1_admin_relatorios_resumo_url, params: params

      assert_response :unprocessable_entity, "deveria recusar #{params}"
      assert_equal mensagem, JSON.parse(response.body)["erro"]
    end
  end

  private

  def entrar_com(usuario)
    post api_v1_sessao_url, params: { email: usuario.email, password: "password123" }
    assert_response :success
  end
end
