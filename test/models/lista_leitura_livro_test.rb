require "test_helper"

class ListaLeituraLivroTest < ActiveSupport::TestCase
  test "o mesmo livro não entra duas vezes na mesma lista" do
    repetido = ListaLeituraLivro.new(lista_leitura: lista_leituras(:one), livro: livros(:one)) # o fixture :one já é esse par

    assert_not repetido.valid?
    assert_includes repetido.errors[:livro_id], "já está em uso"
  end

  test "o mesmo livro pode estar em listas diferentes" do
    assert ListaLeituraLivro.new(lista_leitura: lista_leituras(:two), livro: livros(:one)).valid?
  end

  test "exige lista e livro" do
    item = ListaLeituraLivro.new

    assert_not item.valid?
    assert_not_empty item.errors[:lista_leitura]
    assert_not_empty item.errors[:livro]
  end

  test "pôr um livro atualiza a data da lista" do
    lista = lista_leituras(:two)
    antes = lista.updated_at

    travel 1.minute do
      ListaLeituraLivro.create!(lista_leitura: lista, livro: livros(:one))
    end

    assert_operator lista.reload.updated_at, :>, antes
  end
end
