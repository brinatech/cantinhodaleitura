require "test_helper"

class Relatorios::BibliotecaQueryTest < ActiveSupport::TestCase
  BRASILIA = ActiveSupport::TimeZone["America/Sao_Paulo"]

  setup do
    # Começa do zero: os fixtures têm acessos e livros com datas de outubro/novembro
    AcessoMaterial.delete_all
    @admin = usuarios(:one)
    @categoria = categorias(:one)
    @leitor = Usuario.create!(nome: "Leitora", email: "leitora-relatorio@example.com", password: "password123", tipo_usuario: "leitor",
                              created_at: BRASILIA.local(2026, 9, 1))

    @tunel = criar_livro("O túnel", BRASILIA.local(2026, 9, 15))
    @barco = criar_livro("O barco", BRASILIA.local(2026, 10, 5))
    @lua = criar_livro("A lua", BRASILIA.local(2026, 10, 20))
  end

  def criar_livro(titulo, quando)
    Livro.create!(titulo: titulo, categoria: @categoria, usuario_cadastro: @admin, created_at: quando)
  end

  def acesso(livro, tipo, quando, usuario: nil)
    AcessoMaterial.create!(livro: livro, tipo_acesso: tipo, usuario: usuario, data_acesso: quando)
  end

  def relatorio(inicio = Date.new(2026, 10, 1), fim = Date.new(2026, 10, 31))
    Relatorios::BibliotecaQuery.new(inicio: inicio, fim: fim).call
  end

  test "livros: total até o fim do período, novos no período e por mês" do
    outubro = relatorio[:livros]

    assert_equal Livro.where(created_at: ..BRASILIA.local(2026, 10, 31).end_of_day).count, outubro[:total]
    assert_equal 2, outubro[:novos_no_periodo] # barco e lua
    assert_equal [ { mes: "2026-10", total: 2 } ], outubro[:por_mes]

    set_out = relatorio(Date.new(2026, 9, 1), Date.new(2026, 10, 31))[:livros][:por_mes]
    assert_equal [ { mes: "2026-09", total: 1 }, { mes: "2026-10", total: 2 } ], set_out
  end

  test "acessos por tipo no período, com leitores e visitantes separados" do
    acesso(@tunel, "leitura", BRASILIA.local(2026, 10, 2, 10), usuario: @leitor)
    acesso(@tunel, "leitura", BRASILIA.local(2026, 10, 3, 10))
    acesso(@barco, "leitura", BRASILIA.local(2026, 10, 4, 10))
    acesso(@tunel, "visualizacao", BRASILIA.local(2026, 10, 2, 9), usuario: @leitor)
    acesso(@tunel, "leitura", BRASILIA.local(2026, 11, 1, 10)) # fora do período

    acessos = relatorio[:acessos]

    assert_equal({ total: 3, leitores: 1, visitantes: 2 }, acessos["leitura"])
    assert_equal({ total: 1, leitores: 1, visitantes: 0 }, acessos["visualizacao"])
    assert_equal({ total: 0, leitores: 0, visitantes: 0 }, acessos["download"])
  end

  test "o dia é o de Brasília: 23h do dia 31 ainda é outubro" do
    acesso(@tunel, "leitura", BRASILIA.local(2026, 10, 31, 23, 30)) # já é 1º de novembro em UTC
    acesso(@tunel, "leitura", BRASILIA.local(2026, 9, 30, 23, 30))  # ainda é setembro em Brasília

    assert_equal 1, relatorio[:acessos]["leitura"][:total]
  end

  test "mais acessados: mais leituras primeiro, com o título e as contagens" do
    2.times { acesso(@barco, "leitura", BRASILIA.local(2026, 10, 10)) }
    acesso(@tunel, "leitura", BRASILIA.local(2026, 10, 10))
    3.times { acesso(@tunel, "visualizacao", BRASILIA.local(2026, 10, 10)) }
    acesso(@lua, "download", BRASILIA.local(2026, 10, 10))

    ranking = relatorio[:mais_acessados]

    assert_equal [ "O barco", "O túnel", "A lua" ], ranking.map { |linha| linha[:titulo] }
    assert_equal({ livro_id: @tunel.id, titulo: "O túnel", leituras: 1, visualizacoes: 3, downloads: 0, total: 4 }, ranking[1])
  end

  test "leitores cadastrados conta só leitores criados até o fim do período" do
    Usuario.create!(nome: "Nova", email: "nova-relatorio@example.com", password: "password123", tipo_usuario: "leitor",
                    created_at: BRASILIA.local(2026, 11, 5))

    esperado = Usuario.where(tipo_usuario: "leitor").where(created_at: ..BRASILIA.local(2026, 10, 31).end_of_day).count
    assert_equal esperado, relatorio[:leitores_cadastrados]
    assert_includes Usuario.where(created_at: ..BRASILIA.local(2026, 10, 31).end_of_day), @leitor
  end

  test "dados_desde é o dia do primeiro acesso gravado (ou nil)" do
    assert_nil relatorio[:dados_desde]

    acesso(@tunel, "leitura", BRASILIA.local(2026, 10, 7, 23, 50))
    assert_equal "2026-10-07", relatorio[:dados_desde]
  end

  test "não devolve dados pessoais" do
    acesso(@tunel, "leitura", BRASILIA.local(2026, 10, 2), usuario: @leitor)

    texto = relatorio.to_json
    assert_not_includes texto, @leitor.email
    assert_not_includes texto, @leitor.nome
  end
end
