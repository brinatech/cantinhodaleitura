module Api
  module V1
    # HU-20 (VERSÃO PROPOSTA, aguardando a SESFA): o responsável cria a conta da criança/adolescente.
    # A conta nasce bloqueada (aguardando autorização) e o responsável confirma pelo link do e-mail.
    # Regras em docs/decisoes-negocio/cadastro_menores.md.
    class CadastrosMenoresController < ApplicationController
      rate_limit to: 5, within: 10.minutes, only: :create,
                 with: -> { render json: { erro: "Muitas tentativas. Aguarde alguns minutos." }, status: :too_many_requests }

      # POST /api/v1/cadastros_menores
      # { cadastro_menor: { nome, nome_usuario, password, responsavel_nome, responsavel_email, autorizo } }
      def create
        dados = params.require(:cadastro_menor).permit(:nome, :nome_usuario, :password, :responsavel_nome, :responsavel_email, :autorizo)
        usuario = Usuario.new(dados.except(:autorizo).merge(tipo_usuario: "leitor", menor: true))

        usuario.validate
        unless ActiveModel::Type::Boolean.new.cast(dados[:autorizo])
          usuario.errors.add(:autorizo, "precisa ser marcada: só o responsável pode criar esta conta")
        end
        return render json: { erros: usuario.errors.to_hash }, status: :unprocessable_entity if usuario.errors.any?

        usuario.save!
        UsuarioMailer.autorizar_menor(usuario).deliver_later

        resposta = { nome_usuario: usuario.nome_usuario, responsavel_email: mascarar(usuario.responsavel_email) }
        # Só em desenvolvimento/teste: o e-mail não é enviado de verdade, então a tela mostra o link para demonstrar
        resposta[:link_demonstracao] = UsuarioMailer.link_autorizacao(usuario, root_url) if Rails.env.local?
        render json: resposta, status: :created
      end

      private

      # maria.silva@gmail.com -> m***a@gmail.com (a tela confirma para onde foi, sem mostrar o e-mail inteiro)
      def mascarar(email)
        nome, dominio = email.split("@", 2)
        visivel = nome.length <= 2 ? nome[0] : "#{nome[0]}***#{nome[-1]}"
        "#{visivel}@#{dominio}"
      end
    end
  end
end
