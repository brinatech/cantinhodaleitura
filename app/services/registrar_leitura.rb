# Registra que alguém leu um livro (HU-14 Task 2). Usado pelo leitor ao abrir o livro e ao trocar de página.
# - Primeira vez: cria o histórico com data_inicio.
# - Vezes seguintes: atualiza data_ultima_leitura no mesmo registro (sem duplicar).
# - Progresso: página / total de páginas. Só aumenta: reler o começo não apaga o quanto já leu.
# Devolve o histórico (com errors preenchidos se não salvou). Visitante não chega aqui (o controller exige login).
class RegistrarLeitura
  def self.call(...) = new(...).call

  def initialize(usuario:, livro:, pagina: nil, total_paginas: nil)
    @usuario = usuario
    @livro = livro
    @pagina = pagina
    @total_paginas = total_paginas
  end

  def call
    tentou_de_novo = false
    begin
      historico = @usuario.historico_leituras.find_or_initialize_by(livro: @livro)
      agora = Time.current
      historico.data_inicio ||= agora
      historico.data_ultima_leitura = agora
      historico.progresso_percentual = progresso_novo(historico.progresso_percentual)
      historico.save
      historico
    rescue ActiveRecord::RecordNotUnique
      # Dois pedidos quase juntos criando o primeiro registro: o segundo tenta de novo e só atualiza
      raise if tentou_de_novo

      tentou_de_novo = true
      retry
    end
  end

  private

  def progresso_novo(anterior)
    anterior ||= 0
    return anterior unless @pagina && @total_paginas&.positive?

    atual = (BigDecimal(@pagina) / @total_paginas * 100).round(2)
    [ anterior, atual ].max
  end
end
