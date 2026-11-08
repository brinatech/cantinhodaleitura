class HistoricoLeitura < ApplicationRecord
  belongs_to :usuario
  belongs_to :livro
end
