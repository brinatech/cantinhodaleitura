# Indicadores da biblioteca para o painel de relatórios (HU-22 Task 2).
# Tudo calculado na hora com COUNT/GROUP BY; nenhum dado pessoal sai daqui (só números e títulos).
# Definições em docs/relatorios/definicao_indicadores.md.
module Relatorios
  class BibliotecaQuery
    FUSO = "America/Sao_Paulo" # os dias e meses do relatório são os de Brasília
    MAIS_ACESSADOS = 10
    # O mês do created_at em Brasília (as datas ficam gravadas em UTC). SQL fixo, sem nada do usuário.
    MES_DE_CADASTRO = Arel.sql("to_char((livros.created_at AT TIME ZONE 'UTC') AT TIME ZONE '#{FUSO}', 'YYYY-MM')")

    # inicio e fim: Date (inclusivos)
    def initialize(inicio:, fim:)
      @inicio = inicio
      @fim = fim
    end

    def call
      {
        periodo: { inicio: @inicio.iso8601, fim: @fim.iso8601 },
        dados_desde: primeiro_acesso,
        livros: livros,
        leitores_cadastrados: leitores_cadastrados,
        leitores_ativos: leitores_ativos,
        acessos: acessos,
        mais_acessados: mais_acessados
      }
    end

    private

    def fuso = ActiveSupport::TimeZone[FUSO]
    def inicio_do_periodo = fuso.local(@inicio.year, @inicio.month, @inicio.day)
    def fim_do_periodo = fuso.local(@fim.year, @fim.month, @fim.day).end_of_day
    def periodo = inicio_do_periodo..fim_do_periodo

    def livros
      {
        total: Livro.where(created_at: ..fim_do_periodo).count,
        novos_no_periodo: Livro.where(created_at: periodo).count,
        por_mes: Livro.where(created_at: periodo).group(MES_DE_CADASTRO).order(MES_DE_CADASTRO).count
                      .map { |mes, total| { mes: mes, total: total } }
      }
    end

    # Leitores com conta no fim do período. Conta excluída pelo próprio usuário (HU-21) deixa de contar
    # a partir da data da exclusão; em períodos anteriores a ela, continua contando.
    def leitores_cadastrados
      Usuario.where(tipo_usuario: "leitor", created_at: ..fim_do_periodo)
             .where("usuarios.excluido_em IS NULL OR usuarios.excluido_em > ?", fim_do_periodo)
             .count
    end

    # Leitores ativos (proposta da equipe, opção "b" da definição): leitores DIFERENTES com pelo menos um
    # acesso no período (abriu a página de um livro, leu/ouviu ou baixou). Quem acessou 10 vezes conta 1.
    # Só número: nenhum nome sai daqui. Visitantes e administradores não entram.
    def leitores_ativos
      AcessoMaterial.where(data_acesso: periodo)
                    .joins(:usuario)
                    .where(usuarios: { tipo_usuario: "leitor" })
                    .distinct
                    .count(:usuario_id)
    end

    # { "leitura" => { total:, leitores:, visitantes: }, ... }, com zero para o tipo sem acessos
    def acessos
      contagem = AcessoMaterial.where(data_acesso: periodo)
                               .group(:tipo_acesso, Arel.sql("acesso_materials.usuario_id IS NULL"))
                               .count

      AcessoMaterial::TIPOS.index_with do |tipo|
        visitantes = contagem[[ tipo, true ]] || 0
        leitores = contagem[[ tipo, false ]] || 0
        { total: leitores + visitantes, leitores: leitores, visitantes: visitantes }
      end
    end

    # Os livros com mais leituras no período (empate: mais acessos no total)
    def mais_acessados
      linhas = AcessoMaterial.where(data_acesso: periodo)
                             .joins(:livro)
                             .group("livros.id", "livros.titulo")
                             .select(
                               "livros.id AS livro_id", "livros.titulo AS titulo",
                               "COUNT(*) FILTER (WHERE tipo_acesso = 'leitura') AS leituras",
                               "COUNT(*) FILTER (WHERE tipo_acesso = 'visualizacao') AS visualizacoes",
                               "COUNT(*) FILTER (WHERE tipo_acesso = 'download') AS downloads",
                               "COUNT(*) AS total"
                             )
                             .order(Arel.sql("leituras DESC, total DESC, livros.titulo ASC"))
                             .limit(MAIS_ACESSADOS)

      linhas.map do |linha|
        linha.attributes.slice("livro_id", "titulo", "leituras", "visualizacoes", "downloads", "total").symbolize_keys
      end
    end

    def primeiro_acesso
      AcessoMaterial.minimum(:data_acesso)&.in_time_zone(fuso)&.to_date&.iso8601
    end
  end
end
