module Api
  module V1
    module Admin
      class LivrosController < ApplicationController
        before_action :exigir_administrador!, only: [ :create, :update, :destroy ]

        def index
          render json: Livro.includes(:categoria, :arquivos).map { |livro| livro_json(livro) }
        end

        def create
          livro = Livro.new(livro_attributes)
          livro.usuario_cadastro = current_usuario

          Livro.transaction do
            livro.save!
            criar_arquivo(livro)
          end

          render json: livro_json(livro), status: :created
        rescue ActiveRecord::RecordInvalid => error
          render_erros(error.record.errors.to_hash)
        end

        def update
          livro = Livro.find(params[:id])

          Livro.transaction do
            livro.update!(livro_attributes)
            criar_arquivo(livro) if arquivo_attributes.present?
          end

          render json: livro_json(livro)
        rescue ActiveRecord::RecordNotFound
          render json: { erro: "Livro não encontrado" }, status: :not_found
        rescue ActiveRecord::RecordInvalid => error
          render_erros(error.record.errors.to_hash)
        end

        def destroy
          livro = Livro.find(params[:id])
          livro.destroy!

          head :no_content
        rescue ActiveRecord::RecordNotFound
          render json: { erro: "Livro não encontrado" }, status: :not_found
        rescue ActiveRecord::RecordNotDestroyed => error
          render_erros(error.record.errors.to_hash)
        end

        private

        def livro_attributes
          attributes = params.require(:livro).permit(:titulo, :autor, :descricao, :id_categoria, arquivo: [ :tipo, :caminho ])
          attributes[:categoria_id] = attributes.delete(:id_categoria)
          attributes.except(:arquivo)
        end

        def arquivo_attributes
          params.require(:livro).permit(arquivo: [ :tipo, :caminho ])["arquivo"]
        end

        def criar_arquivo(livro)
          arquivo = arquivo_attributes
          return if arquivo.blank?

          material = livro.arquivos.find_or_initialize_by(tipo: arquivo[:tipo])
          material.caminho = arquivo[:caminho]
          material.save!
        end

        def livro_json(livro)
          {
            id: livro.id,
            titulo: livro.titulo,
            autor: livro.autor,
            descricao: livro.descricao,
            id_categoria: livro.categoria_id,
            arquivos: livro.arquivos.map { |arquivo| { tipo: arquivo.tipo, caminho: arquivo.caminho } }
          }
        end

        def render_erros(erros)
          render json: { erros: erros }, status: :unprocessable_entity
        end
      end
    end
  end
end