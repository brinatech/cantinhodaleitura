class Livro < ApplicationRecord
  # Capa enviada pelo admin (Active Storage). A coluna antiga capa_url (texto) continua
  # valendo para livros que só têm um link de imagem.
  CAPA_TIPOS_PERMITIDOS = %w[image/jpeg image/png image/webp].freeze
  CAPA_TAMANHO_MAXIMO = 5.megabytes

  has_one_attached :capa
  validate :capa_dentro_dos_limites

  # Validações para garantir que os campos obrigatórios estejam presentes
  # titulo: título do livro
  # categoria: categoria associada ao livro
  # usuario_cadastro: usuário que cadastrou o livro
  validates :titulo, :categoria, :usuario_cadastro, presence: true
  # Associações do modelo Livro

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

  private

  def capa_dentro_dos_limites
    return unless capa.attached?

    errors.add(:capa, "deve ser uma imagem JPG, PNG ou WEBP") unless CAPA_TIPOS_PERMITIDOS.include?(capa.blob.content_type)
    errors.add(:capa, "pode ter no máximo 5 MB") if capa.blob.byte_size > CAPA_TAMANHO_MAXIMO
  end
end
