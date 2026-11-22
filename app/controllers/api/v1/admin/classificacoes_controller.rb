module Api
  module V1
    module Admin
      class ClassificacoesController < ApplicationController
        before_action :exigir_administrador!
        before_action :carregar_livro

        def index
          classificacoes = @livro.classificacoes.order(:tipo, :nome)

          render json: classificacoes.map { |classificacao| classificacao_json(classificacao) }
        end

        def create
          classificacao = @livro.classificacoes.new(classificacao_params)

          if classificacao.save
            render json: classificacao_json(classificacao), status: :created
          else
            render json: { erros: classificacao.errors.to_hash }, status: :unprocessable_entity
          end
        end

        def destroy
          classificacao = @livro.classificacoes.find_by(id: params[:id])
          return render json: { erro: "Classificação não encontrada" }, status: :not_found unless classificacao

          classificacao.destroy!
          head :no_content
        end

        private

        def carregar_livro
          @livro = Livro.find_by(id: params[:livro_id])
          render json: { erro: "Livro não encontrado" }, status: :not_found unless @livro
        end

        def classificacao_params
          params.require(:classificacao).permit(:tipo, :nome, :descricao)
        end

        def classificacao_json(classificacao)
          {
            id: classificacao.id,
            tipo: classificacao.tipo,
            nome: classificacao.nome,
            descricao: classificacao.descricao
          }
        end
      end
    end
  end
end
