class CreateListaLeituras < ActiveRecord::Migration[8.1]
  def change
    create_table :lista_leituras do |t|
      t.references :usuario, null: false, foreign_key: true
      t.string :nome, limit: 100, null: false
      t.text :descricao
      t.datetime :data_criacao

      t.timestamps
    end
  end
end
