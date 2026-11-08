class CreateCategorias < ActiveRecord::Migration[8.1]
  def change
    create_table :categorias do |t|
      t.string :nome, limit: 100, null: false
      t.text :descricao

      t.index :nome, unique: true
      t.timestamps
    end
  end
end
