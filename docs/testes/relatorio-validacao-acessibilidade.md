# Validação de acessibilidade com usuários

HU-16 Task 3 (RNF12). Roteiro de teste e modelo de relatório. **Os testes com pessoas ainda não foram feitos:**
as tabelas das seções 4 a 6 estão em branco para o time preencher. Antes de testar, rode a revisão técnica de
`docs/testes/revisao-telas-acessibilidade.md` e corrija o que ela achar.

## 1. Cuidados com os participantes

- Participação voluntária, com explicação do objetivo antes de começar e possibilidade de parar a qualquer momento.
- **Não registrar dados pessoais.** Cada pessoa é um código (P1, P2...) com o perfil mínimo para o teste
  (ex.: "usa leitor de tela", "baixa visão", "usa só teclado", "sem recurso assistivo"). Nada de nome,
  e-mail, idade exata ou deficiência detalhada.
- Gravação de tela ou áudio só com consentimento por escrito, guardada fora do repositório.
- Se a SESFA ou outra instituição autorizar o convite de participantes, registrar a autorização aqui
  (data e quem autorizou). Se não houver contato, convidar pessoas do círculo da equipe que aceitem.
- Usar uma conta de teste, nunca a de uma pessoa real.

## 2. Preparação

- Ambiente: app rodando com dados de teste: pelo menos 1 livro com PDF, 1 com áudio e 1 conta de leitor.
- Cada participante usa o **próprio navegador e recurso assistivo**, quando tiver. Registrar a combinação.
- Quem conduz só observa: não ajuda, não aponta onde clicar. Anota o que a pessoa diz em voz alta e onde trava.

## 3. Roteiro de tarefas

Ler cada tarefa em voz alta. Medir se concluiu (sim, com dificuldade, não) e o tempo aproximado.

| # | Tarefa | Concluída quando |
|---|---|---|
| T1 | Encontrar um livro pelo título ou pelo autor | A pessoa chega à página do livro |
| T2 | Filtrar o acervo por uma categoria e abrir um livro | A página de detalhe está aberta |
| T3 | Dizer quem é o autor e a categoria do livro aberto | Informa os dois corretamente |
| T4 | Iniciar a leitura do livro | A primeira página do PDF está na tela |
| T5 | Ir para a próxima página e voltar | Muda de página nos dois sentidos |
| T6 | Aumentar o tamanho do texto e ligar o tema escuro nos ajustes de leitura | O ajuste aparece na tela |
| T7 | Ligar a leitura em voz alta da página (se o navegador permitir) | A voz começa e a pessoa consegue parar |
| T8 | Entrar com a conta de teste | Está na área logada |
| T9 | Favoritar o livro | O livro aparece em Favoritos |
| T10 | Voltar ao livro, sair da leitura e continuar de onde parou | Abre na página salva |

Perguntas ao final (respostas livres): O que atrapalhou mais? O que ajudou? Ficou algo sem entender?

## 4. Participantes e tarefas (preencher)

| Código | Perfil mínimo | Navegador + recurso assistivo | Data | T1 | T2 | T3 | T4 | T5 | T6 | T7 | T8 | T9 | T10 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| P1 | | | | | | | | | | | | | |
| P2 | | | | | | | | | | | | | |

Legenda: ✔ concluiu · ~ concluiu com dificuldade · ✘ não concluiu · — não se aplica.

## 5. Barreiras encontradas (preencher)

| # | Tarefa | Quem | O que aconteceu | Gravidade | Correção proposta | Situação |
|---|---|---|---|---|---|---|
| 1 | | | | | | Aberta |

**Gravidade:**
- **Crítica:** impede concluir a tarefa.
- **Alta:** conclui só com muita dificuldade ou ajuda.
- **Média:** atrapalha, mas a pessoa contorna.
- **Baixa:** incômodo ou melhoria.

## 6. Pendências priorizadas (preencher)

Ordem: críticas e altas primeiro. Cada item vira um cartão ou issue e entra no backlog.

| Prioridade | Barreira (#) | Responsável | Prazo |
|---|---|---|---|

## 7. Segunda rodada

Depois das correções, repetir o roteiro (de preferência com as mesmas pessoas) e registrar abaixo se cada barreira
foi resolvida.

| Barreira (#) | Resolvida? | Observação |
|---|---|---|
