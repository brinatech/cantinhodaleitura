# Tela inicial da biblioteca

Branch: `feature/tela-inicial-biblioteca`

Primeira tela do Cantinho da Leitura feita em Vue: a página inicial (`/`), com banner, apresentação do projeto, livros em destaque, chamada para entrar e rodapé. Os dados ainda são estáticos e nenhum dado é enviado ao backend.

## Como ver a tela

Com as dependências instaladas (ver [README](../README.md)), rode o servidor e acesse `http://localhost:3000`:

```bash
bin/dev
```

## O que foi feito

### Rails

| Arquivo | O que mudou |
|---|---|
| `config/routes.rb` | Rota raiz `root "home#index"` |
| `app/controllers/home_controller.rb` | Controller vazio que só renderiza a página |
| `app/views/home/index.html.erb` | View vazia. O conteúdo vem todo do Vue |
| `app/views/layouts/application.html.erb` | Fontes Inter e Host Grotesk do Google Fonts. Já tinha a `<div id="vue-app">`, onde o Vue é montado |
| `app/assets/stylesheets/application.css` | Reset básico (`margin`, `padding`, `box-sizing`) e fonte Inter no `body` |

### Vue

```
app/javascript/
├── components/
│   ├── App.vue              ← moldura: só mostra a view atual
│   ├── Cabecalho.vue        ← logo, menu (Início, Sobre, Acervo) e botão Entrar
│   ├── BannerCarrossel.vue  ← carrossel do topo com 3 slides e bolinhas
│   └── Rodape.vue           ← colunas Biblioteca/SESFA e ilustração
├── views/
│   └── HomeView.vue         ← tela inicial, monta os componentes acima
└── images/                  ← imagens da tela, separadas por seção
```

**Seções da `HomeView`:**

1. **Cabeçalho**, flutuando sobre o banner.
2. **Banner:** "Um mundo de histórias. Um cantinho para você."
3. **Apresentação:** "Histórias que aproximam" e o card "Para ler. Para ouvir."
4. **Livros em destaque:** lista com rolagem horizontal. Cada card tem capa, título, autor e um link de formato ("Texto e audiobook").
5. **Chamada:** "Seu próximo capítulo começa neste cantinho."
6. **Rodapé**

**Interações:**

- **Cards de livro:** zoom leve no hover.
- **Link de formato do livro:** troca de cor no hover.
- **Botões azuis:** mudam de cor e ganham sombra no hover.
- **Links do rodapé:** ficam azuis e sublinhados no hover.

## Decisões

- **Views e componentes:** cada tela é uma view em `views/`, e as peças que se repetem ficam em `components/`. O `App.vue` não tem nada visual, para cada tela poder ter seu próprio layout.
- **Cabeçalho da tela inicial:** o `Cabecalho.vue` tem o visual da home (faixa branca a 75% com canto arredondado e botão Entrar azul claro). Ele ocupa seu espaço normal no topo da página, e a `HomeView` faz ele flutuar sobre o banner com a classe `cabecalho-sobre-banner`. A tela de login vai ter um cabeçalho diferente, com faixa branca na largura toda e botão Entrar azul escuro.
- **Livros em destaque:** estão fixos numa lista em `HomeView.vue` e depois devem vir da API.

## Pendências

- [x] **Carrossel do banner:** feito. Ver [carrossel-e-responsividade.md](carrossel-e-responsividade.md).
- [ ] **Cabeçalho do login:** criar o visual do cabeçalho da tela de login.
- [ ] **Rotas no front:** instalar o `vue-router` e criar a `LoginView` (`/login`). No Rails, vai ser preciso uma rota que entregue a mesma página para qualquer caminho do Vue.
- [ ] **Links provisórios:** os links do menu, do rodapé e dos livros usam âncoras (`#acervo`, `#livro-1`…). Trocar pelas rotas reais.
- [ ] **Hover dos botões:** os botões azuis deveriam subir um pouco no hover, mas um bloco `prefers-reduced-motion` comentado pela metade deixou ativa uma regra `transform: none`. Fica no final da seção "Hover dos botões azuis" da `HomeView.vue` e também no `BannerCarrossel.vue`.
- [ ] **`.gitignore`:** o repositório não tem `.gitignore`, e por isso `log/`, `tmp/` e `node_modules/` aparecem no `git status`.
