class UsuarioMailer < ApplicationMailer
  def recuperar_senha(usuario)
    # O link abre a tela do Vue (rota em modo hash); o token vale 15 minutos e só uma vez.
    @link = "#{root_url}#/redefinir-senha?token=#{ERB::Util.url_encode(usuario.password_reset_token)}"
    @nome = usuario.nome
    @menor = usuario.menor?

    # Conta de criança: o link vai para o e-mail do responsável
    mail to: usuario.email_para_contato, subject: "Redefinir sua senha no Cantinho da Leitura"
  end

  # HU-20 (versão proposta): o responsável confirma a conta que criou para a criança/adolescente
  def autorizar_menor(usuario)
    @link = self.class.link_autorizacao(usuario, root_url)
    @responsavel = usuario.responsavel_nome
    @nome = usuario.nome
    @nome_usuario = usuario.nome_usuario
    @prazo_dias = Usuario::PRAZO_AUTORIZACAO.in_days.to_i

    mail to: usuario.responsavel_email, subject: "Confirme a conta de #{usuario.nome} no Cantinho da Leitura"
  end

  def self.link_autorizacao(usuario, base)
    token = usuario.generate_token_for(:autorizacao_responsavel)
    "#{base}#/autorizar-menor?token=#{ERB::Util.url_encode(token)}"
  end
end
