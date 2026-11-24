module Api
  module V1
    module Admin
      class UsuariosController < ApplicationController
        # Admins podem consultar contas, alterar leitor/administrador e bloquear/reativar.
        # Contas não são excluídas para preservar o histórico; ninguém altera a própria conta.
        before_action :exigir_administrador!
        before_action :carregar_usuario, only: :update

        def index
          usuarios = Usuario.order(created_at: :desc, id: :desc)
          render json: usuarios.map { |usuario| usuario_json(usuario) }
        end

        def update
          atributos = usuario_params
          return render json: { erro: "Informe o perfil ou o status da conta" }, status: :unprocessable_entity if atributos.empty?

          if atributos.key?(:ativo) && ActiveModel::Type::Boolean.new.cast(atributos[:ativo]).nil?
            return render json: { erro: "O status precisa ser ativo ou bloqueado" }, status: :unprocessable_entity
          end

          solicitou_bloqueio = atributos.key?(:ativo) && ActiveModel::Type::Boolean.new.cast(atributos[:ativo]) == false
          if @usuario.id == current_usuario.id && (atributos.key?(:tipo_usuario) || solicitou_bloqueio)
            return render json: { erro: "Não é permitido alterar o próprio perfil ou bloquear a própria conta" }, status: :forbidden
          end

          if ultimo_administrador_ativo?(@usuario, atributos)
            return render json: { erro: "A conta é o último administrador ativo e não pode ser rebaixada nem bloqueada" }, status: :conflict
          end

          if @usuario.update(atributos)
            render json: usuario_json(@usuario)
          else
            render json: { erros: @usuario.errors.to_hash }, status: :unprocessable_entity
          end
        end

        private

        def carregar_usuario
          @usuario = Usuario.find_by(id: params[:id])
          render json: { erro: "Usuário não encontrado" }, status: :not_found unless @usuario
        end

        def usuario_params
          params.require(:usuario).permit(:tipo_usuario, :ativo).to_h.symbolize_keys
        end

        def ultimo_administrador_ativo?(usuario, atributos)
          esta_ativo_admin = usuario.ativo? && usuario.tipo_usuario == "administrador"
          solicita_inativacao = atributos.key?(:ativo) && ActiveModel::Type::Boolean.new.cast(atributos[:ativo]) == false
          deixa_de_ser_ativo_admin = solicita_inativacao || atributos[:tipo_usuario] == "leitor"
          esta_ativo_admin && deixa_de_ser_ativo_admin && Usuario.where(tipo_usuario: "administrador", ativo: true).where.not(id: usuario.id).none?
        end
      end
    end
  end
end
