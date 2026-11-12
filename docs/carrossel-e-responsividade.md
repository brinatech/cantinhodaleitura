# Carrossel do banner e responsividade

Branch: `feature/tela-inicial-biblioteca`

Mudanças feitas na tela inicial depois do commit `110b961` (documentação da tela inicial). Este documento complementa o [tela-inicial.md](tela-inicial.md).

## Resumo

- **Carrossel:** o banner do topo virou um carrossel com 3 slides, que troca sozinho e também pelas bolinhas.
- **Responsividade:** a tela inicial passou a se adaptar a 6 larguras de tela, de 1536px até 475px.
- **Imagens do banner:** ficam agora numa pasta própria.


## Carrossel do banner

Arquivo: `app/javascript/components/BannerCarrossel.vue`

**Os slides:**

| Slide | Etiqueta | Título | Botão | Imagem |
|---|---|---|---|---|
| 1 | Leitura que acolhe | Um mundo de histórias. Um cantinho para você. | Explorar o acervo | `img-banner.png` |
| 2 | Clube do livro | Boas histórias ficam melhores em companhia | Conhecer o clube | `img-banner2 (2).png` |
| 3 | Sorteio do livro do mês | Um livro muitas novas descobertas | Ver atividade do mês | `img-banner3.png` |

**Como funciona:**

- **Deslize:** os 3 slides ficam lado a lado dentro de um "trilho", que desliza para o lado em 0.8s.
- **Troca automática:** a cada 6 segundos. Depois do 3º slide, volta ao 1º.
- **Pausa:** a troca para enquanto o mouse ou o foco do teclado estiver no banner.
- **Bolinhas:** agora existe uma fileira só para o carrossel inteiro. Antes, cada slide tinha a sua. Clicar numa bolinha leva ao slide e recomeça a contagem.
- **Acessibilidade:** os slides escondidos recebem `inert`, então os botões deles não pegam o foco do Tab nem são lidos por leitores de tela.

**Para ajustar:** no `<script>` do componente ficam `intervalo: 6000` (tempo de cada slide, em milissegundos) e `total: 3`. Se adicionar uma 4ª `<section class="banner">`, mude o `total` para 4 e crie a classe `banner--4` com a imagem.

**Gradiente:** o gradiente escuro, que deixa o texto legível, deixou de ser repetido em cada slide. Agora é uma camada só (`.banner::before`), por cima da imagem. Cada slide define apenas a sua imagem (`.banner--1`, `.banner--2`, `.banner--3`).

## Imagens do banner

As imagens foram para uma pasta própria, no mesmo padrão das outras seções:

```
app/javascript/images/imgs-banner/
├── img-banner.png
├── img-banner2 (2).png   ← nova
└── img-banner3.png       ← nova
```

## Responsividade

Todas as partes usam os mesmos pontos de quebra:

| Nome | Media query |
|---|---|
| 2xl | `@media (max-width: 1536px)` |
| xl | `@media (max-width: 1280px)` |
| lg | `@media (max-width: 1024px)` |
| md | `@media (max-width: 768px)` |
| sm | `@media (max-width: 640px)` |
| xs | `@media (max-width: 475px)` |

Cada componente tem as suas media queries no final do próprio `<style scoped>`, numa seção "Responsividade". As antigas `@media (max-width: 900px)` da `HomeView` e do `Rodape` foram substituídas por essas.

### Espaço lateral

O espaço nas laterais da página diminui a cada ponto de quebra, igual em todas as seções:

| Largura | Tela grande | 1536 | 1280 | 1024 | 768 | 640 | 475 |
|---|---|---|---|---|---|---|---|
| Espaço lateral | 160px | 120px | 80px | 40px | 24px | 20px | 16px |

### Cabeçalho (`Cabecalho.vue`)

- **Até 1024px:** mesmo visual, com espaços menores entre os itens do menu.
- **Entre 768px e 475px:**
  - o próprio `<header>` vira a faixa branca, na largura toda;
  - logo, menu e botão Entrar ficam numa linha só, com o menu centralizado entre o logo e o botão;
  - o texto do menu diminui para 14px, e para 13px abaixo de 640px.
- **Abaixo de 475px:** o logo é escondido, para sobrar espaço para o menu.

### Banner (`BannerCarrossel.vue`)

- **Até 1024px:** o banner fica mais baixo (615px → 520px) e o título diminui.
- **Abaixo de 768px:**
  - o texto ocupa a largura toda;
  - o gradiente passa a escurecer de baixo para cima, para o texto continuar legível sobre a imagem.
- **Abaixo de 475px:** o botão ocupa a largura toda.

### Tela inicial (`HomeView.vue`)

- **Apresentação:**
  - em 1024px, vira uma coluna (texto em cima, card "Para ler. Para ouvir." embaixo) e as nuvens de enfeite somem;
  - em 768px, o card empilha a imagem e o texto;
  - em 640px, a etiqueta, o título, o texto e o botão ficam centralizados.
- **Livros em destaque:**
  - os cards diminuem em 640px e 475px;
  - a coruja some em 768px.
- **Chamada final:**
  - em 768px, texto e botão empilham;
  - abaixo de 640px, vira um "card": a ilustração inteira em cima e o texto embaixo, num fundo azul (`#1d5577`).

### Rodapé (`Rodape.vue`)

- **1024px:** 3 colunas, e a ilustração do menino com o livro some.
- **768px:** a marca fica em cima e as colunas Biblioteca e SESFA lado a lado embaixo.
- **475px:** tudo numa coluna só.


