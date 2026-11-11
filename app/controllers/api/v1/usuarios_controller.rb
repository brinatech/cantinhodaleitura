module Api
  module V1
    class UsuariosController < ApplicationController
      def create
        usuario = Usuario.new(usuario_params)
        usuario.tipo_usuario = "leitor"

        if usuario.save
          render json: usuario_json(usuario), status: :created
        else
          render json: { erros: usuario.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def usuario_params
        params.require(:usuario).permit(:nome, :email, :password, :password_confirmation)
      end
    end
  end
end