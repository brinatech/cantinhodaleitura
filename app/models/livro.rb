class Livro < ApplicationRecord
  belongs_to :categoria
  belongs_to :usuario_cadastro
end
