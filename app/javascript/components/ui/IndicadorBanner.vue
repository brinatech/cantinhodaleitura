<!--
  Indicador do banner (Figma: "Indicador do banner"). Pontos do banner rotativo
  da home, para ficar sobre a imagem. Cada ponto é um botão "Ir para o slide N".
  "ativo" é o índice (começa em 0) do slide atual; "ir" avisa qual foi escolhido.
  O ponto desenhado tem 12px como no Figma; a área de toque tem 24px.
-->
<script setup>
defineProps({
  total: { type: Number, default: 3 },
  ativo: { type: Number, default: 0 },
})

defineEmits(['ir'])
</script>

<template>
  <div class="indicador">
    <button
      v-for="n in total"
      :key="n"
      type="button"
      class="ponto"
      :class="{ ativo: ativo === n - 1 }"
      :aria-label="`Ir para o slide ${n}`"
      :aria-current="ativo === n - 1 ? 'true' : undefined"
      @click="$emit('ir', n - 1)"
    ></button>
  </div>
</template>

<style scoped>
.indicador {
  display: inline-flex;
  gap: var(--espaco-4);
}

.ponto {
  width: 24px;
  height: 24px;
  padding: 6px; /* 24 - 12 = ponto de 12px no meio da área de toque */
  border: 0;
  border-radius: 50%;
  background: white;
  background-clip: content-box;
  cursor: pointer;
}

.ponto.ativo {
  background-color: var(--destaque-ceu);
}

.ponto:focus-visible {
  outline: 2px solid white;
  outline-offset: 1px;
}
</style>
