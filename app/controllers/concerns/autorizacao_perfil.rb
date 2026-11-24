module AutorizacaoPerfil
  extend ActiveSupport::Concern

  private

  def exigir_administrador!
    unless current_usuario
      exigir_autenticacao
      return
    end

    return if current_usuario.tipo_usuario == "administrador"

    render json: { erro: "Acesso restrito a administradores" }, status: :forbidden
  end
end
