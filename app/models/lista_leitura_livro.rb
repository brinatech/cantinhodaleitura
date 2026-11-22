# Um livro dentro de uma lista de leitura (HU-13, tabela de junção).
class ListaLeituraLivro < ApplicationRecord
  validates :lista_leitura, :livro, presence: true
  # O mesmo livro não entra duas vezes na mesma lista (o banco também garante, com índice único)
  validates :livro_id, uniqueness: { scope: :lista_leitura_id }

  # touch: pôr ou tirar um livro conta como mexer na lista (ela sobe para o topo de "Minhas listas")
  belongs_to :lista_leitura, touch: true
  belongs_to :livro
end
