class CreateHistoricoLeituras < ActiveRecord::Migration[8.1]
  def change
    create_table :historico_leituras do |t|
      t.references :usuario, null: false, foreign_key: true
      t.references :livro, null: false, foreign_key: true
      t.datetime :data_inicio
      t.datetime :data_ultima_leitura
      t.decimal :progresso_percentual, precision: 5, scale: 2

      t.timestamps
    end
  end
end
