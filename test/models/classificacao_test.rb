require "test_helper"

class ClassificacaoTest < ActiveSupport::TestCase
  test "é válida com tipo da lista e nome" do
    classificacao = Classificacao.new(livro: livros(:one), tipo: "faixa_etaria", nome: "6+")

    assert classificacao.valid?
  end

  test "recusa tipo fora da lista" do
    classificacao = Classificacao.new(livro: livros(:one), tipo: "xyz", nome: "6+")

    assert_not classificacao.valid?
    assert classificacao.errors[:tipo].any?
  end

  test "exige nome com até 100 caracteres" do
    sem_nome = Classificacao.new(livro: livros(:one), tipo: "genero")
    nome_longo = Classificacao.new(livro: livros(:one), tipo: "genero", nome: "a" * 101)

    assert_not sem_nome.valid?
    assert_not nome_longo.valid?
  end

  test "acessibilidade aceita só recursos da lista" do
    Classificacao::RECURSOS_ACESSIBILIDADE.each do |recurso|
      assert Classificacao.new(livro: livros(:one), tipo: "acessibilidade", nome: recurso).valid?, recurso
    end

    invalida = Classificacao.new(livro: livros(:one), tipo: "acessibilidade", nome: "Braille")

    assert_not invalida.valid?
    assert invalida.errors[:nome].any?
  end

  test "a lista de recursos vale só para o tipo acessibilidade" do
    assert Classificacao.new(livro: livros(:one), tipo: "genero", nome: "Braille").valid?
  end

  test "exige livro" do
    classificacao = Classificacao.new(tipo: "genero", nome: "Fantasia")

    assert_not classificacao.valid?
  end
end
