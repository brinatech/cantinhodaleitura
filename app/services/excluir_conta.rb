# Exclui a conta a pedido do próprio usuário (HU-21 Task 2), por anonimização.
# Regras em docs/decisoes-negocio/retencao_exclusao_dados.md:
# - apaga o que é pessoal: favoritos, listas de leitura (com os livros delas), marcadores e histórico de leitura;
# - mantém os acessos (visualização/leitura/download) para os relatórios não mudarem, presos a uma conta sem nome;
# - troca nome, e-mail e senha por valores que não identificam ninguém, desativa e marca excluido_em.
# O e-mail original fica livre: a pessoa pode criar uma conta nova no futuro.
# Tudo numa transação: ou tudo acontece, ou nada muda.
class ExcluirConta
  NOME_ANONIMO = "Conta excluída".freeze

  def self.call(...) = new(...).call

  def initialize(usuario:)
    @usuario = usuario
  end

  def call
    Usuario.transaction do
      # Pela tabela (não "@usuario.favoritos.delete_all": num has_many sem dependent, isso só esvazia o usuario_id)
      Favorito.where(usuario_id: @usuario.id).delete_all
      MarcadorPagina.where(usuario_id: @usuario.id).delete_all
      HistoricoLeitura.where(usuario_id: @usuario.id).delete_all
      ListaLeitura.where(usuario_id: @usuario.id).destroy_all # destroy: apaga também os livros de cada lista

      @usuario.update!(
        nome: NOME_ANONIMO,
        email: "conta-excluida-#{@usuario.id}@cantinho.invalid",
        password: SecureRandom.base58(32), # ninguém sabe esta senha; o token de recuperação antigo deixa de valer
        ativo: false,
        ultimo_acesso_em: nil,
        excluido_em: Time.current
      )
    end

    @usuario
  end
end
