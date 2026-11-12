<!--
  Barra de progresso (Figma: "Barra de progresso"). Progresso de leitura ou
  conquista, com gradiente laranja → coral. "progresso" vai de 0 a 100.
  "rotulo" (ex.: "Página 12 de 28") e "valor" (ex.: "45%") são os textos acima
  da barra. É um role="progressbar" com aria-valuenow.
-->
<script setup>
import { computed } from 'vue'

const props = defineProps({
  progresso: { type: Number, required: true },
  rotulo: { type: String, default: '' },
  valor: { type: String, default: '' },
})

const porcento = computed(() => Math.min(100, Math.max(0, props.progresso)))
</script>

<template>
  <div class="progresso">
    <div v-if="rotulo || valor" class="progresso-textos">
      <span class="progresso-rotulo">{{ rotulo }}</span>
      <span class="progresso-valor">{{ valor }}</span>
    </div>

    <div
      class="progresso-trilho"
      role="progressbar"
      :aria-label="rotulo || 'Progresso'"
      :aria-valuenow="porcento"
      aria-valuemin="0"
      aria-valuemax="100"
      :aria-valuetext="valor || undefined"
    >
      <div class="progresso-preenchido" :style="{ width: `${porcento}%` }"></div>
    </div>
  </div>
</template>

<style scoped>
.progresso {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
  width: 100%;
}

.progresso-textos {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--espaco-8);
}

.progresso-rotulo {
  color: var(--texto-principal);
  font: var(--fonte-botao);
}

.progresso-valor {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}

.progresso-trilho {
  height: 12px;
  overflow: hidden;
  border-radius: var(--raio-total);
  background: var(--fundo-suave);
}

.progresso-preenchido {
  height: 100%;
  border-radius: var(--raio-total);
  background: linear-gradient(90deg, var(--apoio-laranja), var(--apoio-coral));
}
</style>
