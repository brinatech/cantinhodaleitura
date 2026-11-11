class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_usuario

  private

  def current_usuario
    @current_usuario ||= Usuario.find_by(id: session[:usuario_id], ativo: true) if session[:usuario_id]
  end

  def require_usuario!
    return if current_usuario

    render json: { erro: "Autenticação necessária" }, status: :unauthorized
  end

  def require_administrador!
    unless current_usuario
      render json: { erro: "Autenticação necessária" }, status: :unauthorized
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
