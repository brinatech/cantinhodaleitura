module Api
  module V1
    class LivrosController < ApplicationController
      def index
        livros = LivrosQuery.new(params).call.includes(:categoria, :arquivos, :classificacoes).with_attached_capa

        render json: livros.map { |livro| livro_json(livro) }
      end

      def show
        livro = Livro.includes(:categoria, :arquivos, :classificacoes).find(params[:id])
        # HU-10 Task 3: abrir a página do livro conta como "visualizacao"
        RegistrarAcesso.call(livro: livro, tipo: "visualizacao", usuario: current_usuario, sessao: session)

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
          capa_url: capa_url_de(livro),
          formatos: livro.arquivos.select { |arquivo| arquivo.arquivo.attached? }.map do |arquivo|
            {
              tipo: arquivo.tipo,
              id: arquivo.id,
              nome: arquivo.arquivo.filename.to_s,
              url: api_v1_livro_arquivo_path(livro, arquivo)
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
