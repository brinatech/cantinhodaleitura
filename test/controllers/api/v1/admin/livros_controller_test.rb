require "test_helper"

class Api::V1::Admin::LivrosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @categoria = Categoria.create!(nome: "Administração", descricao: "Categoria administrativa")
    @leitor = Usuario.create!(nome: "Leitor", email: "leitor-admin@example.com", password: "password123")
    @administrador = Usuario.create!(
      nome: "Administrador",
      email: "administrador@example.com",
      tipo_usuario: "administrador",
      password: "password123"
    )
    @upload = Tempfile.new([ "livro", ".pdf" ])
    @upload.write("%PDF-1.4\n")
    @upload.close
  end

  teardown do
    @upload.close!
  end

  test "apenas administrador pode criar livro" do
    entrar_com(@leitor)
    post api_v1_admin_livros_url, params: { livro: { titulo: "Livro bloqueado", id_categoria: @categoria.id } }

    assert_response :forbidden
    assert_equal "Acesso restrito a administradores", JSON.parse(response.body)["erro"]

    entrar_com(@administrador)
    post api_v1_admin_livros_url, params: {
      livro: {
        titulo: "Livro administrativo",
        autor: "Autora",
        descricao: "Descrição",
        id_categoria: @categoria.id,
        usuario_cadastro_id: @leitor.id,
        arquivo: {
          tipo: "texto",
          arquivo: Rack::Test::UploadedFile.new(@upload.path, "application/pdf")
        }
      }
    }

    assert_response :created
    livro = Livro.find(JSON.parse(response.body)["id"])
    assert_equal @administrador.id, livro.usuario_cadastro_id
    assert livro.arquivos.first.arquivo.attached?
    assert_equal ".pdf", File.extname(livro.arquivos.first.arquivo.filename.to_s)
  end

  test "administrador envia capa junto com o livro" do
    entrar_com(@administrador)
    post api_v1_admin_livros_url, params: {
      livro: {
        titulo: "Livro com capa",
        id_categoria: @categoria.id,
        capa: Rack::Test::UploadedFile.new(StringIO.new("imagem"), "image/png", original_filename: "capa.png"),
        arquivo: { tipo: "texto", arquivo: Rack::Test::UploadedFile.new(@upload.path, "application/pdf") }
      }
    }

    assert_response :created
    livro = Livro.find(JSON.parse(response.body)["id"])
    assert livro.capa.attached?
    assert_match %r{/rails/active_storage/blobs/}, JSON.parse(response.body)["capa_url"]
  end

  test "retorna 422 para capa que não é imagem" do
    entrar_com(@administrador)
    post api_v1_admin_livros_url, params: {
      livro: {
        titulo: "Capa errada",
        id_categoria: @categoria.id,
        capa: Rack::Test::UploadedFile.new(@upload.path, "application/pdf"),
        arquivo: { tipo: "texto", arquivo: Rack::Test::UploadedFile.new(@upload.path, "application/pdf") }
      }
    }

    assert_response :unprocessable_entity
    assert_includes JSON.parse(response.body).dig("erros", "capa"), "deve ser uma imagem JPG, PNG ou WEBP"
  end

  test "retorna 422 para livro inválido" do
    entrar_com(@administrador)
    post api_v1_admin_livros_url, params: { livro: { autor: "Sem título", id_categoria: @categoria.id } }

    assert_response :unprocessable_entity
    assert JSON.parse(response.body).dig("erros", "titulo").any?
  end

  test "retorna 404 ao alterar ou excluir livro inexistente" do
    entrar_com(@administrador)

    patch api_v1_admin_livro_url(id: -1), params: { livro: { titulo: "Novo título" } }
    assert_response :not_found
    assert_equal "Livro não encontrado", JSON.parse(response.body)["erro"]

    delete api_v1_admin_livro_url(id: -1)
    assert_response :not_found
    assert_equal "Livro não encontrado", JSON.parse(response.body)["erro"]
  end

  private

  def entrar_com(usuario)
    post api_v1_sessao_url, params: { email: usuario.email, password: "password123" }
    assert_response :success
  end
end
