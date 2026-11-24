module Api
  module V1
    # Marcador de página de quem está logado (HU-15 Task 2). Um por livro.
    # Tudo sai do current_usuario: o navegador nunca diz de quem é o marcador.
    class MarcadoresPaginaController < ApplicationController
      before_action :exigir_autenticacao
      before_action :carregar_livro

      # GET /api/v1/marcadores_pagina/:livro_id → o meu marcador neste livro, ou null se ainda não tenho
      def show
        marcador = current_usuario.marcador_paginas.find_by(livro: @livro)
        render json: marcador && marcador_json(marcador)
      end

      # PUT /api/v1/marcadores_pagina/:livro_id com { pagina_atual: 11 } → cria ou atualiza o marcador
      def update
        marcador = current_usuario.marcador_paginas.find_or_initialize_by(livro: @livro)
        marcador.assign_attributes(params.slice(:pagina_atual, :localizacao).permit(:pagina_atual, :localizacao))

        if marcador.save
          render json: marcador_json(marcador)
        else
          render json: { erros: marcador.errors.to_hash }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotUnique
        # Dois pedidos quase juntos criando o primeiro marcador: o índice único segura o segundo,
        # que tenta de novo uma vez (agora acha o marcador e só atualiza)
        raise if @tentou_de_novo

        @tentou_de_novo = true
        retry
      end

      private

      def carregar_livro
        @livro = Livro.find_by(id: params[:livro_id])
        render json: { erro: "Livro não encontrado" }, status: :not_found unless @livro
      end

      def marcador_json(marcador)
        {
          livro_id: marcador.livro_id,
          pagina_atual: marcador.pagina_atual,
          localizacao: marcador.localizacao,
          data_atualizacao: marcador.data_atualizacao
        }
      end
    end
  end
end
