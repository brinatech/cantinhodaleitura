module Api
  module V1
    # Pôr e tirar livros de uma lista de leitura de quem está logado (HU-13 Task 3).
    class ListaLeituraLivrosController < ApplicationController
      before_action :exigir_autenticacao
      before_action :carregar_lista

      # POST /api/v1/listas_leitura/:listas_leitura_id/livros com { livro_id: 13 }
      def create
        livro = Livro.find_by(id: params[:livro_id])
        return render json: { erro: "Livro não encontrado" }, status: :not_found unless livro

        item = @lista.lista_leitura_livros.new(livro: livro)
        if item.save
          render json: { lista_id: @lista.id, livro_id: livro.id }, status: :created
        elsif item.errors.of_kind?(:livro_id, :taken)
          render_ja_na_lista
        else
          render json: { erros: item.errors.to_hash }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotUnique
        # Dois cliques quase juntos: o índice único do banco segura o segundo
        render_ja_na_lista
      end

      # DELETE /api/v1/listas_leitura/:listas_leitura_id/livros/:livro_id
      def destroy
        item = @lista.lista_leitura_livros.find_by(livro_id: params[:livro_id])
        return render json: { erro: "Este livro não está na lista" }, status: :not_found unless item

        item.destroy!
        head :no_content
      end

      private

      # Só as listas de quem está logado: a de outra pessoa responde 404
      def carregar_lista
        @lista = current_usuario.lista_leituras.find_by(id: params[:listas_leitura_id])
        render json: { erro: "Lista não encontrada" }, status: :not_found unless @lista
      end

      def render_ja_na_lista
        render json: { erro: "Este livro já está na lista" }, status: :conflict
      end
    end
  end
end
