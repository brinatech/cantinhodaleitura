class CreateListaLeituraLivros < ActiveRecord::Migration[8.1]
  def change
    create_table :lista_leitura_livros do |t|
      t.references :lista_leitura, null: false, foreign_key: { to_table: :lista_leituras }
      t.references :livro, null: false, foreign_key: { to_table: :livros }

      t.timestamps

      t.index [ :lista_leitura_id, :livro_id ], unique: true
    end
  end
end
