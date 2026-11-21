module Api
  module V1
    module Admin
      class CategoriasController < ApplicationController
        before_action :exigir_administrador!
        before_action :carregar_categoria, only: [ :show, :update, :destroy ]


        def index
          categorias = Categoria.order(:nome)

          render json: categorias.map { |categoria| categoria_json(categoria) }
        end

        def show
          render json: categoria_json(@categoria)
        end

                def create
          categoria = Categoria.new(categoria_params)

          if categoria.save
            render json: categoria_json(categoria), status: :created
          else
            render json: { erros: categoria.errors.to_hash }, status: :unprocessable_entity
          end
        end

        def update
          if @categoria.update(categoria_params)
            render json: categoria_json(@categoria)
          else
            render json: { erros: @categoria.errors.to_hash }, status: :unprocessable_entity
          end
        end

                def destroy
          if @categoria.destroy
            head :no_content
          else
            render json: { erro: @categoria.errors.full_messages.to_sentence }, status: :conflict
          end
        end



        private

        def carregar_categoria
          @categoria = Categoria.find_by(id: params[:id])
          render json: { erro: "Categoria não encontrada" }, status: :not_found unless @categoria
        end

                def categoria_params
          params.require(:categoria).permit(:nome, :descricao)
        end


        def categoria_json(categoria)
          {
            id: categoria.id,
            nome: categoria.nome,
            descricao: categoria.descricao
          }
        end
      end
    end
  end
end
