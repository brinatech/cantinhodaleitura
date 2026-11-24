# Histórico de leitura (HU-14): um registro consolidado por pessoa e livro.
# data_inicio: a primeira vez que abriu. data_ultima_leitura: a vez mais recente.
# progresso_percentual: quanto já leu (0 a 100). Quem preenche é o RegistrarLeitura.
class HistoricoLeitura < ApplicationRecord
  validates :usuario, :livro, presence: true
  # Um registro por pessoa e livro (o banco também garante, com índice único)
  validates :livro_id, uniqueness: { scope: :usuario_id }
  validates :progresso_percentual,
            numericality: { in: 0..100 },
            allow_nil: true
  validate :datas_coerentes

  belongs_to :usuario
  belongs_to :livro

  private

  # A última leitura não pode ser antes do início
  def datas_coerentes
    return unless data_inicio && data_ultima_leitura && data_ultima_leitura < data_inicio

    errors.add(:data_ultima_leitura, "não pode ser antes do início da leitura")
  end
end
