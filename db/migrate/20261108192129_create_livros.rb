class CreateLivros < ActiveRecord::Migration[8.1]
  def change
    create_table :livros do |t|
      t.string :titulo, limit: 200
      t.string :autor, limit: 150
      t.text :descricao
      t.string :caminho_arquivo, limit: 255
      t.references :categoria, null: false, foreign_key: true
      t.references :usuario_cadastro,
                   null: false,
                   foreign_key: { to_table: :usuarios }

      t.timestamps
    end
  end
end
