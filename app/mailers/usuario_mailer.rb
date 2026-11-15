class UsuarioMailer < ApplicationMailer
  def recuperar_senha(usuario)
    # O link abre a tela do Vue (rota em modo hash); o token vale 15 minutos e só uma vez.
    @link = "#{root_url}#/redefinir-senha?token=#{ERB::Util.url_encode(usuario.password_reset_token)}"
    @nome = usuario.nome

    mail to: usuario.email, subject: "Redefinir sua senha no Cantinho da Leitura"
  end
end
