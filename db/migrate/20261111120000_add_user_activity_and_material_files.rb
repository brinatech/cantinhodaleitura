class AddUserActivityAndMaterialFiles < ActiveRecord::Migration[8.1]
  def up
    add_column :usuarios, :ativo, :boolean, default: true, null: false
    add_column :usuarios, :ultimo_acesso_em, :datetime
    change_column_default :usuarios, :tipo_usuario, from: nil, to: "leitor"

    execute <<~SQL
      UPDATE usuarios
      SET tipo_usuario = 'leitor'
      WHERE tipo_usuario IS NULL OR BTRIM(tipo_usuario) = ''
    SQL

    change_column_null :usuarios, :tipo_usuario, false
    add_column :livros, :capa_url, :string, limit: 255

    create_table :arquivo_materials do |t|
      t.references :livro, null: false, foreign_key: { to_table: :livros }
      t.string :tipo, limit: 20, null: false
      t.string :caminho, limit: 255, null: false
      t.timestamps
    end

    add_index :arquivo_materials, [ :livro_id, :tipo ], unique: true
  end

  def down
    drop_table :arquivo_materials
    remove_column :livros, :capa_url
    change_column_null :usuarios, :tipo_usuario, true
    change_column_default :usuarios, :tipo_usuario, from: "leitor", to: nil
    remove_column :usuarios, :ultimo_acesso_em
    remove_column :usuarios, :ativo
  end
end