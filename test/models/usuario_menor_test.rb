require "test_helper"

# HU-20 (versão proposta): conta de criança/adolescente criada pelo responsável
class UsuarioMenorTest < ActiveSupport::TestCase
  def menor(**dados)
    Usuario.new({ nome: "João", nome_usuario: "joao.leitor", password: "password123", menor: true,
                  responsavel_nome: "Carla", responsavel_email: "carla@example.com" }.merge(dados))
  end

  test "conta de menor não precisa de e-mail, mas precisa de nome de usuário e do responsável" do
    assert menor.valid?

    conta = menor(nome_usuario: nil, responsavel_nome: "", responsavel_email: "")
    assert_not conta.valid?
    assert conta.errors[:nome_usuario].any?
    assert conta.errors[:responsavel_nome].any?
    assert conta.errors[:responsavel_email].any?
  end

  test "conta de adulto continua exigindo e-mail" do
    adulto = Usuario.new(nome: "Ana", password: "password123")

    assert_not adulto.valid?
    assert adulto.errors[:email].any?
  end

  test "nome de usuário: minúsculo, sem espaço nas pontas, sem @ e único" do
    conta = menor(nome_usuario: "  Joao.Leitor ")
    assert_equal "joao.leitor", conta.nome_usuario
    conta.save!

    assert_not menor(nome_usuario: "JOAO.LEITOR", responsavel_email: "outro@example.com").valid?
    assert_not menor(nome_usuario: "joao@leitor").valid?
    assert_not menor(nome_usuario: "jo").valid?
    assert_not menor(nome_usuario: "joão").valid?
  end

  test "e-mail do responsável precisa ser válido" do
    assert_not menor(responsavel_email: "carla").valid?
  end

  test "aguarda autorização até o responsável confirmar" do
    conta = menor
    assert conta.aguardando_autorizacao?

    conta.autorizado_em = Time.current
    assert_not conta.aguardando_autorizacao?
    assert_not Usuario.new(nome: "Ana", email: "a@example.com").aguardando_autorizacao?
  end

  test "login aceita e-mail ou nome de usuário" do
    conta = menor.tap(&:save!)
    adulto = Usuario.create!(nome: "Ana", email: "ana-login@example.com", password: "password123")

    assert_equal conta, Usuario.para_login(" JOAO.LEITOR ")
    assert_equal adulto, Usuario.para_login("ANA-login@example.com")
    assert_nil Usuario.para_login("")
  end

  test "o token do link deixa de valer depois que o responsável responde" do
    conta = menor.tap(&:save!)
    token = conta.generate_token_for(:autorizacao_responsavel)
    assert_equal conta, Usuario.find_by_token_for(:autorizacao_responsavel, token)

    conta.update!(autorizado_em: Time.current)
    assert_nil Usuario.find_by_token_for(:autorizacao_responsavel, token)
  end

  test "excluir a conta de um menor apaga também os dados do responsável" do
    conta = menor(autorizado_em: Time.current).tap(&:save!)

    ExcluirConta.call(usuario: conta)
    conta.reload

    assert_equal [ false, nil, nil, nil ], [ conta.menor, conta.nome_usuario, conta.responsavel_nome, conta.responsavel_email ]
    assert conta.excluido?
  end
end
