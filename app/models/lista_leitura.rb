class ListaLeitura < ApplicationRecord
  belongs_to :usuario
  has_many :lista_leitura_livros
  has_many :livros, through: :lista_leitura_livros
end
