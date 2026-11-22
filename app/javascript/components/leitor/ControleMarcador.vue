<!--
  Aviso "Você parou na página X" (HU-15 Task 3), mostrado em cima do leitor ao abrir o livro.
  Não pula de página sozinho: a pessoa escolhe continuar de onde parou ou ler do início.
-->
<script setup>
import Botao from '../ui/Botao.vue'
import Icone from '../ui/Icone.vue'

defineProps({
  pagina: { type: Number, required: true },
})

defineEmits(['continuar', 'dispensar'])
</script>

<template>
  <div class="marcador" role="status">
    <span class="marcador-icone" aria-hidden="true"><Icone nome="marcador" /></span>
    <p class="marcador-texto">Você parou na <strong>página {{ pagina }}</strong>.</p>
    <div class="marcador-acoes">
      <Botao @click="$emit('continuar')">Continuar da página {{ pagina }}</Botao>
      <Botao tipo="contorno" @click="$emit('dispensar')">Ler do início</Botao>
    </div>
  </div>
</template>

<style scoped>
.marcador {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: var(--espaco-12) var(--espaco-16);
  padding: var(--espaco-16);
  border-radius: var(--raio-20);
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-cartao);
}

.marcador-icone {
  display: inline-flex;
  padding: var(--espaco-8);
  border-radius: var(--raio-total);
  background: var(--fundo-suave);
  color: var(--texto-principal);
}

.marcador-texto {
  flex: 1;
  min-width: 16ch;
  color: var(--texto-corpo);
  font: var(--fonte-corpo);
}

.marcador-texto strong {
  color: var(--texto-principal);
}

.marcador-acoes {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-8);
}
</style>
