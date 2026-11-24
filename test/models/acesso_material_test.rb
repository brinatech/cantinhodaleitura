require "test_helper"

class AcessoMaterialTest < ActiveSupport::TestCase
  test "permite acesso de visitante" do
    acesso = AcessoMaterial.new(livro: livros(:one), usuario: nil, tipo_acesso: "leitura")

    assert acesso.valid?
  end

  test "aceita só visualizacao, leitura e download" do
    %w[visualizacao leitura download].each do |tipo|
      assert AcessoMaterial.new(livro: livros(:one), tipo_acesso: tipo).valid?, "#{tipo} deveria ser aceito"
    end

    [ "abriu", "", nil ].each do |tipo|
      assert_not AcessoMaterial.new(livro: livros(:one), tipo_acesso: tipo).valid?, "#{tipo.inspect} deveria ser recusado"
    end
  end

  test "exige livro" do
    acesso = AcessoMaterial.new(tipo_acesso: "leitura")

    assert_not acesso.valid?
    assert_not_empty acesso.errors[:livro]
  end

  test "preenche a data do acesso sozinha" do
    acesso = AcessoMaterial.create!(livro: livros(:one), tipo_acesso: "download")

    assert_not_nil acesso.data_acesso
  end
end
