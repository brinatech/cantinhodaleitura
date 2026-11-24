require "test_helper"

class LivroTest < ActiveSupport::TestCase
  test "exige título" do
    livro = Livro.new(categoria: categorias(:one), usuario_cadastro: usuarios(:one))

    assert_not livro.valid?
    assert_includes livro.errors[:titulo], "não pode ficar em branco"
  end

  test "aceita capa em imagem" do
    livro = Livro.new(titulo: "Com capa", categoria: categorias(:one), usuario_cadastro: usuarios(:one))
    livro.capa.attach(io: StringIO.new("imagem"), filename: "capa.png", content_type: "image/png")

    assert livro.valid?
  end

  test "recusa capa que não é imagem" do
    livro = Livro.new(titulo: "Capa errada", categoria: categorias(:one), usuario_cadastro: usuarios(:one))
    livro.capa.attach(io: StringIO.new("%PDF-1.4"), filename: "capa.pdf", content_type: "application/pdf")

    assert_not livro.valid?
    assert_includes livro.errors[:capa], "deve ser uma imagem JPG, PNG ou WEBP"
  end

  test "recusa capa maior que 5 MB" do
    livro = Livro.new(titulo: "Capa grande", categoria: categorias(:one), usuario_cadastro: usuarios(:one))
    livro.capa.attach(io: StringIO.new("a" * (5.megabytes + 1)), filename: "capa.jpg", content_type: "image/jpeg")

    assert_not livro.valid?
    assert_includes livro.errors[:capa], "pode ter no máximo 5 MB"
  end
end
