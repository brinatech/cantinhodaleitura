class CreateUsuarios < ActiveRecord::Migration[8.1]
  def change
    create_table :usuarios do |t|
      t.string :nome, limit: 100
      t.string :email, limit: 150
      t.string :password_digest, limit: 255
      t.string :tipo_usuario, limit: 20
      t.datetime :data_cadastro

      t.index :email, unique: true
      t.timestamps
    end
  end
end
