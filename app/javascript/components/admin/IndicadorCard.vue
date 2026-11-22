<!--
  Card de um número do painel de relatórios (HU-22 Task 4): rótulo, valor grande e um detalhe opcional.
  O número vem em texto (nunca só em cor) e o rótulo vem antes, para o leitor de tela ler "Leituras: 95".
-->
<script setup>
import IconeBolha from '../ui/IconeBolha.vue'

defineProps({
  rotulo: { type: String, required: true },
  valor: { type: [Number, String], required: true },
  detalhe: { type: String, default: '' },
  icone: { type: String, default: 'livro' },
  cor: { type: String, default: 'ceu' },
})
</script>

<template>
  <article class="indicador">
    <IconeBolha :icone="icone" :cor="cor" :tamanho="40" :tamanho-icone="22" />
    <div class="indicador-textos">
      <h3 class="indicador-rotulo">{{ rotulo }}</h3>
      <p class="indicador-valor">{{ valor }}</p>
      <p v-if="detalhe" class="indicador-detalhe">{{ detalhe }}</p>
    </div>
  </article>
</template>

<style scoped>
.indicador {
  display: flex;
  align-items: flex-start;
  gap: var(--espaco-12);
  height: 100%;
  padding: var(--espaco-16);
  border: 1px solid var(--borda-padrao);
  border-radius: var(--raio-20);
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-cartao);
}

.indicador-textos {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-4);
  min-width: 0;
}

.indicador-rotulo {
  color: var(--texto-secundario);
  font: var(--fonte-rotulo);
  letter-spacing: var(--letras-rotulo);
  text-transform: uppercase;
}

.indicador-valor {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
  font-variant-numeric: tabular-nums;
}

.indicador-detalhe {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}
</style>
