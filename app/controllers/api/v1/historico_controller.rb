module Api
  module V1
    # Histórico de leitura de quem está logado (HU-14 Task 2).
    # O leitor avisa a página ao abrir o livro e ao trocar de página; o servidor guarda as datas e o progresso.
    # Tudo sai do current_usuario: o navegador nunca diz de quem é o histórico.
    class HistoricoController < ApplicationController
      before_action :exigir_autenticacao
      before_action :carregar_livro

      # PUT /api/v1/historico/:livro_id com { pagina: 11, total_paginas: 28 } → registra a leitura
      # (sem página: só marca que abriu o livro)
      def update
        pagina = inteiro(params[:pagina])
        total = inteiro(params[:total_paginas])
        return render_pagina_invalida if (params[:pagina].present? || params[:total_paginas].present?) && !pagina_valida?(pagina, total)

        historico = RegistrarLeitura.call(usuario: current_usuario, livro: @livro, pagina: pagina, total_paginas: total)
        if historico.errors.any?
          render json: { erros: historico.errors.to_hash }, status: :unprocessable_entity
        else
          render json: historico_json(historico)
        end
      end

      private

      def carregar_livro
        @livro = Livro.find_by(id: params[:livro_id])
        render json: { erro: "Livro não encontrado" }, status: :not_found unless @livro
      end

      # "11" ou 11 → 11. Qualquer outra coisa (2.5, "abc", -1) → nil
      def inteiro(valor)
        valor.to_s.match?(/\A\d+\z/) ? valor.to_i : nil
      end

      def pagina_valida?(pagina, total)
        pagina && total && total.positive? && pagina.between?(1, total)
      end

      def render_pagina_invalida
        render json: { erros: { pagina: [ "deve estar entre 1 e o total de páginas" ] } }, status: :unprocessable_entity
      end

      def historico_json(historico)
        {
          livro_id: historico.livro_id,
          data_inicio: historico.data_inicio,
          data_ultima_leitura: historico.data_ultima_leitura,
          progresso_percentual: historico.progresso_percentual.to_f
        }
      end
    end
  end
end
