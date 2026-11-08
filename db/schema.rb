# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_08_194714) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "acesso_materials", force: :cascade do |t|
    t.bigint "livro_id", null: false
    t.bigint "usuario_id"
    t.string "tipo_acesso", limit: 30
    t.datetime "data_acesso"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["livro_id"], name: "index_acesso_materials_on_livro_id"
    t.index ["usuario_id"], name: "index_acesso_materials_on_usuario_id"
  end

  create_table "categorias", force: :cascade do |t|
    t.string "nome", limit: 100, null: false
    t.text "descricao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_categorias_on_nome", unique: true
  end

  create_table "classificacaos", force: :cascade do |t|
    t.bigint "livro_id", null: false
    t.string "tipo", limit: 30
    t.string "nome", limit: 100
    t.text "descricao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["livro_id"], name: "index_classificacaos_on_livro_id"
  end

  create_table "favoritos", force: :cascade do |t|
    t.bigint "usuario_id", null: false
    t.bigint "livro_id", null: false
    t.datetime "data_favorito"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["livro_id"], name: "index_favoritos_on_livro_id"
    t.index ["usuario_id", "livro_id"], name: "index_favoritos_on_usuario_id_and_livro_id", unique: true
    t.index ["usuario_id"], name: "index_favoritos_on_usuario_id"
  end

  create_table "historico_leituras", force: :cascade do |t|
    t.bigint "usuario_id", null: false
    t.bigint "livro_id", null: false
    t.datetime "data_inicio"
    t.datetime "data_ultima_leitura"
    t.decimal "progresso_percentual", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["livro_id"], name: "index_historico_leituras_on_livro_id"
    t.index ["usuario_id"], name: "index_historico_leituras_on_usuario_id"
  end

  create_table "lista_leitura_livros", force: :cascade do |t|
    t.bigint "lista_leitura_id", null: false
    t.bigint "livro_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lista_leitura_id", "livro_id"], name: "index_lista_leitura_livros_on_lista_leitura_id_and_livro_id", unique: true
    t.index ["lista_leitura_id"], name: "index_lista_leitura_livros_on_lista_leitura_id"
    t.index ["livro_id"], name: "index_lista_leitura_livros_on_livro_id"
  end

  create_table "lista_leituras", force: :cascade do |t|
    t.bigint "usuario_id", null: false
    t.string "nome", limit: 100, null: false
    t.text "descricao"
    t.datetime "data_criacao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["usuario_id"], name: "index_lista_leituras_on_usuario_id"
  end

  create_table "livros", force: :cascade do |t|
    t.string "titulo", limit: 200
    t.string "autor", limit: 150
    t.text "descricao"
    t.string "caminho_arquivo", limit: 255
    t.bigint "categoria_id", null: false
    t.bigint "usuario_cadastro_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["categoria_id"], name: "index_livros_on_categoria_id"
    t.index ["usuario_cadastro_id"], name: "index_livros_on_usuario_cadastro_id"
  end

  create_table "marcador_paginas", force: :cascade do |t|
    t.bigint "usuario_id", null: false
    t.bigint "livro_id", null: false
    t.integer "pagina_atual"
    t.string "localizacao", limit: 255
    t.datetime "data_atualizacao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["livro_id"], name: "index_marcador_paginas_on_livro_id"
    t.index ["usuario_id", "livro_id"], name: "index_marcador_paginas_on_usuario_id_and_livro_id", unique: true
    t.index ["usuario_id"], name: "index_marcador_paginas_on_usuario_id"
  end

  create_table "usuarios", force: :cascade do |t|
    t.string "nome", limit: 100
    t.string "email", limit: 150
    t.string "password_digest", limit: 255
    t.string "tipo_usuario", limit: 20
    t.datetime "data_cadastro"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_usuarios_on_email", unique: true
  end

  add_foreign_key "acesso_materials", "livros"
  add_foreign_key "acesso_materials", "usuarios"
  add_foreign_key "classificacaos", "livros"
  add_foreign_key "favoritos", "livros"
  add_foreign_key "favoritos", "usuarios"
  add_foreign_key "historico_leituras", "livros"
  add_foreign_key "historico_leituras", "usuarios"
  add_foreign_key "lista_leitura_livros", "lista_leituras"
  add_foreign_key "lista_leitura_livros", "livros"
  add_foreign_key "lista_leituras", "usuarios"
  add_foreign_key "livros", "categorias"
  add_foreign_key "livros", "usuarios", column: "usuario_cadastro_id"
  add_foreign_key "marcador_paginas", "livros"
  add_foreign_key "marcador_paginas", "usuarios"
end
