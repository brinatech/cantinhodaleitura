require "test_helper"

class Api::V1::LivrosControllerTest < ActionDispatch::IntegrationTest
  test "lista livros publicamente com suas categorias" do
    categoria = Categoria.create!(nome: "Fantasia pública", descricao: "Aventuras")
    usuario = Usuario.create!(
      nome: "Usuário responsável",
      email: "responsavel-api@example.com",
      tipo_usuario: "leitor",
      password: "password123"
    )
    livro = Livro.create!(
      titulo: "Livro público",
      autor: "Autor público",
      descricao: "Descrição pública",
      capa_url: "https://example.com/livro-publico.jpg",
      categoria: categoria,
      usuario_cadastro: usuario
    )
    ArquivoMaterial.create!(livro: livro, tipo: "texto", caminho: "livro-publico.pdf")
    ArquivoMaterial.create!(livro: livro, tipo: "audio", caminho: "livro-publico.mp3")

    get api_v1_livros_url

    assert_response :success
    resposta = JSON.parse(response.body)
    livro_json = resposta.find { |item| item["id"] == livro.id }

    assert_equal livro.titulo, livro_json["titulo"]
    assert_equal livro.capa_url, livro_json["capa_url"]
    assert_equal [ "audio", "texto" ], livro_json["formatos"].map { |formato| formato["tipo"] }.sort
    assert_equal categoria.nome, livro_json.dig("categoria", "nome")
    assert_nil livro_json["email"]
    assert_nil livro_json["password_digest"]
    assert_nil livro_json["usuario_cadastro"]
  end
end
