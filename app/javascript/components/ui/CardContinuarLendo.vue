<!--
  Card continuar lendo (Figma: "Card continuar lendo"). Retomar leitura ou
  audiobook em Minhas leituras (RF11: histórico e marcador).
  layout: "horizontal" (largo, ação à direita) ou "vertical" (card de coluna).
  formato: "texto" usa o botão Principal; "audiobook" usa o Destaque (laranja).
  A cor da capa e do ponto vêm da categoria (nome como vem da API).
  A ação é um botão; com "to" vira link do router, e sem "to" avisa por @click.
-->
<script setup>
import { computed } from 'vue'
import BarraProgresso from './BarraProgresso.vue'
import Botao from './Botao.vue'
import Icone from './Icone.vue'
import { chaveCategoria } from './categorias.js'

const props = defineProps({
  titulo: { type: String, required: true },
  detalhe: { type: String, default: '' },
  categoria: { type: String, default: '' },
  formato: {
    type: String,
    default: 'texto',
    validator: (valor) => ['texto', 'audiobook'].includes(valor),
  },
  layout: {
    type: String,
    default: 'horizontal',
    validator: (valor) => ['horizontal', 'vertical'].includes(valor),
  },
  progresso: { type: Number, default: 0 },
  rotuloProgresso: { type: String, default: '' },
  to: { type: [String, Object], default: null },
})

const audiobook = computed(() => props.formato === 'audiobook')
const vertical = computed(() => props.layout === 'vertical')
const icone = computed(() => (audiobook.value ? 'fones' : 'livro'))
const rotuloCategoria = computed(() => props.categoria || 'Diversos')
</script>

<template>
  <article
    class="continuar"
    :class="[`continuar--${layout}`, `cat-${chaveCategoria(categoria)}`]"
  >
    <div class="continuar-capa">
      <Icone :nome="icone" :tamanho="vertical ? 44 : 36" />

      <template v-if="vertical">
        <span class="pilula pilula-categoria">
          <span class="pilula-ponto" aria-hidden="true"></span>
          {{ rotuloCategoria }}
        </span>
        <span class="pilula pilula-formato">
          <Icone :nome="icone" :tamanho="14" />
          {{ audiobook ? 'Audiobook' : 'Leitura' }}
        </span>
      </template>
    </div>

    <div class="continuar-info">
      <span v-if="!vertical" class="pilula pilula-linha">
        <span class="pilula-ponto" aria-hidden="true"></span>
        {{ rotuloCategoria }}
      </span>
      <h3 class="continuar-titulo">{{ titulo }}</h3>
      <p v-if="detalhe" class="continuar-detalhe">{{ detalhe }}</p>
      <BarraProgresso :progresso="progresso" :rotulo="rotuloProgresso" :valor="`${Math.round(progresso)}%`" />
    </div>

    <Botao class="continuar-acao" :tipo="audiobook ? 'destaque' : 'principal'" :to="to">
      <template #icone><Icone :nome="icone" /></template>
      {{ audiobook ? 'Continuar ouvindo' : 'Continuar leitura' }}
    </Botao>
  </article>
</template>

<style scoped>
.continuar {
  display: flex;
  border: 1px solid var(--borda-padrao);
  border-radius: var(--raio-20);
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-cartao);
}

/* ===== Horizontal ===== */
.continuar--horizontal {
  align-items: center;
  gap: var(--espaco-24);
  width: 100%;
  padding: var(--espaco-16) var(--espaco-24) var(--espaco-16) var(--espaco-16);
}

.continuar--horizontal .continuar-capa {
  width: 112px;
  height: 148px;
}

.continuar--horizontal .continuar-info {
  flex: 1;
  min-width: 0;
  gap: 6px;
}

/* ===== Vertical ===== */
.continuar--vertical {
  flex-direction: column;
  gap: var(--espaco-12);
  width: 100%;
  padding: var(--espaco-16);
}

.continuar--vertical .continuar-capa {
  width: 100%;
  height: 180px;
}

.continuar--vertical .continuar-info {
  gap: var(--espaco-12);
}

.continuar--vertical .continuar-acao {
  width: 100%;
}

/* ===== Peças ===== */
.continuar-capa {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  overflow: hidden;
  border-radius: var(--raio-12);
  background: var(--cat-capa);
  color: var(--texto-principal);
}

.continuar-info {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

.continuar-info > .progresso {
  width: 100%;
}

.continuar-titulo {
  color: var(--texto-principal);
  font: var(--fonte-subtitulo);
}

.continuar-detalhe {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}

.pilula {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: var(--espaco-4) 10px var(--espaco-4) var(--espaco-8);
  border-radius: var(--raio-total);
  background: var(--fundo-superficie);
  color: var(--texto-principal);
  font: var(--fonte-rotulo);
  letter-spacing: var(--letras-rotulo);
  text-transform: uppercase;
  white-space: nowrap;
}

.pilula-categoria,
.pilula-formato {
  position: absolute;
  top: 10px;
}

.pilula-categoria {
  left: 10px;
}

.pilula-formato {
  right: var(--espaco-8);
}

.pilula-linha {
  border: 1px solid var(--borda-padrao);
}

.pilula-ponto {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: var(--cat);
}
</style>
