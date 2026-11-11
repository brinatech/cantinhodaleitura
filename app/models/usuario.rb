class Usuario < ApplicationRecord
  has_secure_password

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :nome, :email, presence: true
  validates :email,
            format: { with: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/ },
            uniqueness: { case_sensitive: false }
  validates :tipo_usuario, inclusion: { in: %w[leitor administrador] }

  has_many :livros_cadastrados,
           class_name: "Livro",
           foreign_key: :usuario_cadastro_id
  has_many :acesso_materials
  has_many :favoritos
  has_many :lista_leituras
  has_many :historico_leituras
  has_many :marcador_paginas

  def serializable_hash(options = nil)
    options = (options || {}).dup
    options[:except] = Array(options[:except]) | [ "password_digest" ]
    super(options)
  end
end
