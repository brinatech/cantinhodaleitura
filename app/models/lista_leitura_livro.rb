class ListaLeituraLivro < ApplicationRecord
  belongs_to :lista_leitura
  belongs_to :livro
end
