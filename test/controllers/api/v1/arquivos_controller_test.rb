require "test_helper"

class Api::V1::ArquivosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @categoria = Categoria.create!(nome: "Arquivos", descricao: "Categoria de arquivos")
    @usuario = Usuario.create!(nome: "Leitor", email: "arquivo@example.com", password: "password123")
    @livro = Livro.create!(titulo: "Livro com arquivo", categoria: @categoria, usuario_cadastro: @usuario)
    @arquivo = ArquivoMaterial.new(livro: @livro, tipo: "texto")
    @arquivo.arquivo.attach(io: StringIO.new("%PDF-1.4"), filename: "livro.pdf", content_type: "application/pdf")
    @arquivo.save!
  end

  test "exige autenticação para baixar arquivo" do
    get api_v1_livro_arquivo_url(@livro, @arquivo)

    assert_response :unauthorized
  end

  test "redireciona usuário autenticado para URL assinada do arquivo" do
    post api_v1_sessao_url, params: { email: @usuario.email, password: "password123" }
    get api_v1_livro_arquivo_url(@livro, @arquivo)

    assert_response :redirect
    assert_includes response.location, "/rails/active_storage/blobs/"
  end
end