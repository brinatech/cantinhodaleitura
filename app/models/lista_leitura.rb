class ListaLeitura < ApplicationRecord
  validates :usuario, :nome, presence: true
  validates :nome, length: { maximum: 100 }

  belongs_to :usuario
  has_many :lista_leitura_livros
  has_many :livros, through: :lista_leitura_livros
end
