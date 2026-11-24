require "test_helper"

class ListaLeituraTest < ActiveSupport::TestCase
  test "nome é obrigatório e tem no máximo 100 caracteres" do
    assert_not ListaLeitura.new(usuario: usuarios(:one), nome: "   ").valid?
    assert_not ListaLeitura.new(usuario: usuarios(:one), nome: "a" * 101).valid?
    assert ListaLeitura.new(usuario: usuarios(:one), nome: "a" * 100).valid?
  end

  test "tira os espaços do começo e do fim do nome" do
    lista = ListaLeitura.create!(usuario: usuarios(:one), nome: "  Para as férias  ")

    assert_equal "Para as férias", lista.nome
  end

  test "exige dono" do
    lista = ListaLeitura.new(nome: "Sem dono")

    assert_not lista.valid?
    assert_not_empty lista.errors[:usuario]
  end

  test "preenche a data de criação sozinha" do
    lista = ListaLeitura.create!(usuario: usuarios(:one), nome: "Nova")

    assert_not_nil lista.data_criacao
  end

  test "apagar a lista tira os livros dela, mas os livros continuam no acervo" do
    lista = lista_leituras(:one) # tem o livro :one
    livro = livros(:one)

    assert_difference "ListaLeituraLivro.count", -1 do
      lista.destroy!
    end
    assert Livro.exists?(livro.id)
  end
end
