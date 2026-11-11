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
    assert_includes usuario.errors[:nome], "can't be blank"
    assert_includes usuario.errors[:email], "can't be blank"
    assert_includes usuario.errors[:tipo_usuario], "is not included in the list"
  end
end
