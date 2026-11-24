class Classificacao < ApplicationRecord
  self.table_name = "classificacaos"

  TIPOS = %w[genero faixa_etaria formato acessibilidade].freeze

  # Recursos de acessibilidade que um livro pode declarar (HU-17). Decisão da equipe, sem validação da SESFA:
  # docs/decisoes-negocio/recursos_acessibilidade.md. Se mudar aqui, mude em services/tiposClassificacao.js.
  RECURSOS_ACESSIBILIDADE = [
    "Leitura em voz alta",
    "Audiodescrição",
    "Libras",
    "Legendas",
    "Texto alternativo em imagens",
    "Alto contraste"
  ].freeze

  belongs_to :livro

  validates :tipo, inclusion: { in: TIPOS }
  validates :nome, presence: true, length: { maximum: 100 }
  # Lista fechada só para "acessibilidade"; classificações antigas com outro nome continuam legíveis (só valida ao salvar)
  validates :nome, inclusion: { in: RECURSOS_ACESSIBILIDADE }, if: -> { tipo == "acessibilidade" && nome.present? }
end
