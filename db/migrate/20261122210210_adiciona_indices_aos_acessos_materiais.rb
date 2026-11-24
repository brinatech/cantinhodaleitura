# HU-10 Task 3: os relatórios (HU-22) e os "mais lidos" filtram e contam os acessos por data e por tipo.
# O índice de livro_id já existe (veio do references).
class AdicionaIndicesAosAcessosMateriais < ActiveRecord::Migration[8.1]
  def change
    add_index :acesso_materials, :data_acesso
    add_index :acesso_materials, [ :tipo_acesso, :livro_id ]
  end
end
