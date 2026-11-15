module Api
  module V1
    class PerfilController < ApplicationController
      before_action :exigir_autenticacao

      def show
        render json: usuario_json(current_usuario)
      end

      # Sempre o usuário da sessão: nunca um id vindo da URL. tipo_usuario não é aceito.
      def update
        if current_usuario.update(params.require(:usuario).permit(:nome, :email))
          render json: usuario_json(current_usuario)
        else
          render json: { erros: current_usuario.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def senha
        return render_erros(senha_atual: [ "está incorreta" ]) unless current_usuario.authenticate(params[:senha_atual].to_s)
        return render_erros(password: [ I18n.t("errors.messages.blank") ]) if params[:password].blank?

        if current_usuario.update(password: params[:password])
          head :no_content
        else
          render_erros(current_usuario.errors.to_hash)
        end
      end

      private

      def render_erros(erros)
        render json: { erros: erros }, status: :unprocessable_entity
      end
    end
  end
end
