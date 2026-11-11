module Api
  module V1
    class LivrosController < ApplicationController
      def index
        livros = Livro.includes(:categoria, :arquivos).all

        render json: livros.map { |livro| livro_json(livro) }
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
          }
        }
      end
    end
  end
end
