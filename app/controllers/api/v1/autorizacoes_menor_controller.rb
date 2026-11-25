module Api
  module V1
    # HU-20 (VERSÃO PROPOSTA): página que o responsável abre pelo link do e-mail.
    # Sem login: quem prova que é o responsável é o token do link (vale 7 dias e uma resposta só).
    # GET mostra o resumo; PATCH autoriza (a conta passa a entrar); DELETE recusa (a conta é apagada).
    class AutorizacoesMenorController < ApplicationController
      before_action :carregar_conta

      def show
        render json: {
          nome: @usuario.nome,
          nome_usuario: @usuario.nome_usuario,
          responsavel_nome: @usuario.responsavel_nome,
          criado_em: @usuario.created_at,
          vence_em: @usuario.created_at + Usuario::PRAZO_AUTORIZACAO
        }
      end

      def update
        @usuario.update!(autorizado_em: Time.current)
        render json: { nome: @usuario.nome, nome_usuario: @usuario.nome_usuario, autorizado_em: @usuario.autorizado_em }
      end

      # Recusar apaga o cadastro: a conta nunca entrou, então não há favoritos, histórico ou acessos ligados a ela
      def destroy
        @usuario.destroy!
        head :no_content
      end

      private

      def carregar_conta
        @usuario = Usuario.find_by_token_for(:autorizacao_responsavel, params[:token].to_s)
        return if @usuario&.aguardando_autorizacao? && !@usuario.excluido?

        render json: { erro: "Este link venceu ou já foi usado." }, status: :not_found
      end
    end
  end
end
