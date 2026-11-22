<!--
  Interruptor (Figma: "Interruptor"). Liga/desliga ajustes (painel de acessibilidade).
  Ligado mostra a marca de check além da cor. É um <button role="switch"
  aria-checked> com v-model; a linha inteira é a área de toque.
-->
<script setup>
defineProps({
  rotulo: { type: String, required: true },
  descricao: { type: String, default: '' },
})

const ligado = defineModel({ type: Boolean, default: false })
</script>

<template>
  <button type="button" class="interruptor" role="switch" :aria-checked="ligado" @click="ligado = !ligado">
    <span class="interruptor-textos">
      <span class="interruptor-rotulo">{{ rotulo }}</span>
      <span v-if="descricao" class="interruptor-descricao">{{ descricao }}</span>
    </span>

    <span class="interruptor-trilho" :class="{ ligado }" aria-hidden="true">
      <!-- Marca de check: fica no trilho, ao lado do botão (como no Figma) -->
      <svg v-if="ligado" class="interruptor-marca" viewBox="0 0 48 28" fill="none">
        <path d="M10.5 14.25L12.75 16.5L17.5 11.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
      </svg>
      <span class="interruptor-botao"></span>
    </span>
  </button>
</template>

<style scoped>
.interruptor {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--espaco-16);
  width: 100%;
  min-height: 40px;
  padding: 0;
  border: 0;
  border-radius: var(--raio-8);
  background: transparent;
  text-align: left;
  cursor: pointer;
}

.interruptor:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 4px;
}

.interruptor-textos {
  display: flex;
  flex-direction: column;
}

.interruptor-rotulo {
  color: var(--texto-principal);
  font: var(--fonte-interface);
}

.interruptor-descricao {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}

.interruptor-trilho {
  position: relative;
  flex-shrink: 0;
  width: 48px;
  height: 28px;
  border-radius: var(--raio-total);
  background: var(--borda-padrao);
  color: var(--texto-inverso);
  transition: background-color var(--duracao-rapida) var(--curva);
}

.interruptor-trilho.ligado {
  background: var(--destaque-escuro);
}

/* Passar o mouse no interruptor desligado: o trilho escurece um pouco */
.interruptor:hover .interruptor-trilho:not(.ligado) {
  background: var(--borda-forte);
}

.interruptor-marca {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
}

.interruptor-botao {
  position: absolute;
  top: 3px;
  left: 3px;
  width: 22px;
  height: 22px;
  border-radius: 50%;
  background: white;
}

.interruptor-trilho.ligado .interruptor-botao {
  left: 23px;
}

/* A bolinha desliza ao ligar/desligar (só para quem não pediu menos movimento) */
@media (prefers-reduced-motion: no-preference) {
  .interruptor-botao {
    transition: left var(--duracao-rapida) var(--curva);
  }
}
</style>
