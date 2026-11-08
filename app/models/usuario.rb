class Usuario < ApplicationRecord
  validates :email,
            format: { with: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/ },
            uniqueness: true,
            allow_blank: true

  has_many :livros_cadastrados,
           class_name: "Livro",
           foreign_key: :usuario_cadastro_id
  has_many :acesso_materials
  has_many :favoritos
  has_many :lista_leituras
  has_many :historico_leituras
  has_many :marcador_paginas
end
