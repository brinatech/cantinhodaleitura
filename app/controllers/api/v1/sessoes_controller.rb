module Api
  module V1
    class SessoesController < ApplicationController
      # O login troca a sessão (reset_session) e invalida o token CSRF que a página leu ao carregar.
      # O front guarda este header e o reenvia nos próximos POST/PATCH/DELETE. Vai antes do
      # exigir_autenticacao (o 401 também leva o token) e de novo depois de create/destroy (sessão nova).
      before_action :enviar_token_csrf
      before_action :exigir_autenticacao, only: :show
      after_action :enviar_token_csrf, only: [ :create, :destroy ]
      # Segurar tentativas de senha por IP (cache do Rails; no teste o cache é nulo)
      rate_limit to: 10, within: 3.minutes, only: :create,
                 with: -> { render json: { erro: "Muitas tentativas. Aguarde alguns minutos." }, status: :too_many_requests }

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

      private

      def enviar_token_csrf
        response.set_header("X-CSRF-Token", form_authenticity_token)
      end
    end
  end
end
