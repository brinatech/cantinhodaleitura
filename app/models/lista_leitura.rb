# Lista de leitura de um leitor (HU-13): uma "prateleira" com nome, descrição e vários livros.
# Cada lista tem um dono só; o mesmo livro pode estar em várias listas, mas não repetido na mesma.
class ListaLeitura < ApplicationRecord
  normalizes :nome, with: ->(nome) { nome.strip }

  validates :usuario, :nome, presence: true
  validates :nome, length: { maximum: 100 }

  belongs_to :usuario
  # Apagar a lista tira os livros dela (os livros continuam no acervo)
  has_many :lista_leitura_livros, dependent: :destroy
  has_many :livros, through: :lista_leitura_livros

  # O dia em que a lista foi criada: preenchido sozinho, nunca vem do navegador
  before_validation { self.data_criacao ||= Time.current }
end
