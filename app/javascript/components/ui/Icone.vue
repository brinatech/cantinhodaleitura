<!--
  Ícone do Cantinho (Figma: "Ícone/…"). 24px, traço 2px, cantos arredondados.
  Herda a cor do texto ao redor (currentColor). O traço fica em 2px em qualquer
  tamanho, como nos ícones de 16px do Figma.
  Decorativo por padrão (aria-hidden). Se estiver sozinho, sem texto ao lado,
  passe "rotulo" para virar uma imagem com nome acessível.
-->
<script setup>
import { icones } from './icones.js'

defineProps({
  nome: {
    type: String,
    required: true,
    validator: (valor) => valor in icones,
  },
  tamanho: { type: Number, default: 24 },
  rotulo: { type: String, default: null },
})
</script>

<template>
  <!-- v-html é seguro aqui: o SVG vem dos nossos arquivos, nunca de dado do usuário -->
  <span
    class="icone"
    :style="{ '--tamanho': `${tamanho}px` }"
    :role="rotulo ? 'img' : undefined"
    :aria-label="rotulo ?? undefined"
    :aria-hidden="rotulo ? undefined : 'true'"
    v-html="icones[nome]"
  ></span>
</template>

<style scoped>
.icone {
  display: inline-flex;
  flex-shrink: 0;
  width: var(--tamanho);
  height: var(--tamanho);
}

.icone :deep(svg) {
  width: 100%;
  height: 100%;
}

.icone :deep(path) {
  vector-effect: non-scaling-stroke; /* traço de 2px mesmo com o ícone em 16, 20 ou 48px */
}
</style>
