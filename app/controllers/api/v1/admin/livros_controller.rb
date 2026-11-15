module Api
  module V1
    module Admin
      class LivrosController < ApplicationController
        before_action :exigir_administrador!, only: [ :create, :update, :destroy ]

        def index
          render json: Livro.includes(:categoria, :arquivos).map { |livro| livro_json(livro) }
        end

        def create
          arquivo = arquivo_attributes
          livro = Livro.new(livro_attributes)
          livro.usuario_cadastro = current_usuario
          if arquivo.blank?
            livro.valid?
            livro.errors.add(:arquivo, "deve ser informado")
            return render_erros(livro.errors.to_hash)
          end

          Livro.transaction do
            livro.save!
            criar_arquivo(livro, arquivo)
          end

          render json: livro_json(livro), status: :created
        rescue ActiveRecord::RecordInvalid => error
          render_erros(error.record.errors.to_hash)
        end

        def update
          livro = Livro.find(params[:id])

          Livro.transaction do
            livro.update!(livro_attributes)
            arquivo = arquivo_attributes
            criar_arquivo(livro, arquivo) if arquivo.present?
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
          attributes = params.require(:livro).permit(:titulo, :autor, :descricao, :id_categoria)
          attributes[:categoria_id] = attributes.delete(:id_categoria)
          attributes
        end

        def arquivo_attributes
          params.require(:livro).permit(arquivo: [ :tipo, :arquivo ])["arquivo"]
        end

        def criar_arquivo(livro, arquivo)
          material = livro.arquivos.find_or_initialize_by(tipo: arquivo[:tipo])
          material.arquivo.attach(arquivo[:arquivo]) if arquivo[:arquivo].present?
          material.save!
        end

        def livro_json(livro)
          {
            id: livro.id,
            titulo: livro.titulo,
            autor: livro.autor,
            descricao: livro.descricao,
            id_categoria: livro.categoria_id,
            arquivos: livro.arquivos.filter_map do |arquivo|
              next unless arquivo.arquivo.attached?

              {
                id: arquivo.id,
                tipo: arquivo.tipo,
                nome: arquivo.arquivo.filename.to_s,
                url: api_v1_livro_arquivo_path(livro, arquivo)
              }
            end
          }
        end

        def render_erros(erros)
          render json: { erros: erros }, status: :unprocessable_entity
        end
      end
    end
  end
end