class Classificacao < ApplicationRecord
  validates :livro, presence: true

  belongs_to :livro
end
