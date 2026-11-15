module Autenticavel
  extend ActiveSupport::Concern

  included do
    helper_method :current_usuario
  end

  private

  def current_usuario
    @current_usuario ||= Usuario.find_by(id: session[:usuario_id], ativo: true) if session[:usuario_id]
  end

  def exigir_autenticacao
    return if current_usuario

    render json: { erro: "Autenticação necessária" }, status: :unauthorized
  end
end