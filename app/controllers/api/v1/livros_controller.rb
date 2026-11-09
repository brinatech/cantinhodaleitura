module Api
  module V1
    class LivrosController < ApplicationController
      def index
        livros = Livro.includes(:categoria).all

        render json: livros.map { |livro| livro_json(livro) }
      end

      private

      def livro_json(livro)
        {
          id: livro.id,
          titulo: livro.titulo,
          autor: livro.autor,
          descricao: livro.descricao,
          caminho_arquivo: livro.caminho_arquivo,
          categoria: {
            id: livro.categoria.id,
            nome: livro.categoria.nome,
            descricao: livro.categoria.descricao
          }
        }
      end
    end
  end
end
