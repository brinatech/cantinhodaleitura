module Api
  module V1
    module Admin
      # Relatórios da biblioteca, só para administradores (HU-22 Task 3).
      class RelatoriosController < ApplicationController
        before_action :exigir_administrador!

        PERIODO_MAXIMO = 366 # dias

        # GET /api/v1/admin/relatorios/resumo?inicio=2026-11-01&fim=2026-11-30
        # Sem datas: o mês atual (do dia 1 até hoje, em Brasília)
        def resumo
          inicio = data(:inicio) { hoje.beginning_of_month }
          fim = data(:fim) { hoje }
          return render_erro("Use datas no formato AAAA-MM-DD") unless inicio && fim
          return render_erro("O início precisa ser antes do fim") if inicio > fim
          return render_erro("O período pode ter no máximo 1 ano") if (fim - inicio).to_i >= PERIODO_MAXIMO

          render json: Relatorios::BibliotecaQuery.new(inicio: inicio, fim: fim).call
        end

        private

        def hoje = Time.current.in_time_zone(Relatorios::BibliotecaQuery::FUSO).to_date

        # Data do parâmetro (AAAA-MM-DD); sem parâmetro, o valor padrão; inválida, nil
        def data(chave)
          return yield if params[chave].blank?

          Date.iso8601(params[chave].to_s)
        rescue Date::Error
          nil
        end

        def render_erro(mensagem)
          render json: { erro: mensagem }, status: :unprocessable_entity
        end
      end
    end
  end
end
