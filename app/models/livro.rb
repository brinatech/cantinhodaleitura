class Livro < ApplicationRecord
  validates :titulo, :categoria, :usuario_cadastro, presence: true

  belongs_to :categoria
  belongs_to :usuario_cadastro,
             class_name: "Usuario",
             foreign_key: :usuario_cadastro_id
  has_many :arquivos,
           class_name: "ArquivoMaterial",
           dependent: :destroy
  has_many :acesso_materials, dependent: :restrict_with_error
  has_many :favoritos, dependent: :restrict_with_error
  has_many :historico_leituras, dependent: :restrict_with_error
  has_many :marcador_paginas, dependent: :restrict_with_error
  has_many :classificacoes,
           class_name: "Classificacao",
           dependent: :restrict_with_error
  has_many :lista_leitura_livros, dependent: :restrict_with_error
  has_many :lista_leituras, through: :lista_leitura_livros
end
