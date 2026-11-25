module Api
  module V1
    class PerfilController < ApplicationController
      before_action :exigir_autenticacao

      def show
        render json: usuario_json(current_usuario)
      end

      # Sempre o usuário da sessão: nunca um id vindo da URL. tipo_usuario não é aceito.
      def update
        # Conta de menor (HU-20) só troca o nome: o e-mail de contato é o do responsável
        permitidos = current_usuario.menor? ? [ :nome ] : [ :nome, :email ]
        if current_usuario.update(params.require(:usuario).permit(*permitidos))
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

      # DELETE /api/v1/perfil com { senha_atual } — o próprio usuário exclui a conta (HU-21).
      # Anonimiza em vez de apagar (ExcluirConta). Conta de administrador não se exclui por aqui,
      # para a biblioteca não ficar sem administrador.
      def destroy
        if current_usuario.tipo_usuario == "administrador"
          return render json: { erro: "Contas de administrador não podem ser excluídas por aqui." }, status: :forbidden
        end
        return render_erros(senha_atual: [ "está incorreta" ]) unless current_usuario.authenticate(params[:senha_atual].to_s)

        ExcluirConta.call(usuario: current_usuario)
        reset_session
        # A sessão nova troca o token CSRF: o front guarda este para o próximo login/cadastro
        response.set_header("X-CSRF-Token", form_authenticity_token)
        head :no_content
      end

      private

      def render_erros(erros)
        render json: { erros: erros }, status: :unprocessable_entity
      end
    end
  end
end
