require "test_helper"

class AcessoMaterialTest < ActiveSupport::TestCase
  test "permite acesso de visitante" do
    acesso = AcessoMaterial.new(livro: livros(:one), usuario: nil)

    assert acesso.valid?
  end
end
