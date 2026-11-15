require "test_helper"

class UsuarioTest < ActiveSupport::TestCase
  test "normaliza email e aceita perfil válido" do
    usuario = Usuario.new(
      nome: "Novo leitor",
      email: "  LEITOR-NOVO@example.com ",
      tipo_usuario: "leitor",
      password: "password123"
    )

    assert usuario.valid?
    assert_equal "leitor-novo@example.com", usuario.email
  end

  test "exige nome, email e perfil válido" do
    usuario = Usuario.new(tipo_usuario: "perfil-invalido")

    assert_not usuario.valid?
    assert_includes usuario.errors[:nome], "não pode ficar em branco"
    assert_includes usuario.errors[:email], "não pode ficar em branco"
    assert_includes usuario.errors[:tipo_usuario], "não está na lista"
  end

  test "rejeita senha curta, nome curto e textos acima do limite do banco" do
    usuario = Usuario.new(nome: "A", email: "#{"x" * 150}@example.com", password: "1234567")

    assert_not usuario.valid?
    assert usuario.errors[:password].any?
    assert usuario.errors[:nome].any?
    assert usuario.errors[:email].any?
    assert_not Usuario.new(nome: "A" * 101, email: "ok@example.com", password: "12345678").valid?
  end

  test "aceita senha de 8 caracteres" do
    assert Usuario.new(nome: "Ana", email: "ana@example.com", password: "12345678").valid?
  end
end
