class ArquivoMaterial < ApplicationRecord
  TIPOS = %w[texto audio].freeze

  belongs_to :livro

  validates :tipo, inclusion: { in: TIPOS }
  validates :caminho, presence: true
end