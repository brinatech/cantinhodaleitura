class Favorito < ApplicationRecord
  validates :usuario, :livro, presence: true
  # O mesmo livro não entra duas vezes nos favoritos da mesma pessoa (o banco também garante, com índice único)
  validates :livro_id, uniqueness: { scope: :usuario_id }

  belongs_to :usuario
  belongs_to :livro

  # O dia em que a pessoa favoritou: preenchido sozinho, nunca vem do navegador
  before_validation { self.data_favorito ||= Time.current }
end
