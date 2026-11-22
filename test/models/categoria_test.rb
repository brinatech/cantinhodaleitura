require "test_helper"

class CategoriaTest < ActiveSupport::TestCase
  test "exige nome" do
    categoria = Categoria.new(nome: "")

    assert_not categoria.valid?
    assert_includes categoria.errors[:nome], "não pode ficar em branco"
  end

  test "limita o nome a 100 caracteres" do
    categoria = Categoria.new(nome: "a" * 101)

    assert_not categoria.valid?
    assert_includes categoria.errors[:nome], "é muito longo (máximo de 100 caracteres)"
  end

  test "não aceita nome repetido com letras maiúsculas diferentes" do
    categoria = Categoria.new(nome: "fantasia") # o fixture :one é "Fantasia"

    assert_not categoria.valid?
    assert_includes categoria.errors[:nome], "já está em uso"
  end

  test "tira os espaços sobrando do nome" do
    categoria = Categoria.new(nome: "  Contos   de fadas ")

    assert_equal "Contos de fadas", categoria.nome
  end

  test "não exclui categoria que tem livros" do
    categoria = categorias(:one) # o livro :one está nela

    assert_not categoria.destroy
    assert Categoria.exists?(categoria.id)
    assert_includes categoria.errors[:base],
                    "Não é possível excluir o registro pois existem livros dependentes"
  end

  test "exclui categoria sem livros" do
    categoria = Categoria.create!(nome: "Poesia")

    assert categoria.destroy
    assert_not Categoria.exists?(categoria.id)
  end
end
