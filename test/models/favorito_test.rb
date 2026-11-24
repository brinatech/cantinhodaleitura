require "test_helper"

class FavoritoTest < ActiveSupport::TestCase
  test "preenche a data do favorito sozinho" do
    favorito = Favorito.create!(usuario: usuarios(:one), livro: livros(:two))

    assert_not_nil favorito.data_favorito
  end

  test "não troca a data de um favorito antigo" do
    favorito = favoritos(:one)
    data_antiga = favorito.data_favorito

    favorito.save!

    assert_equal data_antiga, favorito.reload.data_favorito
  end

  test "não deixa favoritar o mesmo livro duas vezes" do
    repetido = Favorito.new(usuario: usuarios(:one), livro: livros(:one)) # o fixture :one já é esse par

    assert_not repetido.valid?
    assert_includes repetido.errors[:livro_id], "já está em uso"
  end

  test "pessoas diferentes podem favoritar o mesmo livro" do
    favorito = Favorito.new(usuario: usuarios(:two), livro: livros(:one))

    assert favorito.valid?
  end

  test "exige usuário e livro" do
    favorito = Favorito.new

    assert_not favorito.valid?
    assert_not_empty favorito.errors[:usuario]
    assert_not_empty favorito.errors[:livro]
  end
end
