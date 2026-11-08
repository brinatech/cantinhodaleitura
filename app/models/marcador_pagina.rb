class MarcadorPagina < ApplicationRecord
  validates :usuario, :livro, presence: true
  validates :livro_id, uniqueness: { scope: :usuario_id }

  belongs_to :usuario
  belongs_to :livro
end
