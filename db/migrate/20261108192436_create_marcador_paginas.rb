class CreateMarcadorPaginas < ActiveRecord::Migration[8.1]
  def change
    create_table :marcador_paginas do |t|
      t.references :usuario, null: false, foreign_key: { to_table: :usuarios }
      t.references :livro, null: false, foreign_key: { to_table: :livros }
      t.integer :pagina_atual
      t.string :localizacao, limit: 255
      t.datetime :data_atualizacao

      t.index [ :usuario_id, :livro_id ], unique: true
      t.timestamps
    end
  end
end
