class Usuario < ApplicationRecord
  FORMATO_EMAIL = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
  # Nome de usuário das contas de menores: letras minúsculas sem acento, números, ponto, - e _ (nunca @,
  # para o login saber se recebeu um e-mail ou um nome de usuário)
  FORMATO_NOME_USUARIO = /\A[a-z0-9._-]+\z/
  PRAZO_AUTORIZACAO = 7.days

  has_secure_password

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :nome_usuario, with: ->(nome) { nome.strip.downcase.presence }
  normalizes :responsavel_email, with: ->(email) { email.strip.downcase }

  validates :nome, presence: true, length: { in: 2..100 }
  # Conta de criança/adolescente (HU-20) entra pelo nome de usuário: o e-mail é opcional
  validates :email, presence: true, unless: :menor?
  validates :email, length: { maximum: 150 }, format: { with: FORMATO_EMAIL },
                    uniqueness: { case_sensitive: false }, allow_nil: true
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :tipo_usuario, inclusion: { in: %w[leitor administrador] }
  validates :nome_usuario, uniqueness: true, allow_nil: true

  with_options if: :menor? do
    validates :nome_usuario, presence: true, length: { in: 3..30 },
                             format: { with: FORMATO_NOME_USUARIO, message: "só pode ter letras sem acento, números, ponto, hífen e sublinhado" }
    validates :responsavel_nome, presence: true, length: { in: 2..100 }
    validates :responsavel_email, presence: true, length: { maximum: 150 }, format: { with: FORMATO_EMAIL }
  end

  has_many :livros_cadastrados,
           class_name: "Livro",
           foreign_key: :usuario_cadastro_id
  has_many :acesso_materials
  has_many :favoritos
  has_many :lista_leituras
  has_many :historico_leituras
  has_many :marcador_paginas

  # Link que o responsável recebe por e-mail. Vale 7 dias e deixa de valer quando ele responde
  # (o token muda junto com autorizado_em).
  generates_token_for :autorizacao_responsavel, expires_in: PRAZO_AUTORIZACAO do
    autorizado_em
  end

  # Cadastros de menores que o responsável não confirmou dentro do prazo: são apagados (ver LimparCadastrosMenoresPendentesJob)
  scope :menores_pendentes_vencidos, -> { where(menor: true, autorizado_em: nil, excluido_em: nil).where(created_at: ...PRAZO_AUTORIZACAO.ago) }

  # Conta excluída pelo próprio usuário (HU-21): anonimizada, desativada e sem volta
  def excluido?
    excluido_em.present?
  end

  # Conta de menor que ainda não pode entrar: o responsável não confirmou pelo e-mail
  def aguardando_autorizacao?
    menor? && autorizado_em.nil?
  end

  # Para onde vão os e-mails da conta: o próprio e-mail ou, numa conta de menor, o do responsável
  def email_para_contato
    email.presence || responsavel_email
  end

  # Login: com @ é e-mail; sem @ é nome de usuário (contas de menores)
  def self.para_login(identificador)
    texto = identificador.to_s.strip.downcase
    return if texto.empty?

    texto.include?("@") ? find_by(email: texto) : find_by(nome_usuario: texto)
  end

  def serializable_hash(options = nil)
    options = (options || {}).dup
    options[:except] = Array(options[:except]) | [ "password_digest" ]
    super(options)
  end
end
