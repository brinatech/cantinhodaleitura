# Padrão de acessibilidade do frontend

HU-16 Task 1. Regras curtas para quem cria ou altera telas e componentes Vue.
Elas descrevem o que o projeto já pratica e servem de checklist na revisão (HU-16 Task 2).
A referência de avaliação é o WCAG 2.2 (nível AA). **Isto não é uma declaração de conformidade:**
só dá para afirmar depois do teste com usuários (HU-16 Task 3).

## 1. Estrutura e semântica

- Uma tela tem um `<main>` e um `<h1>`. Os títulos seguem a ordem (h1 → h2 → h3), sem pular nível por causa do tamanho visual.
- Botão faz ação (`<button>`); link leva para outra tela (`<a>` / `RouterLink`). Não use `<div @click>`.
- O idioma da página é `pt-BR` (`<html lang="pt-BR">` em `app/views/layouts/application.html.erb`).
- O primeiro item focável da página é o link **"Pular para o conteúdo"** (`App.vue`). Ele leva o foco ao `<main>`.
- `aria-label` só quando não existe texto visível. Se existe texto, o nome acessível começa com ele (ex.: botão "Ajustar" com `aria-label="Ajustar à largura"`).
- Ícone decorativo: `aria-hidden="true"`. Imagem informativa: `alt` descritivo. Capa e ilustração decorativas: `alt=""`.

## 2. Teclado e foco

- Tudo que o mouse faz, o teclado faz: Tab / Shift+Tab percorrem na ordem visual; Enter ativa botões e links; Espaço ativa botões e interruptores.
- O foco **sempre aparece**. Use o anel do design system (3px, cor `--borda-foco`, como o `Botao`). Nunca `outline: none` sem um anel no lugar.
- Diálogo é `<dialog>` nativo com `showModal()` (veja `PainelAcessibilidade` e `ModalConfirmacao`): o foco fica preso dentro, Esc fecha e o foco volta para quem abriu. A opção segura recebe o foco inicial.
- Widget com setas (player, leitor de PDF): `role` correto, `tabindex="0"` no elemento principal e teclas documentadas no próprio componente. Os campos e botões dentro dele continuam recebendo as teclas normais.

## 3. Formulários e mensagens

- Todo campo tem `<label>` visível ligado por `for`/`id` (`CampoFormulario` já faz isso).
- Erro de campo: texto + ícone (nunca só cor), `aria-invalid="true"` e `aria-describedby` apontando para a mensagem (`CampoFormulario`).
- Feedback que aparece sem a pessoa pedir usa `Alerta`: `role="alert"` para erro e `role="status"` para info e sucesso. Texto que muda sozinho (página X de Y, zoom, "carregando") usa `aria-live="polite"`.
- Estado de carregamento é anunciado (`role="status"`), não só um desenho girando.

## 4. Cor, tamanho e movimento

- Texto normal: contraste mínimo 4,5:1; texto grande e componentes de interface: 3:1. Use só os tokens de `styles/tokens.css`; valor de cor solto em componente só com contraste conferido.
- Nunca passe informação só pela cor (erro, selecionado, disponível).
- Alvo de toque/clique de pelo menos 44×44 px nos controles principais.
- Fonte em `rem`, para o ajuste "Tamanho do texto" e o zoom do navegador funcionarem. A tela precisa continuar usável em 200% de zoom e em 320 px de largura, sem rolagem horizontal.
- Animação respeita `prefers-reduced-motion` e o "Modo calmo" (`data-calmo` no `<html>`). Nada pisca.
- Ajustes do painel (`stores/ajustes.js`): tamanho, espaço entre linhas, tema, alto contraste, modo calmo. Componente novo precisa ficar legível em todos eles, inclusive no tema escuro.

## 5. Recursos assistivos de conteúdo (HU-17)

- A tela só mostra como disponível o que existe de fato. Ausência de recurso não aparece como botão que não funciona.
- Os recursos de um livro vêm das **classificações do tipo `acessibilidade`** (cadastradas no admin, HU-09). A lista é uma declaração do cadastro; ela não liga nada sozinha.
- **Leitura em voz alta** usa a Web Speech API do navegador (`speechSynthesis`). Se o navegador não suporta, a tela diz isso; se a página não tem texto (PDF de imagem), diz isso também.
- **Legendas, Libras e audiodescrição:** o DER não tem onde guardar esses arquivos (`ArquivoMaterial` só aceita `texto` e `audio`). Não há controle para eles. Quando houver armazenamento definido, entram em `components/leitor/RecursosAcessibilidade.vue`.

## 6. Decisões assumidas (sem validação da SESFA)

A equipe não tem contato com a SESFA. Foi decidido seguir sem esperar a validação, registrando aqui:

- Lista de recursos entregues na v1: ajustes de apresentação (HU-18), leitura em voz alta (HU-17) e a lista de recursos declarados por classificação.
- Taxonomia de recursos: o tipo `acessibilidade` das classificações, com nome livre (ex.: "Audiodescrição", "Libras").
- As decisões podem ser revistas se a SESFA validar depois.

## 7. Checklist de revisão de tela

- [ ] Dá para fazer o fluxo inteiro só com teclado? A ordem do foco faz sentido?
- [ ] O foco está sempre visível? Depois de abrir/fechar um diálogo, onde ele cai?
- [ ] Um leitor de tela anuncia cada botão, campo e ícone com nome claro?
- [ ] Erros aparecem junto ao campo e são anunciados?
- [ ] Os títulos estão em ordem e há um só `<h1>`?
- [ ] Contraste conferido em tema claro, escuro e alto contraste?
- [ ] Funciona em 320 px, em zoom de 200% e com "Tamanho do texto" A++?
- [ ] Respeita "Modo calmo" e `prefers-reduced-motion`?

## Pendências conhecidas (para a HU-16 Task 2)

- Depois de trocar de rota o foco não é movido para o início da nova tela. Avaliar mover o foco para o `<h1>`.
- Conferir `alt` de capas e ilustrações em todas as telas e a ordem dos títulos.
- Conferir contraste dos tokens no tema escuro com uma ferramenta (não foi medido).
