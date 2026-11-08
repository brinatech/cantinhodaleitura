class Categoria < ApplicationRecord
  validates :nome, presence: true, uniqueness: true

  has_many :livros
end
