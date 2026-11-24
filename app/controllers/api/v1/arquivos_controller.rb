module Api
  module V1
    class ArquivosController < ApplicationController
      # Quanto tempo o link do arquivo vale. Depois disso, é preciso pedir de novo (e passar pelo login).
      VALIDADE_DO_LINK = 5.minutes

      # Sem login: pelo backlog, visitantes podem abrir os materiais públicos (premissas e HU-10).
      # A restrição de livros por idade ou perfil fica para a HU-11 (acesso_service).
      # Cadastrar livro continua só para admin (admin/livros_controller).
      before_action :carregar_arquivo

      # GET /api/v1/livros/:livro_id/arquivos/:id               → baixa o arquivo
      # GET /api/v1/livros/:livro_id/arquivos/:id?modo=leitura  → abre no navegador (para ler ou ouvir)
      def show
        # HU-10 Task 3: abrir para ler/ouvir conta como "leitura"; sem modo, como "download"
        RegistrarAcesso.call(livro: @arquivo.livro, tipo: leitura? ? "leitura" : "download", usuario: current_usuario, sessao: session)

        redirect_to rails_blob_url(@arquivo.arquivo, disposition: disposicao, expires_in: VALIDADE_DO_LINK),
                    allow_other_host: true
      end

      private

      # inline = abre no navegador; attachment = baixa
      def disposicao
        leitura? ? "inline" : "attachment"
      end

      def leitura? = params[:modo] == "leitura"

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
