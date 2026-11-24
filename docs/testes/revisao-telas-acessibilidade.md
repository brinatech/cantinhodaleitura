# Revisão de acessibilidade das telas (teclado e leitor de tela)

HU-16 Task 2. Registro da revisão de 24/11/2026, com o que foi testado, o que foi achado e o que ainda
não foi coberto. Padrão usado como referência: `docs/frontend/acessibilidade.md` e WCAG 2.2 AA.
**Este documento não declara conformidade**: a validação com pessoas é a HU-16 Task 3.

## 1. Como foi feita

- **Automática:** axe-core 4.14.1 (regras WCAG 2.0/2.1/2.2 A e AA, mais boas práticas), rodado no Brave 157
  (Chromium, modo sem tela) por `puppeteer-core`. Telas visitantes: `/`, `/entrar`, `/criar-conta`,
  `/esqueci-senha`, `/acervo-publico`, `/sobre` (página provisória) e `/livros/1` (livro inexistente).
  Três cenários: tema claro no desktop (1280 px), **tema escuro** no desktop e tema claro no **celular (375 px)**.
  Também verifica rolagem horizontal. O contraste foi checado nos dois temas.
- **Teclado:** Tab pelas telas de visitante (ordem, anel de foco e itens fora da tela), abrir e fechar o painel
  de acessibilidade, e foco ao trocar de tela e ao digitar na busca.
- **Estática:** leitura do código atrás de `<img>` sem `alt`, elementos clicáveis que não são botões,
  `outline: none` sem substituto e títulos.

## 2. Achados e correções

| # | Achado | Gravidade | Onde | Situação |
|---|---|---|---|---|
| 1 | `<html>` sem `lang` (leitor de tela lê no idioma errado) | Séria | Todas as telas | Corrigido na branch `feat/hu16-padrao-acessibilidade` (`lang="pt-BR"`) |
| 2 | `role="tabpanel"` num `<form>` (papel não permitido nesse elemento) | Pequena | `/entrar`, `/criar-conta` | Corrigido: papel removido; o `id` continua ligado ao `aria-controls` das abas |
| 3 | Página sem `<h1>` | Moderada | `/sobre` e "página não encontrada" | Corrigido: o título do `EstadoVazio` vira `<h1>` nessa tela |
| 4 | Foco não ia para a tela nova ao navegar (leitor de tela não anunciava a página) | Moderada | Todas | Corrigido: foco vai para o `<h1>` ao mudar de tela. Não age na primeira tela nem ao mudar só a busca na URL |

Conferido e **sem problema**:

- Contraste, nos temas claro e escuro, nas telas de visitante.
- Nenhuma rolagem horizontal a 375 px nas telas de visitante.
- Painel de acessibilidade: abre com o foco dentro, Esc fecha e o foco volta ao botão.
- Ordem do Tab lógica nas telas de visitante. O campo de busca do acervo não tem `outline`, mas o anel está no
  contêiner (`:focus-within`), então o foco aparece.
- Os `outline: none` do projeto têm anel de foco substituto (`ChipFiltro`, `CampoBusca`, `CampoFormulario`,
  `ItemMenuLateral`, `LeitorPdf`, editor de classificações, formulário de livro, cartões).
- Nenhum `<img>` sem `alt` e nenhum `div` clicável (o fundo escuro do menu móvel é decorativo).

## 3. O que **não** foi coberto

- **Telas logadas e de administração** (minhas leituras, acervo logado, detalhe, leitor de PDF, listas,
  favoritos, histórico, perfil, categorias, livros, relatórios): exigem sessão e não houve conta de teste.
  Só tiveram a revisão estática. Repetir o roteiro da seção 1 com uma conta de leitor e uma de administrador.
- **Leitor de tela de verdade** (NVDA, VoiceOver ou Orca): a revisão usou a árvore de acessibilidade e o axe,
  que não substituem ouvir a tela. Fica para a HU-16 Task 3.
- **Leitor de PDF em uso** (precisa de um livro com PDF no banco), zoom de 200% e "Tamanho do texto" A++.
- Telas com dados (acervo com livros): o banco de desenvolvimento estava sem livros.

## 4. Como repetir

1. Subir o app (`bin/rails s` e `bin/vite dev`).
2. Rodar o axe em cada tela, nos três cenários da seção 1, e comparar com a tabela acima.
3. Percorrer cada fluxo só com Tab, Shift+Tab, Enter, Espaço e Esc, usando o checklist de
   `docs/frontend/acessibilidade.md` (seção 7).
