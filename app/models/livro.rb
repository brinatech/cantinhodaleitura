class Livro < ApplicationRecord
  validates :categoria, :usuario_cadastro, presence: true

  belongs_to :categoria
  belongs_to :usuario_cadastro,
             class_name: "Usuario",
             foreign_key: :usuario_cadastro_id
  has_many :acesso_materials
  has_many :favoritos
  has_many :historico_leituras
  has_many :marcador_paginas
  has_many :classificacoes
  has_many :lista_leitura_livros
  has_many :lista_leituras, through: :lista_leitura_livros
end
