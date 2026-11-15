module Api
  module V1
    class LivrosController < ApplicationController
      def index
        livros = LivrosQuery.new(params).call.includes(:categoria, :arquivos, :classificacoes)

        render json: livros.map { |livro| livro_json(livro) }
      end

      def show
        livro = Livro.includes(:categoria, :arquivos, :classificacoes).find(params[:id])

        render json: livro_json(livro)
      rescue ActiveRecord::RecordNotFound
        render json: { erro: "Livro não encontrado" }, status: :not_found
      end

      private

      def livro_json(livro)
        {
          id: livro.id,
          titulo: livro.titulo,
          autor: livro.autor,
          descricao: livro.descricao,
          capa_url: livro.capa_url,
          formatos: livro.arquivos.map do |arquivo|
            {
              tipo: arquivo.tipo,
              caminho: arquivo.caminho
            }
          end,
          categoria: {
            id: livro.categoria.id,
            nome: livro.categoria.nome,
            descricao: livro.categoria.descricao
          },
          classificacoes: livro.classificacoes.map do |classificacao|
            {
              tipo: classificacao.tipo,
              nome: classificacao.nome,
              descricao: classificacao.descricao
            }
          end
        }
      end
    end
  end
end
