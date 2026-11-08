class AcessoMaterial < ApplicationRecord
  validates :livro, presence: true

  belongs_to :livro
  belongs_to :usuario
end
