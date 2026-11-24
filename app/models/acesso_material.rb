# Cada uso de um livro (HU-10 Task 3): abrir a página, abrir para ler/ouvir ou baixar.
# Serve para os relatórios (HU-22) e para os "Livros em destaque" da home (os mais lidos).
# Visitante também conta: o acesso fica sem usuário (usuario_id nulo).
class AcessoMaterial < ApplicationRecord
  TIPOS = %w[visualizacao leitura download].freeze

  validates :livro, presence: true
  validates :tipo_acesso, inclusion: { in: TIPOS }

  belongs_to :livro
  belongs_to :usuario, optional: true

  # A data do acesso: preenchida sozinha, nunca vem do navegador
  before_validation { self.data_acesso ||= Time.current }
end
