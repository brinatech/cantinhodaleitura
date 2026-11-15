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
    assert_kind_of Array, resposta
    livro_json = resposta.find { |item| item["id"] == livro.id }

    assert_not_nil livro_json
    assert_equal livro.titulo, livro_json["titulo"]
    assert_equal livro.autor, livro_json["autor"]
    assert_equal livro.descricao, livro_json["descricao"]
    assert_equal livro.capa_url, livro_json["capa_url"]
    assert_equal [ "audio", "texto" ], livro_json["formatos"].map { |formato| formato["tipo"] }.sort
    assert_equal [ "livro-publico.mp3", "livro-publico.pdf" ], livro_json["formatos"].map { |formato| formato["caminho"] }.sort
    assert_equal categoria.nome, livro_json.dig("categoria", "nome")
    assert_equal categoria.id, livro_json.dig("categoria", "id")
    assert_equal categoria.descricao, livro_json.dig("categoria", "descricao")
    assert_equal [], livro_json["classificacoes"]
    assert_nil livro_json["email"]
    assert_nil livro_json["password_digest"]
    assert_nil livro_json["usuario_cadastro"]
  end

  test "exibe os detalhes de um livro com suas classificações" do
    categoria = Categoria.create!(nome: "Detalhes", descricao: "Categoria de detalhes")
    usuario = Usuario.create!(
      nome: "Usuário dos detalhes",
      email: "detalhes-api@example.com",
      tipo_usuario: "leitor",
      password: "password123"
    )
    livro = Livro.create!(
      titulo: "Livro detalhado",
      autor: "Autor detalhado",
      descricao: "Descrição detalhada",
      categoria: categoria,
      usuario_cadastro: usuario
    )
    Classificacao.create!(
      livro: livro,
      tipo: "formato",
      nome: "PDF",
      descricao: "Documento portátil"
    )

    get api_v1_livro_url(livro)

    assert_response :success
    resposta = JSON.parse(response.body)

    assert_equal livro.id, resposta["id"]
    assert_equal livro.titulo, resposta["titulo"]
    assert_equal livro.autor, resposta["autor"]
    assert_equal livro.descricao, resposta["descricao"]
    assert_nil resposta["capa_url"]
    assert_equal [], resposta["formatos"]
    assert_equal categoria.nome, resposta.dig("categoria", "nome")
    assert_equal "PDF", resposta.dig("classificacoes", 0, "nome")
    assert_equal "formato", resposta.dig("classificacoes", 0, "tipo")
    assert_equal "Documento portátil", resposta.dig("classificacoes", 0, "descricao")
    assert_nil resposta["password_digest"]
    assert_nil resposta["usuario_cadastro"]
  end

  test "preserva campos opcionais ausentes e listas vazias" do
    categoria = Categoria.create!(nome: "Sem opcionais", descricao: "Categoria mínima")
    usuario = Usuario.create!(
      nome: "Usuário sem opcionais",
      email: "sem-opcionais-api@example.com",
      tipo_usuario: "leitor",
      password: "password123"
    )
    livro = Livro.create!(
      titulo: "Livro sem opcionais",
      autor: nil,
      descricao: nil,
      capa_url: nil,
      categoria: categoria,
      usuario_cadastro: usuario
    )

    get api_v1_livro_url(livro)

    assert_response :success
    resposta = JSON.parse(response.body)

    assert_equal livro.titulo, resposta["titulo"]
    assert_nil resposta["autor"]
    assert_nil resposta["descricao"]
    assert_nil resposta["capa_url"]
    assert_equal [], resposta["formatos"]
    assert_equal [], resposta["classificacoes"]
  end

  test "serializa classificações com campos opcionais ausentes" do
    categoria = Categoria.create!(nome: "Classificação parcial", descricao: "Categoria parcial")
    usuario = Usuario.create!(
      nome: "Usuário da classificação parcial",
      email: "classificacao-parcial-api@example.com",
      tipo_usuario: "leitor",
      password: "password123"
    )
    livro = Livro.create!(
      titulo: "Livro com classificação parcial",
      categoria: categoria,
      usuario_cadastro: usuario
    )
    classificacao = Classificacao.create!(livro: livro, tipo: "acessibilidade", nome: nil, descricao: nil)

    get api_v1_livro_url(livro)

    assert_response :success
    resposta = JSON.parse(response.body)
    classificacao_json = resposta["classificacoes"].find { |item| item["tipo"] == classificacao.tipo }

    assert_not_nil classificacao_json
    assert_nil classificacao_json["nome"]
    assert_nil classificacao_json["descricao"]
  end

  test "pesquisa livros por texto e formato" do
    categoria = Categoria.create!(nome: "Busca pela API")
    usuario = Usuario.create!(nome: "Responsável", email: "busca-api@example.com", password: "password123")
    com_audio = Livro.create!(titulo: "Lua Cheia", autor: "Ana", categoria: categoria, usuario_cadastro: usuario)
    sem_audio = Livro.create!(titulo: "Lua Nova", autor: "Rita", categoria: categoria, usuario_cadastro: usuario)
    ArquivoMaterial.create!(livro: com_audio, tipo: "audio", caminho: "lua-cheia.mp3")
    ArquivoMaterial.create!(livro: sem_audio, tipo: "texto", caminho: "lua-nova.pdf")

    get api_v1_livros_url, params: { q: "lua", formato: "audio" }

    assert_response :success
    assert_equal [ com_audio.id ], JSON.parse(response.body).map { |livro| livro["id"] }
  end

  test "retorna 404 quando o livro não existe" do
    get api_v1_livro_url(id: -1)

    assert_response :not_found
    assert_equal "Livro não encontrado", JSON.parse(response.body)["erro"]
  end
end
