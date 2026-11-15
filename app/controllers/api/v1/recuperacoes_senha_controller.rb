module Api
  module V1
    class RecuperacoesSenhaController < ApplicationController
      rate_limit to: 5, within: 10.minutes, only: :create,
                 with: -> { render json: { erro: "Muitas tentativas. Aguarde alguns minutos." }, status: :too_many_requests }

      # Responde igual exista a conta ou não, para não revelar quem tem cadastro.
      def create
        usuario = Usuario.find_by(email: params[:email].to_s.strip.downcase, ativo: true)
        UsuarioMailer.recuperar_senha(usuario).deliver_later if usuario

        head :no_content
      end

      def update
        usuario = Usuario.find_by_password_reset_token(params[:token].to_s)

        return render_erros(token: [ "inválido ou expirado" ]) unless usuario
        return render_erros(password: [ I18n.t("errors.messages.blank") ]) if params[:password].blank?

        if usuario.update(password: params[:password])
          head :no_content
        else
          render_erros(usuario.errors.to_hash)
        end
      end

      private

      def render_erros(erros)
        render json: { erros: erros }, status: :unprocessable_entity
      end
    end
  end
end
