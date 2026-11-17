class Classificacao < ApplicationRecord
  self.table_name = "classificacaos"

  TIPOS = %w[genero faixa_etaria formato acessibilidade].freeze

  belongs_to :livro

  validates :tipo, inclusion: { in: TIPOS }
  validates :nome, presence: true, length: { maximum: 100 }
end
