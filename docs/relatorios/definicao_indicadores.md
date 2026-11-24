# Definição dos indicadores (HU-22, Task 1)

Proposta da equipe para aprovação da SESFA. Os relatórios são calculados na hora a partir dos dados
já gravados; não existe tabela de relatórios.

## Período

- **Padrão:** o mês atual (do dia 1 até hoje).
- **Filtros:** este mês, mês passado, últimos 30 dias ou de uma data a outra (no máximo 1 ano).
- **Fuso horário:** Brasília (`America/Sao_Paulo`). Um acesso às 23h do dia 10 conta no dia 10.
- **Datas inclusivas:** de 01/11 a 15/11 inclui o dia 15 inteiro.

## Indicadores

| Indicador | Fórmula | Fonte |
| --- | --- | --- |
| Livros no acervo | todos os livros cadastrados até o fim do período | `livros` |
| Livros novos no período | livros com `created_at` dentro do período | `livros` |
| Livros cadastrados por mês | contagem por mês (`created_at`), dentro do período | `livros` |
| Leitores cadastrados | contas com `tipo_usuario = leitor`, criadas até o fim do período (conta excluída pelo próprio usuário deixa de contar a partir da exclusão) | `usuarios` |
| Leitores ativos | leitores **diferentes** com pelo menos um acesso (visualização, leitura ou download) no período; quem acessou várias vezes conta 1; visitantes e administradores não entram. O painel mostra também a % sobre os cadastrados | `acesso_materials` + `usuarios` |
| Visualizações | acessos `visualizacao` no período | `acesso_materials` |
| Leituras | acessos `leitura` no período | `acesso_materials` |
| Downloads | acessos `download` no período | `acesso_materials` |
| Livros mais acessados | os 10 livros com mais leituras no período (empate: mais acessos no total) | `acesso_materials` + `livros` |

## Quando cada acesso é gravado

- **Visualização:** quando a página de um livro é aberta (`GET /api/v1/livros/:id`).
- **Leitura:** quando o leitor abre o arquivo do livro para ler ou ouvir (`?modo=leitura`).
- **Download:** quando alguém usa o botão "Baixar".
- Só é gravado depois que a ação foi permitida (o livro ou o arquivo existe).

## Repetições

O mesmo livro, do mesmo tipo, na mesma sessão do navegador, conta **uma vez a cada 30 minutos**.
Assim, um livro com PDF e áudio não conta 2 leituras, o player de áudio (que renova o link a cada
5 minutos) não conta uma leitura por renovação e recarregar a página não conta várias visualizações.

## Visitantes

Acessos de quem não fez login entram nos totais e aparecem **separados** ("de leitores" e "de visitantes").
Nenhum dado pessoal aparece nos relatórios: só números e títulos de livros.

## Início dos dados

Os acessos começaram a ser gravados em **22/11/2026**. Períodos anteriores aparecem sem acessos;
o painel avisa a data do primeiro acesso registrado.

## Em aberto (decisão da SESFA)

- **Usuário ativo:** a equipe adotou a opção (b), **"leu ou abriu algum livro no período"**
  (`acesso_materials` com usuário), porque é a única que dá para calcular para qualquer período com
  os dados que já existem. As outras opções eram: (a) entrou no sistema no período (não dá para
  calcular o passado: a tabela `usuarios` guarda só o último login, `ultimo_acesso_em`); (c) conta
  habilitada (é o mesmo que "leitores cadastrados", que continua no painel). **A SESFA precisa
  confirmar** esta definição.
- **Quem é "gestor autorizado":** hoje só o perfil `administrador` vê os relatórios.
