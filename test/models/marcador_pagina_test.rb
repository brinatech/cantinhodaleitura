require "test_helper"

class MarcadorPaginaTest < ActiveSupport::TestCase
  def novo_marcador(**atributos)
    MarcadorPagina.new(usuario: usuarios(:two), livro: livros(:one), pagina_atual: 5, **atributos)
  end

  test "é válido com usuário, livro e página" do
    assert novo_marcador.valid?
  end

  test "exige usuário e livro" do
    marcador = MarcadorPagina.new(pagina_atual: 1)

    assert_not marcador.valid?
    assert_not_empty marcador.errors[:usuario]
    assert_not_empty marcador.errors[:livro]
  end

  test "não aceita página zero, negativa ou quebrada" do
    [ 0, -3, 2.5 ].each do |pagina|
      marcador = novo_marcador(pagina_atual: pagina)

      assert_not marcador.valid?, "a página #{pagina} deveria ser recusada"
      assert_not_empty marcador.errors[:pagina_atual]
    end
  end

  test "aceita só a localização, sem página" do
    assert novo_marcador(pagina_atual: nil, localizacao: "audio:125").valid?
  end

  test "exige a página ou a localização" do
    marcador = novo_marcador(pagina_atual: nil, localizacao: nil)

    assert_not marcador.valid?
    assert_includes marcador.errors[:base], "Informe a página ou a localização"
  end

  test "localização tem no máximo 255 caracteres" do
    marcador = novo_marcador(localizacao: "a" * 256)

    assert_not marcador.valid?
    assert_not_empty marcador.errors[:localizacao]
  end

  test "um marcador por pessoa e livro" do
    repetido = MarcadorPagina.new(usuario: usuarios(:one), livro: livros(:one), pagina_atual: 3) # o fixture :one já é esse par

    assert_not repetido.valid?
    assert_includes repetido.errors[:livro_id], "já está em uso"
  end

  test "pessoas diferentes podem marcar o mesmo livro" do
    assert novo_marcador.valid? # usuário :two no livro :one
  end

  test "preenche a data ao criar" do
    marcador = novo_marcador
    marcador.save!

    assert_not_nil marcador.data_atualizacao
  end

  test "atualiza a data quando a página muda" do
    marcador = marcador_paginas(:one)
    data_antiga = marcador.data_atualizacao

    travel 1.minute do
      marcador.update!(pagina_atual: 9)
    end

    assert_operator marcador.reload.data_atualizacao, :>, data_antiga
  end

  test "não muda a data quando a posição não muda" do
    marcador = marcador_paginas(:one)
    data_antiga = marcador.data_atualizacao

    marcador.save!

    assert_equal data_antiga, marcador.reload.data_atualizacao
  end
end
