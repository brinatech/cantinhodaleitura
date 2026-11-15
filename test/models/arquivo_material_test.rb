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

  test "recusa MIME e extensão não permitidos" do
    arquivo = ArquivoMaterial.new(livro: livros(:one), tipo: "texto")
    arquivo.arquivo.attach(
      io: StringIO.new("executável"),
      filename: "livro.exe",
      content_type: "application/x-msdownload"
    )

    assert_not arquivo.valid?
    assert_includes arquivo.errors[:arquivo], "possui um tipo não permitido"
    assert_includes arquivo.errors[:arquivo], "possui uma extensão não permitida"
  end
end