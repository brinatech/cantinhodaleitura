require "test_helper"

class ArquivoMaterialTest < ActiveSupport::TestCase
  test "aceita texto e áudio" do
    assert ArquivoMaterial.new(
      livro: livros(:one),
      tipo: "texto",
      caminho: "novo-livro.pdf"
    ).valid?

    assert ArquivoMaterial.new(
      livro: livros(:one),
      tipo: "audio",
      caminho: "novo-livro.mp3"
    ).valid?
  end

  test "recusa tipo desconhecido" do
    arquivo = ArquivoMaterial.new(
      livro: livros(:one),
      tipo: "video",
      caminho: "novo-livro.mp4"
    )

    assert_not arquivo.valid?
  end
end