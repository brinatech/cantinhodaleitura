class ApplicationController < ActionController::Base
  include Autenticavel

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def require_administrador!
    unless current_usuario
      exigir_autenticacao
      return
    end

    return if current_usuario.tipo_usuario == "administrador"

    render json: { erro: "Acesso restrito a administradores" }, status: :forbidden
  end

  def usuario_json(usuario)
    {
      id: usuario.id,
      nome: usuario.nome,
      email: usuario.email,
      tipo_usuario: usuario.tipo_usuario,
      ativo: usuario.ativo,
      ultimo_acesso_em: usuario.ultimo_acesso_em
    }
  end
end
