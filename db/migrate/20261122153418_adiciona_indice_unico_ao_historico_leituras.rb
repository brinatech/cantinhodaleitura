# HU-14: o histórico é consolidado, um registro por pessoa e livro (guarda o início,
# a última leitura e o progresso). O índice único garante isso mesmo com dois pedidos juntos.
class AdicionaIndiceUnicoAoHistoricoLeituras < ActiveRecord::Migration[8.1]
  def change
    add_index :historico_leituras, [ :usuario_id, :livro_id ], unique: true
  end
end
