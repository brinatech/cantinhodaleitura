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

  test "recusa material sem anexo e sem caminho legado" do
    arquivo = ArquivoMaterial.new(livro: livros(:one), tipo: "texto")

    assert_not arquivo.valid?
    assert_includes arquivo.errors[:arquivo], "deve ser informado"
  end

  test "aceita anexos PDF e MP3 sem caminho legado" do
    pdf = ArquivoMaterial.new(livro: livros(:one), tipo: "texto")
    pdf.arquivo.attach(io: StringIO.new("%PDF-1.4"), filename: "livro.pdf", content_type: "application/pdf")

    audio = ArquivoMaterial.new(livro: livros(:one), tipo: "audio")
    audio.arquivo.attach(io: StringIO.new("ID3"), filename: "livro.mp3", content_type: "audio/mpeg")

    assert pdf.valid?, pdf.errors.full_messages.to_sentence
    assert audio.valid?, audio.errors.full_messages.to_sentence
  end

  test "recusa anexo maior que 50 MB" do
    arquivo = ArquivoMaterial.new(livro: livros(:one), tipo: "texto")
    conteudo = "%PDF-1.4".ljust(50.megabytes + 1, " ")
    arquivo.arquivo.attach(io: StringIO.new(conteudo), filename: "livro.pdf", content_type: "application/pdf")

    assert_not arquivo.valid?
    assert_includes arquivo.errors[:arquivo], "excede o tamanho máximo permitido"
  end
end
