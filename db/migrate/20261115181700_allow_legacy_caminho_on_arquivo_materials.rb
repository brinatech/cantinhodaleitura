class AllowLegacyCaminhoOnArquivoMaterials < ActiveRecord::Migration[8.1]
  def change
    change_column_null :arquivo_materials, :caminho, true
  end
end
