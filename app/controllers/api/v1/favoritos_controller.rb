module Api
  module V1
    # Favoritos de quem está logado (HU-12 Task 2).
    # Tudo sai do current_usuario: o navegador nunca diz de quem são os favoritos,
    # então ninguém vê nem mexe nos favoritos de outra pessoa trocando um número na URL.
    class FavoritosController < ApplicationController
      before_action :exigir_autenticacao

      # GET /api/v1/favoritos → os meus favoritos, do mais recente para o mais antigo
      def index
        favoritos = current_usuario.favoritos
                                   .includes(livro: [ :categoria, { capa_attachment: :blob } ])
                                   .order(data_favorito: :desc, id: :desc)

        render json: favoritos.map { |favorito| favorito_json(favorito) }
      end

      # POST /api/v1/favoritos com { livro_id: 13 } → favorita o livro
      def create
        livro = Livro.find_by(id: params[:livro_id])
        return render json: { erro: "Livro não encontrado" }, status: :not_found unless livro

        favorito = current_usuario.favoritos.new(livro: livro)
        if favorito.save
          render json: favorito_json(favorito), status: :created
        elsif favorito.errors.of_kind?(:livro_id, :taken)
          render_ja_favorito
        else
          render json: { erros: favorito.errors.to_hash }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotUnique
        # Dois cliques quase juntos: a validação deixa passar os dois, e o índice único do banco segura o segundo
        render_ja_favorito
      end

      # DELETE /api/v1/favoritos/:livro_id → tira o livro dos meus favoritos
      def destroy
        favorito = current_usuario.favoritos.find_by(livro_id: params[:livro_id])
        return render json: { erro: "Este livro não está nos seus favoritos" }, status: :not_found unless favorito

        favorito.destroy!
        head :no_content
      end

      private

      def render_ja_favorito
        render json: { erro: "Este livro já está nos seus favoritos" }, status: :conflict
      end

      def favorito_json(favorito)
        livro = favorito.livro
        {
          livro_id: livro.id,
          data_favorito: favorito.data_favorito,
          livro: {
            id: livro.id,
            titulo: livro.titulo,
            autor: livro.autor,
            capa_url: capa_url_de(livro), # capa enviada pelo admin ou, se não tiver, o link antigo
            categoria: { id: livro.categoria.id, nome: livro.categoria.nome }
          }
        }
      end
    end
  end
end
