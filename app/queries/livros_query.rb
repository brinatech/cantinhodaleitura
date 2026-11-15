# Busca e filtros do catálogo (GET /api/v1/livros). Todo valor vem do usuário e entra
# no SQL só por bind parameter ou por hash do ActiveRecord; a ordenação usa lista fixa.
class LivrosQuery
  ORDENACOES = {
    "titulo" => { titulo: :asc },
    "recentes" => { created_at: :desc }
  }.freeze

  def initialize(params)
    @params = params
  end

  def call
    livros = Livro.all
    livros = livros.where("livros.titulo ILIKE :q OR livros.autor ILIKE :q", q: "%#{Livro.sanitize_sql_like(valor(:q))}%") if valor(:q)
    livros = livros.where(categoria_id: valor(:categoria_id)) if valor(:categoria_id)
    livros = livros.where(id: Classificacao.where(classificacao_filtro).select(:livro_id)) if classificacao_filtro.any?
    livros = livros.where(id: ArquivoMaterial.where(tipo: valor(:formato)).select(:livro_id)) if valor(:formato)
    livros = livros.order(ORDENACOES[valor(:ordem)]) if ORDENACOES.key?(valor(:ordem))
    livros
  end

  private

  # Sempre texto: um parâmetro enviado como lista ou objeto não quebra a consulta
  def valor(chave)
    @params[chave].to_s.strip.presence
  end

  def classificacao_filtro
    { tipo: valor(:tipo_classificacao), nome: valor(:classificacao) }.compact
  end
end
