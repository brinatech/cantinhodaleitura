# HU-20 (versão proposta): apaga os cadastros de menores que o responsável não confirmou em 7 dias.
# A conta nunca entrou, então não há favoritos, histórico ou acessos ligados a ela: apagar é seguro.
# Agendado uma vez por dia em config/recurring.yml (Solid Queue, em produção).
class LimparCadastrosMenoresPendentesJob < ApplicationJob
  queue_as :default

  def perform
    Usuario.menores_pendentes_vencidos.find_each(&:destroy!)
  end
end
