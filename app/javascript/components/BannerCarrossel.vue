<!--
  Banner rotativo da tela inicial (Figma: "HERO" + "Indicador do banner").
  O Figma só desenha o 1º slide; os outros dois seguem o mesmo molde.
  Troca sozinho a cada 6s, pausa com mouse ou foco dentro do banner e não troca
  sozinho para quem pediu menos movimento no sistema.
-->
<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue'
import Botao from './ui/Botao.vue'
import IndicadorBanner from './ui/IndicadorBanner.vue'
import Selo from './ui/Selo.vue'
import imagem1 from '../images/imgs-banner/img-banner.png'
import imagem2 from '../images/imgs-banner/img-banner2 (2).png'
import imagem3 from '../images/imgs-banner/img-banner3.png'

const slides = [
  {
    selo: 'Leitura que acolhe',
    titulo: ['Um mundo de histórias.', 'Um cantinho para você.'],
    texto: 'Leia, ouça e descubra novas possibilidades. No seu tempo, do seu jeito.',
    acao: 'Explorar o acervo',
    imagem: imagem1,
  },
  {
    selo: 'Clube do livro',
    titulo: ['Boas histórias ficam', 'melhores em companhia'],
    texto: 'Um espaço para conversar sobre livros, trocar ideias e criar novos laços.',
    acao: 'Conhecer o clube',
    imagem: imagem2,
  },
  {
    selo: 'Sorteio do livro do mês',
    titulo: ['Um livro muitas', 'novas descobertas'],
    texto: 'Um espaço para divulgar o livro do mês e as próximas atividades da biblioteca.',
    acao: 'Ver atividade do mês',
    imagem: imagem3,
  },
]

const INTERVALO = 6000
const atual = ref(0)
let timer = null

const pausar = () => {
  clearInterval(timer)
  timer = null
}

const iniciar = () => {
  pausar()
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return
  timer = setInterval(() => (atual.value = (atual.value + 1) % slides.length), INTERVALO)
}

const irPara = (indice) => {
  atual.value = indice
  iniciar() // recomeça a contagem depois do clique
}

onMounted(iniciar)
onBeforeUnmount(pausar)
</script>

<template>
  <div
    class="carrossel"
    aria-roledescription="carrossel"
    aria-label="Destaques"
    @mouseenter="pausar"
    @mouseleave="iniciar"
    @focusin="pausar"
    @focusout="iniciar"
  >
    <!-- O trilho tem os slides lado a lado e desliza para mostrar o atual -->
    <div class="carrossel-trilho" :style="{ transform: `translateX(-${atual * 100}%)` }">
      <!-- inert tira os slides escondidos do Tab e dos leitores de tela -->
      <section
        v-for="(slide, indice) in slides"
        :key="slide.selo"
        class="banner"
        :style="{ backgroundImage: `url('${slide.imagem}')` }"
        aria-roledescription="slide"
        :aria-label="`${indice + 1} de ${slides.length}`"
        :inert="atual !== indice"
      >
        <div class="banner-conteudo">
          <div class="banner-textos">
            <Selo>{{ slide.selo }}</Selo>
            <h1 class="banner-titulo">{{ slide.titulo[0] }}<br>{{ slide.titulo[1] }}</h1>
            <p class="banner-texto">{{ slide.texto }}</p>
          </div>

          <Botao class="banner-acao" to="/acervo-publico">{{ slide.acao }}</Botao>
        </div>
      </section>
    </div>

    <IndicadorBanner class="banner-indicador" :total="slides.length" :ativo="atual" @ir="irPara" />
  </div>
</template>

<style scoped>
.carrossel {
  position: relative;
  overflow: hidden; /* esconde os slides que estão fora da tela */
  border-radius: 0 0 var(--raio-40) var(--raio-40);
}

.carrossel-trilho {
  display: flex;
  transition: transform 0.8s ease-in-out;
}

@media (prefers-reduced-motion: reduce) {
  .carrossel-trilho {
    transition: none;
  }
}

/* ===== Cada slide: 661px de altura no Figma, texto no canto de baixo à esquerda ===== */
.banner {
  position: relative;
  flex: 0 0 100%;
  display: flex;
  align-items: flex-end;
  min-height: 661px;
  padding: var(--espaco-64) var(--espaco-48) 48px clamp(var(--espaco-24), 9.8vw, 141px);
  background-position: center;
  background-size: cover;
  color: var(--texto-inverso);
}

/* Escurece o canto de baixo à esquerda para o texto branco ter contraste (gradiente do Figma) */
.banner::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(211deg, rgb(213 234 245 / 0%) 6%, rgb(47 47 47 / 60%) 67%);
}

.banner-conteudo {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 34px;
  max-width: 509px;
}

.banner-textos {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-8);
}

.banner-titulo {
  font: var(--fonte-display);
}

.banner-texto {
  font: var(--fonte-corpo);
}

.banner-acao {
  min-width: 260px;
}

/* Pontos centralizados, 12px acima da borda de baixo como no Figma */
.banner-indicador {
  position: absolute;
  bottom: 14px;
  left: 50%;
  transform: translateX(-50%);
}

/* ===== Telas menores: o menu vira uma barra no topo, o banner só precisa de menos altura ===== */
@media (max-width: 1024px) {
  .banner {
    min-height: 560px;
  }

  .banner-titulo {
    font: var(--fonte-titulo);
  }
}

@media (max-width: 768px) {
  .banner {
    min-height: 520px;
    padding: var(--espaco-48) var(--espaco-24) 64px;
  }

  /* O texto ocupa a largura toda: o escuro passa a subir de baixo para cima */
  .banner::before {
    background: linear-gradient(to top, rgb(47 47 47 / 85%) 0%, rgb(47 47 47 / 55%) 45%, transparent 80%);
  }

  .banner-conteudo {
    max-width: none;
    gap: var(--espaco-24);
  }
}

@media (max-width: 475px) {
  .banner {
    padding-inline: var(--espaco-16);
  }

  .banner-acao {
    align-self: stretch; /* botão na largura toda, mais fácil de tocar */
    min-width: 0;
  }
}
</style>
