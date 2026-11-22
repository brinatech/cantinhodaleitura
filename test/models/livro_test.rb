require "test_helper"

class LivroTest < ActiveSupport::TestCase
  test "exige título" do
    livro = Livro.new(categoria: categorias(:one), usuario_cadastro: usuarios(:one))

    assert_not livro.valid?
    assert_includes livro.errors[:titulo], "não pode ficar em branco"
  end
end
