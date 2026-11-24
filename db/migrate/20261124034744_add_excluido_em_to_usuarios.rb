# HU-21: quando o próprio usuário exclui a conta, ela é anonimizada (não apagada) e fica marcada aqui.
# Nulo = conta normal. Preenchido = conta excluída: não entra, não volta a ser ativada e não conta nos relatórios.
class AddExcluidoEmToUsuarios < ActiveRecord::Migration[8.1]
  def change
    add_column :usuarios, :excluido_em, :datetime
  end
end
