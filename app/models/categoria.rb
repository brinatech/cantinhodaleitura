class Categoria < ApplicationRecord
  self.table_name = "categorias"

  normalizes :nome, with: ->(nome) { nome.squish }

  validates :nome, presence: true,
                   length: { maximum: 100 },
                   uniqueness: { case_sensitive: false }

  has_many :livros, dependent: :restrict_with_error
end
