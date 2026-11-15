class ArquivoMaterial < ApplicationRecord
  TIPOS = %w[texto audio].freeze
  TIPOS_MIME_PERMITIDOS = %w[
    application/pdf
    audio/mpeg
    audio/ogg
    audio/wav
    image/jpeg
    image/png
    image/webp
  ].freeze
  EXTENSOES_PERMITIDAS = %w[.pdf .mp3 .ogg .wav .jpg .jpeg .png .webp].freeze
  TAMANHO_MAXIMO = 50.megabytes

  belongs_to :livro
  has_one_attached :arquivo

  validates :tipo, inclusion: { in: TIPOS }
  validate :arquivo_obrigatorio_sem_caminho_legado
  validate :arquivo_dentro_dos_limites

  private

  def arquivo_obrigatorio_sem_caminho_legado
    return if arquivo.attached? || caminho.present?

    errors.add(:arquivo, "deve ser informado")
  end

  def arquivo_dentro_dos_limites
    return unless arquivo.attached?

    blob = arquivo.blob
    errors.add(:arquivo, "excede o tamanho máximo permitido") if blob.byte_size > TAMANHO_MAXIMO
    errors.add(:arquivo, "possui um tipo não permitido") unless TIPOS_MIME_PERMITIDOS.include?(blob.content_type)
    errors.add(:arquivo, "possui uma extensão não permitida") unless EXTENSOES_PERMITIDAS.include?(File.extname(blob.filename.to_s).downcase)
  end
end