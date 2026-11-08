class CreateAcessoMaterials < ActiveRecord::Migration[8.1]
  def change
    create_table :acesso_materials do |t|
      t.references :livro, null: false, foreign_key: true
      t.references :usuario, foreign_key: true
      t.string :tipo_acesso, limit: 30
      t.datetime :data_acesso

      t.timestamps
    end
  end
end
