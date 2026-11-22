# Onde a pessoa parou num livro (HU-15). Um marcador por pessoa e livro: salvar de novo atualiza o mesmo.
# pagina_atual: página do PDF. localizacao: posição técnica opcional (ex.: o segundo do áudio, no futuro).
class MarcadorPagina < ApplicationRecord
  validates :usuario, :livro, presence: true
  # Um marcador por pessoa e livro (o banco também garante, com índice único)
  validates :livro_id, uniqueness: { scope: :usuario_id }
  validates :pagina_atual, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :localizacao, length: { maximum: 255 }
  validate :posicao_informada

  belongs_to :usuario
  belongs_to :livro

  # A data muda sozinha quando a posição muda (nunca vem do navegador)
  before_save :atualizar_data, if: -> { new_record? || will_save_change_to_pagina_atual? || will_save_change_to_localizacao? }

  private

  # Marcador sem página e sem localização não marca nada
  def posicao_informada
    return if pagina_atual.present? || localizacao.present?

    errors.add(:base, "Informe a página ou a localização")
  end

  def atualizar_data
    self.data_atualizacao = Time.current
  end
end
