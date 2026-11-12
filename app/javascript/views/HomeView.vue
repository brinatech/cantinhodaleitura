<template>
  <div class="pagina">
    <Cabecalho class="cabecalho-sobre-banner" />

    <main>
      <BannerCarrossel />

      <section class="apresentacao">
        <!-- Decorações (escondidas de leitores de tela) -->
        <img class="deco deco-nuvem" src="../images/imgs-baixo-banner/nuvem.png" alt="" aria-hidden="true">
        <img class="deco deco-nuvem-roxa" src="../images/imgs-baixo-banner/nuvem-roxa.png" alt="" aria-hidden="true">
        <img class="deco deco-nuvem-arcoiris" src="../images/imgs-baixo-banner/nuvem-arcoiris.png" alt="" aria-hidden="true">
        <img class="deco deco-estrela" src="../images/imgs-baixo-banner/arco-iris-estrela.png" alt="" aria-hidden="true">

        <div class="apresentacao-grid">
          <div class="apresentacao-texto">
            <span class="tag-clara">Um mundo ao seu alcance</span>

            <h2>Histórias que aproximam.<br>Leitura que transforma.</h2>

            <p>
              O Cantinho da Leitura nasce para ampliar o acesso aos livros e acolher
              diferentes formas de ler. Uma biblioteca para famílias, pessoas e novas
              possibilidades.
            </p>

            <a href="#sobre" class="botao-azul">Conheça o projeto</a>
          </div>

          <article class="card-ouvir">
            <div class="card-ouvir-texto">
              <svg class="icone-fone" viewBox="0 0 24 24" aria-hidden="true">
                <path d="M3 18v-6a9 9 0 0 1 18 0v6" />
                <path d="M21 19a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3zM3 19a2 2 0 0 0 2 2h1a2 2 0 0 0 2-2v-3a2 2 0 0 0-2-2H3z" />
              </svg>

              <h3>Para ler. Para ouvir.<br>Para todo mundo.</h3>

              <p>Textos ajustáveis e audiobooks fazem parte da proposta da biblioteca.</p>
            </div>

            <img class="card-ouvir-img" src="../images/imgs-baixo-banner/garota-com-fone.png" alt="" aria-hidden="true">
          </article>
        </div>

        <div class="destaque-titulo" id="acervo">
          <img src="../images/imgs-baixo-banner/lamparina.png" alt="" aria-hidden="true">
          <div>
            <h2>Livros em destaque</h2>
            <p>Uma boa história pode ser seu próximo começo.</p>
          </div>
        </div>
      </section>

      <section class="livros-destaque" aria-label="Livros em destaque">
        <img class="deco deco-coruja" :src="coruja" alt="" aria-hidden="true">

        <ul class="livros-lista">
          <li v-for="livro in livrosDestaque" :key="livro.id" class="livro-card">
            <span class="livro-marca" aria-hidden="true">Cantinho · da · leitura</span>

            <img class="livro-capa" :src="livro.capa" :alt="`Capa do livro ${livro.titulo}`">

            <h3 class="livro-titulo">{{ livro.titulo }}</h3>
            <p class="livro-autor">{{ livro.autor }}</p>

            <a
              class="livro-formato"
              :href="`#livro-${livro.id}`"
              :aria-label="`${livro.titulo}: ${livro.formato}`"
            >
              <svg viewBox="0 0 24 24" aria-hidden="true">
                <path d="M3 18v-6a9 9 0 0 1 18 0v6" />
                <path d="M21 19a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3zM3 19a2 2 0 0 0 2 2h1a2 2 0 0 0 2-2v-3a2 2 0 0 0-2-2H3z" />
              </svg>
              {{ livro.formato }}
            </a>
          </li>
        </ul>

        <a href="#acervo" class="botao-azul botao-explorar">Explorar acervo →</a>
      </section>

      <section class="chamada">
        <div class="chamada-box">
          <h2>Seu próximo capítulo<br>começa neste cantinho.</h2>
          <a href="#entrar" class="botao-azul chamada-botao">Entrar para acessar</a>
        </div>
      </section>
    </main>

    <Rodape />
  </div>
</template>

<script setup>
import Cabecalho from '../components/Cabecalho.vue'
import BannerCarrossel from '../components/BannerCarrossel.vue'
import Rodape from '../components/Rodape.vue'
import coruja from '../images/imgs-livros-destaque/coruja.png'
import capaJardim from '../images/imgs-livros-destaque/o jardim das pequenas coisas.png'
import capaMaluquinho from '../images/imgs-livros-destaque/o menino maluquinho.png'
import capaPrincipePreto from '../images/imgs-livros-destaque/o pequeno principe preto.png'
import capaPerigoso from '../images/imgs-livros-destaque/perigoso.png'
import capaMeninaCastelo from '../images/imgs-livros-destaque/outro.png'

// Dados estáticos por enquanto — depois virão de livrosService.listar()
const livrosDestaque = [
  { id: 5, titulo: 'A menina e o castelo', autor: 'Guacyra Pereira', capa: capaMeninaCastelo, formato: 'Texto e audiobook' },
  { id: 1, titulo: 'O pequeno livro das grandes coisas', autor: 'Sophie Vissière', capa: capaJardim, formato: 'Texto e audiobook' },
  { id: 2, titulo: 'O Menino Maluquinho', autor: 'Ziraldo', capa: capaMaluquinho, formato: 'Texto e audiobook' },
  { id: 3, titulo: 'O Pequeno Príncipe Preto', autor: 'Rodrigo França', capa: capaPrincipePreto, formato: 'Texto e audiobook' },
  { id: 4, titulo: 'Perigoso!', autor: 'Tim Warnes', capa: capaPerigoso, formato: 'Texto e audiobook' },
]
</script>

<style scoped>
.pagina {
  position: relative;                 /* referência para o cabeçalho que flutua sobre o banner */
}

/* Só na tela inicial: o cabeçalho flutua em cima do banner */
.pagina > .cabecalho-sobre-banner {   /* ".pagina >" garante que vence o position: relative do Cabecalho */
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
}

/* ===== Apresentação (abaixo do banner) ===== */
.apresentacao {
  position: relative;
  overflow: hidden;
  padding: 60px 160px 50px;
  background-color: #fdf7f6;
  color: #333;
}

.apresentacao-grid {
  position: relative;
  z-index: 1;                         /* conteúdo acima das nuvens */
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 60px;
  align-items: center;
}

.tag-clara {
  display: inline-block;
  padding: 6px 30px;
  border-radius: 20px;
  background-color: #e3f0f8;
  color: #1d5577;
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
}

.apresentacao-texto h2 {
  margin: 16px 0 20px;
  color: #1d5577;
  font-size: 34px;
  line-height: 1.45;
  text-align: center;
}

.apresentacao-texto p {
  max-width: 460px;
  margin-bottom: 16px;
  font-size: 18px;
  line-height: 1.6;
}

.botao-azul {
  display: inline-block;
  padding: 12px 22px;
  border-radius: 4px;
  background-color: #5bc8f5;
  color: #1d5577;
  font-weight: 700;
  text-decoration: none;
}

.card-ouvir {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  padding: 50px 40px;
  border-radius: 40px;
  background-color: #F0F9FF;
  box-shadow: 0 8px 12px rgba(0, 0, 0, 0.12);
}

.icone-fone {
  width: 56px;
  height: 56px;
  fill: none;
  stroke: #1d5577;
  stroke-width: 1.5;
  stroke-linecap: round;
  stroke-linejoin: round;
}

.card-ouvir h3 {
  margin: 20px 0;
  color: #1d5577;
  font-size: 24px;
  line-height: 1.6;
}

.card-ouvir p {
  max-width: 240px;
  font-size: 17px;
  line-height: 1.6;
}

.card-ouvir-img {
  width: 230px;
  flex-shrink: 0;
}

.destaque-titulo {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  gap: 12px;
  margin-top: 90px;
}

.destaque-titulo img {
  width: 80px;
}

.destaque-titulo h2 {
  color: #1d5577;
  font-size: 34px;
  line-height: 1.2;
}

.destaque-titulo p {
  color: #436f86;
  font-size: 20px;
  font-weight: 600;
}

/* Decorações */
.deco {
  position: absolute;
  pointer-events: none;
}

.deco-nuvem {
  top: 20px;
  left: 38%;
  width: 190px;
}

.deco-nuvem-roxa {
  top: 400px;
  left: 40px;
  width: 135px;
}

.deco-nuvem-arcoiris {
  right: 0;
  bottom: 0;
  width: 640px;
}

.deco-estrela {
  right: 0;
  bottom: 140px;
  width: 175px;
}

/* ===== Livros em destaque ===== */
.livros-destaque {
  position: relative;
  padding: 10px 0 40px;
  background-color: #fdf7f6;
  text-align: center;
}

.livros-lista {
  position: relative;
  z-index: 1;
  display: flex;
  justify-content: center;
  justify-content: safe center;       /* centraliza, mas se não couber começa do 1º card (sem cortar) */
  gap: 16px;
  padding: 10px 160px 24px;
  scroll-padding-inline: 160px;       /* o "encaixe" da rolagem respeita o espaço lateral */
  overflow-x: auto;                   /* rolagem horizontal */
  scroll-snap-type: x mandatory;
  list-style: none;
  scrollbar-width: none;              /* esconde a barra (Firefox, Chrome, Edge) */
}

.livros-lista::-webkit-scrollbar {
  display: none;                      /* esconde a barra (Safari e navegadores antigos) */
}

.livro-card {
  flex: 0 0 260px;
  scroll-snap-align: start;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 14px 20px 18px;
  border: 1px solid #f1e3e3;
  border-radius: 16px;
  background-color: #faf7f3;
  box-shadow: 0 6px 10px rgba(0, 0, 0, 0.15);
  transition: transform 0.25s ease, box-shadow 0.25s ease; /* ao sair com o mouse */
}

.livro-card:hover {
  transform: scale(1.03);             /* zoom bem leve */
  box-shadow: 0 10px 18px rgba(0, 0, 0, 0.18);
  transition: transform 0.45s ease, box-shadow 0.45s ease; /* ao entrar com o mouse */
}

/* @media (prefers-reduced-motion: reduce) {
  .livro-card,
  .livro-card:hover {
    transition: none;
  }
} */

.livro-marca {
  margin-bottom: 14px;
  color: #1d5577;
  font-size: 9px;
  font-weight: 700;
  letter-spacing: 4px;
  text-transform: uppercase;
}

.livro-capa {
  width: 180px;
  height: 235px;
  object-fit: cover;
}

.livro-titulo {
  margin-top: 18px;
  color: #1d5577;
  font-size: 15px;
  line-height: 1.3;
}

.livro-autor {
  margin: 4px 0 10px;
  color: #555;
  font-size: 13px;
}

.livro-formato {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  margin-top: auto;                   /* gruda no fim do card */
      padding: 7px 22px;
  border-radius: 4px;
  background-color: #d8e8f2;
  color: #284859;
  font-size: 13px;
  text-decoration: none;              /* tira o sublinhado padrão do link */
  transition: background-color 0.4s ease-in-out, color 0.4s ease-in-out;
}

.livro-formato:hover
 {
  background-color: #1d5577;
  color: #fff;
  transition: background-color 0.4s ease-in-out, color 0.4s ease-in-out;
}

/* .livro-formato:focus-visible {
  outline: 2px solid #1d5577;
  outline-offset: 2px;
} */

/* @media (prefers-reduced-motion: reduce) {
  .livro-formato,
  .livro-formato:hover,
  .livro-formato:focus-visible {
    transition: none;
  }
} */

.livro-formato svg {
  width: 14px;
  height: 14px;
  fill: none;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
}

.botao-explorar {
  position: relative;
  z-index: 1;
  margin-top: 16px;
  padding: 12px 44px;
}

.deco-coruja {
  left: 60px;
  bottom: -70px;                      /* negativo = desce e invade a .chamada-box */
  z-index: 5;                         /* coruja na frente dos cards e da chamada */
  width: 110px;
}

/* ===== Chamada (acima do rodapé) ===== */
.chamada {
  padding: 0 40px 50px;
  /* metade rosa (seção de cima) + metade azul (rodapé): a caixa fica "entre" as duas */
  background: linear-gradient(to bottom, #fdf7f6 50%, #eef6fd 50%);
}

.chamada-box {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 30px;
  aspect-ratio: 3072 / 700;           /* menor que a imagem (984): corta só a faixa bege de baixo */
  padding: 0 80px 40px;
  border-radius: 40px;
  overflow: hidden;
  color: white;
  background-image:
    linear-gradient(to top, rgba(0, 0, 0, 0.6), transparent 60%),
    url('../images/imgs-cima-footer/fundo-cima-footer.png');
  background-size: cover;
  background-position: center top;
}

.chamada-box h2 {
  font-size: 36px;
  line-height: 1.1;
}

.chamada-botao {
  flex-shrink: 0;
  padding: 10px 52px;
}

/* ===== Hover dos botões azuis ===== */
.botao-azul {
  transition: transform 0.3s ease, box-shadow 0.3s ease, background-color 0.3s ease;
}

.botao-azul:hover,
.botao-azul:focus-visible {
  transform: translateY(-3px);                      /* sobe um pouquinho */
  background-color: #3fb8ec;                        /* azul um tom mais forte */
  box-shadow: 0 8px 18px rgba(29, 85, 119, 0.35);   /* sombra azulada */
}

.botao-azul:active {
  transform: translateY(0);                         /* "afunda" ao clicar */
  box-shadow: 0 3px 8px rgba(29, 85, 119, 0.3);
}

/* Contorno visível para quem navega pelo teclado */
.botao-azul:focus-visible {
  outline: 3px solid #1d5577;
  outline-offset: 3px;
}

/* Quem pediu menos animação no sistema não vê o movimento */
/* @media (prefers-reduced-motion: reduce) {
  .botao-azul {
    transition: none;
  } */

  .botao-azul:hover,
  .botao-azul:focus-visible {
    transform: none;
  }


/* ===== Responsividade ===== */

/* 2xl */
@media (max-width: 1536px) {
  .apresentacao {
    padding: 60px 120px 50px;
  }

  .livros-lista {
    padding: 10px 120px 24px;
    scroll-padding-inline: 120px;
  }
}

/* xl */
@media (max-width: 1280px) {
  .apresentacao {
    padding: 60px 80px 50px;
  }

  .apresentacao-grid {
    gap: 40px;
  }

  .apresentacao-texto h2,
  .destaque-titulo h2 {
    font-size: 30px;
  }

  .card-ouvir {
    padding: 40px 32px;
  }

  .card-ouvir-img {
    width: 190px;
  }

  .deco-nuvem-arcoiris {
    width: 520px;
  }

  .livros-lista {
    padding: 10px 80px 24px;
    scroll-padding-inline: 80px;
  }

  .deco-coruja {
    left: 30px;
    width: 90px;
  }

  .chamada-box {
    padding: 0 60px 32px;
  }

  .chamada-box h2 {
    font-size: 32px;
  }
}

/* lg: apresentação vira uma coluna (texto em cima, card embaixo) */
@media (max-width: 1024px) {
  .apresentacao {
    padding: 50px 40px 40px;
  }

  .apresentacao-grid {
    grid-template-columns: 1fr;
  }

  .apresentacao-texto p {
    max-width: none;
  }

  .card-ouvir p {
    max-width: none;
  }

  .deco-nuvem,
  .deco-nuvem-roxa {
    display: none;
  }

  .deco-estrela {
    width: 130px;
  }

  .destaque-titulo {
    margin-top: 70px;
  }

  .livros-lista {
    padding: 10px 40px 24px;
    scroll-padding-inline: 40px;
  }

  .chamada {
    padding: 0 32px 40px;
  }

  .chamada-box {
    aspect-ratio: 3072 / 1000;        /* um pouco mais alta para o texto caber */
    padding: 0 40px 28px;
  }

  .chamada-box h2 {
    font-size: 28px;
  }
}

/* md */
@media (max-width: 768px) {
  .apresentacao {
    padding: 40px 24px;
  }

  .apresentacao-texto h2,
  .destaque-titulo h2 {
    font-size: 28px;
    
  }

  .apresentacao-texto p {
    font-size: 16px;
  }

  .card-ouvir {
    flex-direction: column;
    text-align: center;
  }

  .deco-nuvem-arcoiris {
    width: 380px;
  }

  .deco-estrela {
    width: 100px;
  }

  .destaque-titulo {
    margin-top: 56px;
  }

  .destaque-titulo img {
    width: 64px;
  }

  .destaque-titulo p {
    font-size: 17px;
  }

  .livros-lista {
    padding: 10px 24px 24px;
    scroll-padding-inline: 24px;
  }

  .deco-coruja {
    display: none;
  }

  /* Chamada: texto e botão empilhados, altura fixa em vez da proporção da imagem */
  .chamada {
    padding: 0 24px 40px;
  }

  .chamada-box {
    flex-direction: column;
    justify-content: flex-end;
    align-items: flex-start;
    aspect-ratio: auto;
    min-height: 300px;
    padding: 24px;
  }

  .chamada-box h2 {
    font-size: 26px;
  }
}

/* sm */
@media (max-width: 640px) {
  .apresentacao {
    padding: 36px 20px;
  }

  .tag-clara {
    display: block;
    width: fit-content;
    margin-inline: auto;
    text-align: center;
  }

  .apresentacao-texto h2 {
    text-align: center;
  }

  .apresentacao-texto p {
    text-align: center;
  }

  .botao-azul {
    display: block;
    width: fit-content;
    margin-inline: auto;
  }

  .card-ouvir {
    padding: 32px 20px;
    border-radius: 28px;
  }

  .card-ouvir h3 {
    font-size: 20px;
  }

  .card-ouvir-img {
    width: 170px;
  }

  .livros-lista {
    padding: 10px 20px 24px;
    scroll-padding-inline: 20px;
  }

  .livro-card {
    flex-basis: 220px;
  }

  .livro-capa {
    width: 150px;
    height: 196px;
  }

  .chamada {
    padding: 0 20px 36px;
  }

  /* Chamada vira um "card": a ilustração inteira em cima (sem cortar a coruja e o dragão)
     e o texto embaixo, num fundo azul que continua a onda da imagem.
     A arte colorida ocupa ~21,5% da largura da imagem (467 de 2172px); o resto é bege. */
  .chamada-box {
    --altura-arte: calc((100vw - 40px) * 0.215);   /* largura da caixa x proporção da arte */
    justify-content: flex-start;
    min-height: 0;
    padding: calc(var(--altura-arte) + 20px) 20px 24px;
    background:
      linear-gradient(#1d5577, #1d5577) bottom / 100% calc(100% - var(--altura-arte)) no-repeat,
      url('../images/imgs-cima-footer/fundo-cima-footer.png') top / 100% auto no-repeat;
  }
}

/* xs */
@media (max-width: 475px) {
  .apresentacao {
    padding: 32px 16px;
  }

  .apresentacao-texto h2,
  .destaque-titulo h2 {
    font-size: 24px;
  }

  .tag-clara {
    padding: 6px 20px;
  }

  .destaque-titulo img {
    width: 52px;
  }

  .destaque-titulo p {
    font-size: 15px;
  }

  .deco-nuvem-arcoiris {
    width: 280px;
  }

  .deco-estrela {
    display: none;
  }

  .livros-lista {
    padding: 10px 16px 24px;
    scroll-padding-inline: 16px;
  }

  .livro-card {
    flex-basis: 200px;
  }

  .livro-capa {
    width: 140px;
    height: 183px;
  }

  .chamada {
    padding: 0 16px 32px;
  }

  .chamada-box {
    --altura-arte: calc((100vw - 32px) * 0.215);   /* aqui a .chamada tem 16px de cada lado */
    padding: calc(var(--altura-arte) + 16px) 16px 20px;
  }

  .chamada-box h2 {
    font-size: 22px;
  }

  .chamada-botao {
    align-self: stretch;              /* botão na largura toda */
    text-align: center;
  }
}
</style>
