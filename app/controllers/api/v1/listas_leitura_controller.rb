module Api
  module V1
    # Listas de leitura de quem está logado (HU-13 Task 3).
    # Tudo sai de current_usuario.lista_leituras: lista de outra pessoa responde 404, como se não existisse.
    class ListasLeituraController < ApplicationController
      before_action :exigir_autenticacao
      before_action :carregar_lista, only: [ :show, :update, :destroy ]

      # GET /api/v1/listas_leitura → as minhas listas, a mexida mais recentemente primeiro
      def index
        listas = current_usuario.lista_leituras
                                .includes(lista_leitura_livros: { livro: [ :categoria, { capa_attachment: :blob } ] })
                                .order(updated_at: :desc, id: :desc)

        render json: listas.map { |lista| resumo_json(lista) }
      end

      # GET /api/v1/listas_leitura/:id → a lista com os livros, o adicionado mais recentemente primeiro
      def show
        render json: resumo_json(@lista).merge(livros: itens_em_ordem(@lista).map { |item| livro_json(item.livro) })
      end

      # POST /api/v1/listas_leitura com { nome, descricao }
      def create
        lista = current_usuario.lista_leituras.new(lista_params)

        if lista.save
          render json: resumo_json(lista), status: :created
        else
          render json: { erros: lista.errors.to_hash }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/listas_leitura/:id com { nome, descricao }
      def update
        if @lista.update(lista_params)
          render json: resumo_json(@lista)
        else
          render json: { erros: @lista.errors.to_hash }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/listas_leitura/:id → apaga a lista (os livros continuam no acervo)
      def destroy
        @lista.destroy!
        head :no_content
      end

      private

      def carregar_lista
        @lista = current_usuario.lista_leituras.find_by(id: params[:id])
        render json: { erro: "Lista não encontrada" }, status: :not_found unless @lista
      end

      # Só nome e descrição: o dono e a data vêm do servidor
      def lista_params
        params.slice(:nome, :descricao).permit(:nome, :descricao)
      end

      def itens_em_ordem(lista)
        lista.lista_leitura_livros.sort_by { |item| [ item.created_at, item.id ] }.reverse
      end

      # livro_ids: para a página do livro saber em quais listas ele já está.
      # capas: até 3 livros, para a miniatura do card da lista
      def resumo_json(lista)
        itens = itens_em_ordem(lista)
        {
          id: lista.id,
          nome: lista.nome,
          descricao: lista.descricao,
          data_criacao: lista.data_criacao,
          total_livros: itens.size,
          livro_ids: itens.map(&:livro_id),
          capas: itens.first(3).map { |item| livro_json(item.livro).slice(:id, :titulo, :capa_url, :categoria) }
        }
      end

      def livro_json(livro)
        {
          id: livro.id,
          titulo: livro.titulo,
          autor: livro.autor,
          capa_url: capa_url_de(livro),
          categoria: { id: livro.categoria.id, nome: livro.categoria.nome }
        }
      end
    end
  end
end
