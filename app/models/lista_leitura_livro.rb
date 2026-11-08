class ListaLeituraLivro < ApplicationRecord
  validates :lista_leitura, :livro, presence: true
  validates :livro_id, uniqueness: { scope: :lista_leitura_id }

  belongs_to :lista_leitura
  belongs_to :livro
end
