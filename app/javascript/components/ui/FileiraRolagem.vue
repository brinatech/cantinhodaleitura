<!--
  Fileira de cards que rola para o lado, com setas nas laterais (sem Figma: decisão da equipe).
  Usada nos "Livros em destaque" da home e em Minhas leituras ("Continue de onde parou" e "Novidades").
  No celular a fileira continua: aparece um card e meio (o pedaço do próximo mostra que tem mais)
  e dá para arrastar com o dedo. As setas só aparecem quando há cards escondidos: a ← some no
  começo, a → some no fim e, se tudo couber, nenhuma aparece.
  Cada card vem do slot: <FileiraRolagem :itens="livros"><template #default="{ item }">...</template></FileiraRolagem>
  Quem usa ajusta o visual por variáveis CSS (todas opcionais):
  --fileira-largura-item  largura de cada card (padrão 272px, a do Card de livro no Figma)
  --fileira-espaco        espaço entre os cards (padrão 16px)
  --fileira-respiro       espaço nas laterais da fileira (padrão 0)
  --fileira-alinhar       alinhamento dos cards quando sobram poucos (padrão: começo)
  --fileira-seta-lado     distância das setas até a borda (padrão: no meio do respiro, mínimo 8px)
-->
<script setup>
import { nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import Icone from './Icone.vue'

const props = defineProps({
  itens: { type: Array, required: true },
  chave: { type: Function, default: (item) => item.id },
  rotuloAnterior: { type: String, default: 'Ver livros anteriores' },
  rotuloProximo: { type: String, default: 'Ver próximos livros' },
})

const lista = ref(null)
const setaAnterior = ref(null)
const setaProxima = ref(null)
const podeVoltar = ref(false)
const podeAvancar = ref(false)
let observador = null

function atualizarSetas() {
  const el = lista.value
  if (!el) return
  const focoNaAnterior = document.activeElement === setaAnterior.value
  const focoNaProxima = document.activeElement === setaProxima.value

  podeVoltar.value = el.scrollLeft > 4
  podeAvancar.value = el.scrollLeft + el.clientWidth < el.scrollWidth - 4

  // A seta com o foco do teclado sumiu (chegou na ponta): o foco passa para a outra, em vez de se perder
  nextTick(() => {
    if (focoNaProxima && !podeAvancar.value) setaAnterior.value?.focus()
    if (focoNaAnterior && !podeVoltar.value) setaProxima.value?.focus()
  })
}

// Anda um card por clique (a largura de um card + o espaço entre eles)
function rolar(direcao) {
  const el = lista.value
  const card = el?.querySelector('.fileira-item')
  if (!card) return
  const passo = card.offsetWidth + parseFloat(getComputedStyle(el).columnGap || 0)
  const semMovimento =
    window.matchMedia('(prefers-reduced-motion: reduce)').matches || document.documentElement.hasAttribute('data-calmo')
  el.scrollBy({ left: direcao * passo, behavior: semMovimento ? 'auto' : 'smooth' })
}

// Vigia a rolagem e o tamanho da tela; se a quantidade de cards mudar, confere as setas de novo
onMounted(() => {
  lista.value.addEventListener('scroll', atualizarSetas, { passive: true })
  observador = new ResizeObserver(atualizarSetas)
  observador.observe(lista.value)
  atualizarSetas()
})

watch(() => props.itens.length, () => nextTick(atualizarSetas))

onBeforeUnmount(() => {
  lista.value?.removeEventListener('scroll', atualizarSetas)
  observador?.disconnect()
})
</script>

<template>
  <div class="fileira">
    <!-- v-aparecer + cascata: os cards entram um por um quando a fileira aparece na tela -->
    <ul ref="lista" v-aparecer class="fileira-lista aparecer-em-cascata">
      <li v-for="(item, indice) in itens" :key="chave(item)" class="fileira-item" :style="{ '--ordem': indice }">
        <slot :item="item" :indice="indice" />
      </li>
    </ul>

    <button
      v-if="podeVoltar"
      ref="setaAnterior"
      type="button"
      class="fileira-seta fileira-seta--anterior"
      :aria-label="rotuloAnterior"
      @click="rolar(-1)"
    >
      <Icone nome="seta-esquerda" :tamanho="28" />
    </button>
    <button
      v-if="podeAvancar"
      ref="setaProxima"
      type="button"
      class="fileira-seta fileira-seta--proxima"
      :aria-label="rotuloProximo"
      @click="rolar(1)"
    >
      <Icone nome="seta-direita" :tamanho="28" />
    </button>
  </div>
</template>

<style scoped>
.fileira {
  position: relative; /* referência das setas */
}

/* A folga em cima e embaixo deixa à mostra a sombra e o "levantar" dos cards (a rolagem corta o que passa da caixa) */
.fileira-lista {
  display: flex;
  justify-content: var(--fileira-alinhar, flex-start);
  gap: var(--fileira-espaco, var(--espaco-16));
  padding: var(--espaco-16) var(--fileira-respiro, 0px) var(--espaco-24);
  scroll-padding-inline: var(--fileira-respiro, 0px); /* o encaixe da rolagem respeita o respiro */
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  list-style: none;
  scrollbar-width: none;
}

.fileira-lista::-webkit-scrollbar {
  display: none;
}

/* Cards com a mesma altura, mesmo com título de 1 ou 2 linhas.
   Nunca mais largo que 75% da fileira: no celular sempre aparece um pedaço do próximo */
.fileira-item {
  display: flex;
  flex: 0 0 min(var(--fileira-largura-item, 272px), 75%);
  scroll-snap-align: start;
}

.fileira-item > * {
  flex: 1;
}

/* Setas: redondas, no mesmo estilo das setas do leitor de PDF */
.fileira-seta {
  position: absolute;
  top: 50%;
  z-index: 2;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 52px;
  height: 52px;
  padding: 0;
  border: 1.5px solid var(--borda-padrao);
  border-radius: 50%;
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-cartao);
  color: var(--texto-principal);
  cursor: pointer;
  transform: translateY(-50%);
  transition: transform var(--duracao-rapida) var(--curva), background-color var(--duracao-rapida) var(--curva);
}

.fileira-seta--anterior {
  left: var(--fileira-seta-lado, max(var(--espaco-8), calc(var(--fileira-respiro, 0px) / 2 - 26px)));
}

.fileira-seta--proxima {
  right: var(--fileira-seta-lado, max(var(--espaco-8), calc(var(--fileira-respiro, 0px) / 2 - 26px)));
}

.fileira-seta:hover {
  transform: translateY(-50%) scale(var(--crescer));
  background: color-mix(in srgb, var(--fundo-superficie), var(--texto-principal) 8%);
}

.fileira-seta:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 2px;
}

/* Celular: a seta fica por cima do card. Menor e meio transparente (dá para deslizar o dedo) */
@media (max-width: 640px) {
  .fileira-seta {
    width: 40px;
    height: 40px;
    background: color-mix(in srgb, var(--fundo-superficie) 85%, transparent);
  }
}
</style>
