class CreateClassificacaos < ActiveRecord::Migration[8.1]
  def change
    create_table :classificacaos do |t|
      t.references :livro, null: false, foreign_key: true
      t.string :tipo, limit: 30
      t.string :nome, limit: 100
      t.text :descricao

      t.timestamps
    end
  end
end
