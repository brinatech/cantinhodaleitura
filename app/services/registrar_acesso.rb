# Grava um uso de livro (HU-10 Task 3). Chamado só depois que a ação foi permitida
# (o livro/arquivo existe e a pessoa pode usar).
#
# Sem repetir a mesma coisa várias vezes: a mesma pessoa (ou o mesmo navegador, no caso do visitante)
# abrindo o mesmo livro do mesmo jeito dentro de JANELA conta uma vez só. Isso evita que:
# - o leitor com PDF e audiobook conte 2 leituras (um pedido para cada arquivo);
# - o player de áudio, que pede um link novo a cada 5 minutos, conte uma leitura a cada renovação;
# - recarregar a página do livro (F5) conte várias visualizações.
# A memória do "já contei" fica na sessão (cookie), que existe também para o visitante.
#
# Nunca atrapalha a leitura: se não conseguir gravar, só anota no log.
class RegistrarAcesso
  JANELA = 30.minutes

  def self.call(...) = new(...).call

  def initialize(livro:, tipo:, usuario: nil, sessao: {})
    @livro = livro
    @tipo = tipo
    @usuario = usuario
    @sessao = sessao
  end

  def call
    return if contado_ha_pouco?

    acesso = AcessoMaterial.create(livro: @livro, usuario: @usuario, tipo_acesso: @tipo)
    lembrar if acesso.persisted?
    acesso
  rescue ActiveRecord::ActiveRecordError => falha
    Rails.logger.warn("Não foi possível registrar o acesso (livro #{@livro&.id}, #{@tipo}): #{falha.message}")
    nil
  end

  private

  def chave = "#{@livro.id}-#{@tipo}"

  def recentes
    @sessao[:acessos_recentes] || {}
  end

  def contado_ha_pouco?
    momento = recentes[chave]
    momento.present? && momento.to_i > JANELA.ago.to_i
  end

  # Guarda só os da última meia hora (o cookie da sessão não pode crescer sem limite).
  # Atribui um hash novo para a sessão perceber a mudança e gravar.
  def lembrar
    limite = JANELA.ago.to_i
    @sessao[:acessos_recentes] = recentes.select { |_chave, momento| momento.to_i > limite }.merge(chave => Time.current.to_i)
  end
end
