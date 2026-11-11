module Api
  module V1
    class SessoesController < ApplicationController
      before_action :require_usuario!, only: :show

      def show
        render json: usuario_json(current_usuario)
      end

      def create
        usuario = Usuario.find_by(email: params[:email].to_s.strip.downcase)

        if usuario&.ativo? && usuario.authenticate(params[:password].to_s)
          reset_session
          session[:usuario_id] = usuario.id
          usuario.update!(ultimo_acesso_em: Time.current)
          render json: usuario_json(usuario)
        else
          render json: { erro: "Email ou senha inválidos" }, status: :unauthorized
        end
      end

      def destroy
        reset_session
        head :no_content
      end
    end
  end
end