# Exclusão da própria conta e retenção de dados (HU-21)

Registro de como funciona o "Excluir minha conta" em "Meu perfil". É uma **proposta da equipe**: o backlog pede que a SESFA defina a política de retenção, o que ainda não foi possível. A escolha foi a **anonimização**, que atende ao direito de eliminação dos dados pessoais (LGPD, art. 18) sem quebrar os relatórios nem o banco.

## Como a pessoa exclui a conta

1. Em "Meu perfil", seção "Excluir minha conta", lê o que será apagado e clica no botão.
2. Uma janela de confirmação pede a **senha atual** (protege contra alguém usando o computador logado, comum em computador compartilhado na ONG).
3. O servidor exclui, encerra a sessão, e a pessoa vai para a tela de entrar com o aviso "Sua conta foi excluída".

API: `DELETE /api/v1/perfil` com `{ "senha_atual": "..." }`. Sempre a conta de quem está logado (nunca um id na URL). Senha errada → 422 (`erros.senha_atual`). Sem login → 401. Conta de administrador → 403 (a biblioteca não pode ficar sem administrador; isso é feito pela equipe técnica).

## O que acontece com cada dado

| Dado | O que acontece | Por quê |
|---|---|---|
| Favoritos | **Apagados** | Dado pessoal, sem uso para a ONG |
| Listas de leitura (e os livros de cada lista) | **Apagadas** | Dado pessoal |
| Marcadores de página | **Apagados** | Dado pessoal |
| Histórico de leitura | **Apagado** | Dado pessoal (o que a pessoa leu) |
| Acessos (visualização, leitura, download) | **Mantidos**, presos à conta anonimizada | São a base dos relatórios (HU-22) e dos "mais lidos"; sem nome nem e-mail não identificam ninguém |
| Nome | Vira "Conta excluída" | Anonimização |
| E-mail | Vira `conta-excluida-<id>@cantinho.invalid` | Libera o e-mail original para uma conta nova no futuro |
| Senha | Trocada por uma aleatória que ninguém conhece | A senha antiga e links de recuperação deixam de valer |
| Último acesso | Apagado | Dado de uso pessoal |
| Livros do acervo | Não mudam | Não pertencem ao leitor |

A conta fica com `ativo = false` e `excluido_em` preenchido (coluna nova, migration `AddExcluidoEmToUsuarios`). Tudo acontece numa transação (`app/services/excluir_conta.rb`): se algo falhar, nada é apagado.

## Efeitos em outras partes

- **Login**: a conta não entra mais (está inativa e ninguém sabe a senha).
- **Administração de contas (HU-19)**: aparece como "Excluída" (filtro próprio) e **não pode ser reativada** (403), diferente da conta desativada pelo administrador.
- **Relatórios**: "Leitores cadastrados" deixa de contar a conta a partir da data da exclusão; períodos anteriores não mudam. Os números de acessos não mudam.

## Perguntas em aberto para a SESFA

1. A exclusão deve ser imediata (como está) ou um pedido analisado por alguém da ONG?
2. Por quanto tempo os acessos anonimizados podem ser mantidos? Devem ser apagados depois de um prazo?
3. Para crianças e adolescentes (HU-20), o responsável também pode pedir a exclusão?
4. É preciso enviar um e-mail confirmando a exclusão? (Hoje não: o e-mail é apagado na hora.)
