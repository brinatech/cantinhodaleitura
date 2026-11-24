require "test_helper"

class LivrosQueryTest < ActiveSupport::TestCase
  setup do
    usuario = Usuario.create!(nome: "Responsável", email: "busca@example.com", password: "password123")
    @fantasia = Categoria.create!(nome: "Fantasia da busca")
    @aventura = Categoria.create!(nome: "Aventura da busca")

    @dragao = Livro.create!(titulo: "Dragão Azul", autor: "Ana Lima", categoria: @fantasia,
                            usuario_cadastro: usuario, created_at: 1.day.ago)
    @mapa = Livro.create!(titulo: "Mapa do Quintal", autor: "Rita Souza", categoria: @aventura,
                          usuario_cadastro: usuario)

    ArquivoMaterial.create!(livro: @dragao, tipo: "texto", caminho: "dragao.pdf")
    ArquivoMaterial.create!(livro: @dragao, tipo: "audio", caminho: "dragao.mp3")
    ArquivoMaterial.create!(livro: @mapa, tipo: "texto", caminho: "mapa.pdf")

    Classificacao.create!(livro: @dragao, tipo: "faixa_etaria", nome: "6+")
    Classificacao.create!(livro: @mapa, tipo: "faixa_etaria", nome: "9+")
  end

  test "busca no título sem diferenciar maiúsculas" do
    assert_equal [ @dragao.id ], buscar(q: "AZUL")
    assert_equal [ @dragao.id ], buscar(q: "dragão")
  end

  test "busca no autor" do
    assert_equal [ @mapa.id ], buscar(q: "rita")
  end

  test "% e _ na busca valem como texto e não como curinga" do
    assert_empty buscar(q: "%")
    assert_empty buscar(q: "_")
  end

  test "filtra por categoria" do
    assert_equal [ @mapa.id ], buscar(categoria_id: @aventura.id)
  end

  test "filtra por classificação" do
    assert_equal [ @dragao.id ], buscar(tipo_classificacao: "faixa_etaria", classificacao: "6+")
    assert_equal [ @dragao.id, @mapa.id ].sort, buscar(tipo_classificacao: "faixa_etaria").sort
  end

  test "filtra por formato" do
    assert_includes buscar(formato: "audio"), @dragao.id
    assert_not_includes buscar(formato: "audio"), @mapa.id
    assert_includes buscar(formato: "texto"), @mapa.id
  end

  test "filtros combinados devolvem a interseção" do
    assert_equal [ @dragao.id ], buscar(categoria_id: @fantasia.id, formato: "audio")
    assert_empty buscar(categoria_id: @aventura.id, formato: "audio")
    assert_equal [ @dragao.id ], buscar(q: "ana", categoria_id: @fantasia.id, classificacao: "6+")
  end

  test "ordena só pelas opções permitidas" do
    assert_equal [ @dragao.id, @mapa.id ], buscar(tipo_classificacao: "faixa_etaria", ordem: "titulo")
    assert_equal [ @mapa.id, @dragao.id ], buscar(tipo_classificacao: "faixa_etaria", ordem: "recentes")
  end

  test "mais lidos: quem tem mais leituras primeiro; sem leituras, os mais recentes" do
    # Sem nenhuma leitura: igual a "recentes" (o mapa é o mais novo)
    assert_equal [ @mapa.id, @dragao.id ], buscar(tipo_classificacao: "faixa_etaria", ordem: "mais_lidos")

    # O dragão ganha 2 leituras; visualizações e downloads não contam
    2.times { AcessoMaterial.create!(livro: @dragao, tipo_acesso: "leitura") }
    3.times { AcessoMaterial.create!(livro: @mapa, tipo_acesso: "visualizacao") }
    AcessoMaterial.create!(livro: @mapa, tipo_acesso: "leitura")

    assert_equal [ @dragao.id, @mapa.id ], buscar(tipo_classificacao: "faixa_etaria", ordem: "mais_lidos")
  end

  test "ordenação fora da lista e parâmetros estranhos são ignorados" do
    esperado = [ @dragao.id, @mapa.id ].sort

    assert_equal esperado, buscar(tipo_classificacao: "faixa_etaria", ordem: "id; DROP TABLE livros").sort
    assert_empty buscar(categoria_id: { x: 1 })
    assert_empty buscar(q: [ "dragão", "mapa" ])
    assert Livro.exists?
  end

  private

  def buscar(**params)
    LivrosQuery.new(ActionController::Parameters.new(params)).call.map(&:id)
  end
end
