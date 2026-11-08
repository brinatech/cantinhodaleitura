class HistoricoLeitura < ApplicationRecord
  validates :usuario, :livro, presence: true
  validates :progresso_percentual,
            numericality: { in: 0..100 },
            allow_nil: true

  belongs_to :usuario
  belongs_to :livro
end
