class CreateFavoritos < ActiveRecord::Migration[8.1]
  def change
    create_table :favoritos do |t|
      t.references :usuario, null: false, foreign_key: { to_table: :usuarios }
      t.references :livro, null: false, foreign_key: { to_table: :livros }
      t.datetime :data_favorito

      t.index [ :usuario_id, :livro_id ], unique: true
      t.timestamps
    end
  end
end
