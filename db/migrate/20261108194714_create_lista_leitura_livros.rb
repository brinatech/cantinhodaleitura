class CreateListaLeituraLivros < ActiveRecord::Migration[8.1]
  def change
    create_table :lista_leitura_livros do |t|
      t.references :lista_leitura, null: false, foreign_key: true
      t.references :livro, null: false, foreign_key: true

      t.timestamps

      t.index [ :lista_leitura_id, :livro_id ], unique: true
    end
  end
end
