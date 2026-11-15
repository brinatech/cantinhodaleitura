module Api
  module V1
    class ArquivosController < ApplicationController
      before_action :exigir_autenticacao
      before_action :carregar_arquivo

      def show
        redirect_to rails_blob_url(@arquivo.arquivo, disposition: "attachment"), allow_other_host: true
      end

      private

      def carregar_arquivo
        @arquivo = ArquivoMaterial.find_by!(livro_id: params[:livro_id], id: params[:id])
        return if @arquivo.arquivo.attached?

        render json: { erro: "Arquivo não encontrado" }, status: :not_found
      rescue ActiveRecord::RecordNotFound
        render json: { erro: "Arquivo não encontrado" }, status: :not_found
      end
    end
  end
end