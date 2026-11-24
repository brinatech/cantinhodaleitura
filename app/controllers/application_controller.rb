class ApplicationController < ActionController::Base
  include Autenticavel
  include AutorizacaoPerfil

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  # Endereço da capa: a imagem enviada pelo admin; se não houver, o link antigo da coluna capa_url
  def capa_url_de(livro)
    return rails_blob_path(livro.capa, disposition: "inline") if livro.capa.attached?

    livro.capa_url
  end

  def usuario_json(usuario)
    {
      id: usuario.id,
      nome: usuario.nome,
      email: usuario.email,
      tipo_usuario: usuario.tipo_usuario,
      ativo: usuario.ativo,
      ultimo_acesso_em: usuario.ultimo_acesso_em,
      menor: usuario.menor, # HU-20: conta de criança/adolescente criada pelo responsável
      nome_usuario: usuario.nome_usuario
    }
  end
end
