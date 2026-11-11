class MoveBookFileToMaterialFiles < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      INSERT INTO arquivo_materials (livro_id, tipo, caminho, created_at, updated_at)
      SELECT id, 'texto', caminho_arquivo, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM livros
      WHERE caminho_arquivo IS NOT NULL
        AND BTRIM(caminho_arquivo) <> ''
    SQL

    remove_column :livros, :caminho_arquivo
  end

  def down
    add_column :livros, :caminho_arquivo, :string, limit: 255

    execute <<~SQL
      UPDATE livros
      SET caminho_arquivo = arquivo_materials.caminho
      FROM arquivo_materials
      WHERE livros.id = arquivo_materials.livro_id
        AND arquivo_materials.tipo = 'texto'
    SQL
  end
end