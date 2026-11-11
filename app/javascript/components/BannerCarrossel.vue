<script>
    export default {
        name: 'BannerCarrossel',

        data() {
            return {
                atual: 0,        // índice do slide que está aparecendo
                total: 3,        // quantidade de <section class="banner"> no template
                intervalo: 6000, // tempo de cada slide (ms)
                timer: null,
            }
        },

        mounted() {
            this.iniciar()
        },

        beforeUnmount() {
            this.parar()
        },

        methods: {
            proximo() {
                this.atual = (this.atual + 1) % this.total   // depois do último, volta ao primeiro
            },

            irPara(indice) {
                this.atual = indice
                this.iniciar()                               // recomeça a contagem depois do clique
            },

            iniciar() {
                this.parar()
                this.timer = setInterval(this.proximo, this.intervalo)
            },

            parar() {
                clearInterval(this.timer)
                this.timer = null
            },
        },
    }
</script>

<template>
  <!-- Pausa a troca automática enquanto o mouse ou o foco do teclado estiver no banner -->
  <div
    class="carrossel"
    aria-roledescription="carrossel"
    aria-label="Destaques"
    @mouseenter="parar"
    @mouseleave="iniciar"
    @focusin="parar"
    @focusout="iniciar"
  >
    <!-- O trilho tem os 3 slides lado a lado e desliza para mostrar o atual -->
    <div class="carrossel-trilho" :style="{ transform: `translateX(-${atual * 100}%)` }">

      <!-- :inert tira os slides escondidos do Tab e dos leitores de tela -->
      <section class="banner banner--1" aria-roledescription="slide" aria-label="1 de 3" :inert="atual !== 0">
        <div class="banner-conteudo">
          <span class="banner-tag">Leitura que acolhe</span>

          <h1>Um mundo de histórias.<br>Um cantinho para você.</h1>

          <p>Leia, ouça e descubra novas possibilidades. No seu tempo, do seu jeito.</p>

          <a href="#acervo" class="banner-botao">Explorar o acervo</a>
        </div>
      </section>

      <section class="banner banner--2" aria-roledescription="slide" aria-label="2 de 3" :inert="atual !== 1">
        <div class="banner-conteudo">
          <span class="banner-tag">CLUBE DO LIVRO</span>

          <h1>Boas histórias ficam <br> melhores em companhia</h1>

          <p>Um espaço para conversar sobre livros, trocar ideias e criar novos laços.</p>

          <a href="#acervo" class="banner-botao">Conhecer o clube</a>
        </div>
      </section>

      <section class="banner banner--3" aria-roledescription="slide" aria-label="3 de 3" :inert="atual !== 2">
        <div class="banner-conteudo">
          <span class="banner-tag">SORTEIO DO LIVRO DO MÊS</span>

          <h1>Um livro muitas <br> novas descobertas</h1>

          <p>Um espaço para divulgar o livro do mês e as próximas atividades da biblioteca.</p>

          <a href="#acervo" class="banner-botao">Ver atividade do mês</a>
        </div>
      </section>

    </div>

    <!-- Bolinhas: uma só fileira para o carrossel inteiro -->
    <div class="banner-pontos">
      <button
        v-for="indice in total"
        :key="indice"
        class="ponto"
        :class="{ ativo: atual === indice - 1 }"
        :aria-label="`Ir para o slide ${indice}`"
        :aria-current="atual === indice - 1"
        @click="irPara(indice - 1)"
      ></button>
    </div>
  </div>
</template>

<style scoped>
/* ===== Carrossel ===== */
.carrossel {
  position: relative;                 /* referência para as bolinhas */
  overflow: hidden;                   /* esconde os slides que estão fora da tela */
  border-radius: 0 0 30px 30px;       /* cantos de baixo arredondados */
}

.carrossel-trilho {
  display: flex;                      /* slides lado a lado */
  transition: transform 0.8s ease-in-out;   /* o deslizar entre os slides */
}

/* ===== Cada slide ===== */
.banner {
  position: relative;                 /* referência para o gradiente (::before) */
  flex: 0 0 100%;                     /* cada slide ocupa a largura toda */
  display: flex;
  align-items: flex-end;              /* joga o conteúdo para baixo */
  height: 615px;
  padding: 0 0 45px 130px;            /* distância da borda esquerda e de baixo */
  color: white;
  background-size: cover;
  background-position: center;
}

/* Gradiente escuro à esquerda, por cima da imagem (o mesmo para os 3 slides) */
.banner::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(to right, rgba(0, 0, 0, 0.8) 0%, rgba(0, 0, 0, 0.5) 35%, transparent 65%);
}

/* Imagem de cada slide */
.banner--1 {
  background-image: url('../images/imgs-banner/img-banner.png');
}

.banner--2 {
  background-image: url('../images/imgs-banner/img-banner2 (2).png');
}

.banner--3 {
  background-image: url('../images/imgs-banner/img-banner3.png');
}

.banner-conteudo {
  position: relative;                 /* texto na frente do gradiente */
  max-width: 520px;
}

.banner-tag {
  display: inline-block;
  padding: 10px 40px;
  border-radius: 6px;
  background-color: #5bc8f5;
  color: #0d3b66;
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
}

.banner h1 {
  margin: 10px 0 8px;
  font-size: 40px;
  line-height: 1.2;
}

.banner p {
  font-size: 16px;
}

.banner-botao {
  display: inline-block;
  margin-top: 40px;
  padding: 14px 56px;
  border-radius: 6px;
  background-color: #5bc8f5;
  color: #0d3b66;
  font-weight: 700;
  text-decoration: none;
  transition: transform 0.3s ease, box-shadow 0.3s ease, background-color 0.3s ease;
}

.banner-botao:hover,
.banner-botao:focus-visible {
  transform: translateY(-3px);                      /* sobe um pouquinho */
  background-color: #3fb8ec;                        /* azul um tom mais forte */
  box-shadow: 0 8px 18px rgba(29, 85, 119, 0.35);   /* sombra azulada */
}

.banner-botao:active {
  transform: translateY(0);                         /* "afunda" ao clicar */
  box-shadow: 0 3px 8px rgba(29, 85, 119, 0.3);
}

/* Contorno visível para quem navega pelo teclado */
.banner-botao:focus-visible {
  outline: 3px solid #1d5577;
  outline-offset: 3px;
}

/* Mesmo comportamento que estava na HomeView: o botão não sobe no hover.
   Apague este bloco para ele voltar a subir. */
.banner-botao:hover,
.banner-botao:focus-visible {
  transform: none;
}

/* ===== Bolinhas ===== */
.banner-pontos {
  position: absolute;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);        /* centraliza na horizontal */
  display: flex;
  gap: 16px;
}

.ponto {
  width: 10px;
  height: 10px;
  border: none;
  border-radius: 50%;
  background-color: white;
  cursor: pointer;
  transition: background-color 0.3s ease, transform 0.3s ease;
}

.ponto:hover {
  transform: scale(1.3);
}

.ponto.ativo {
  background-color: #5bc8f5;
}

.ponto:focus-visible {
  outline: 2px solid white;
  outline-offset: 3px;
}

/* ===== Responsividade ===== */

/* 2xl */
@media (max-width: 1536px) {
  .banner {
    padding-left: 120px;
  }
}

/* xl */
@media (max-width: 1280px) {
  .banner {
    height: 560px;
    padding-left: 80px;
  }
}

/* lg */
@media (max-width: 1024px) {
  .banner {
    height: 520px;
    padding-left: 40px;
  }

  .banner-conteudo {
    max-width: 460px;
  }

  .banner h1 {
    font-size: 34px;
  }
}

/* md */
@media (max-width: 768px) {
  .banner {
    padding: 0 24px 64px;             /* espaço embaixo para as bolinhas */
  }

  /* No celular o texto ocupa a largura toda: o gradiente escurece de baixo para cima */
  .banner::before {
    background: linear-gradient(to top, rgba(0, 0, 0, 0.85) 0%, rgba(0, 0, 0, 0.55) 45%, transparent 80%);
  }

  .banner-conteudo {
    max-width: none;
  }

  .banner h1 {
    font-size: 30px;
  }

  .banner p {
    font-size: 15px;
  }

  .banner-tag {
    padding: 8px 24px;
  }

  .banner-botao {
    margin-top: 24px;
    padding: 12px 36px;
  }
}

/* sm */
@media (max-width: 640px) {
  .banner {
    height: 500px;
    padding: 0 20px 60px;
  }

  .banner h1 {
    font-size: 26px;
  }
}

/* xs */
@media (max-width: 475px) {
  .banner {
    height: 480px;
    padding: 0 16px 56px;
  }

  .banner h1 {
    font-size: 23px;
  }

  .banner-tag {
    font-size: 11px;
  }

  .banner-botao {
    display: block;                   /* botão na largura toda, mais fácil de tocar */
    text-align: center;
    padding: 12px 20px;
  }
}
</style>
