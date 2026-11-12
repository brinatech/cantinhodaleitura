<!--
  Barra do leitor (Figma: "Barra do leitor"). Ações do leitor de texto (RF10/RF11):
  voltar, ajustar texto, ouvir e salvar marcador, mais o "Página X de Y".
  Eventos: ajustar, ouvir, marcador. "Voltar ao livro" vira link com "voltarPara"
  (rota do router) ou avisa por @voltar.
-->
<script setup>
import Botao from './Botao.vue'
import Icone from './Icone.vue'

defineProps({
  pagina: { type: String, default: '' },
  voltarPara: { type: [String, Object], default: null },
})

defineEmits(['voltar', 'ajustar', 'ouvir', 'marcador'])
</script>

<template>
  <nav class="barra-leitor" aria-label="Ações do leitor">
    <Botao tipo="contorno" :to="voltarPara" @click="$emit('voltar')">
      <template #icone><Icone nome="seta-esquerda" /></template>
      Voltar ao livro
    </Botao>
    <Botao tipo="contorno" @click="$emit('ajustar')">
      <template #icone><Icone nome="texto" /></template>
      Ajustar texto
    </Botao>
    <Botao tipo="contorno" @click="$emit('ouvir')">
      <template #icone><Icone nome="fones" /></template>
      Ouvir
    </Botao>
    <Botao tipo="contorno" @click="$emit('marcador')">
      <template #icone><Icone nome="marcador" /></template>
      Salvar marcador
    </Botao>
    <span v-if="pagina" class="barra-leitor-pagina">{{ pagina }}</span>
  </nav>
</template>

<style scoped>
.barra-leitor {
  display: inline-flex;
  align-items: center;
  flex-wrap: wrap;
  gap: var(--espaco-12);
  padding: var(--espaco-12);
  border: 1px solid var(--borda-padrao);
  border-radius: var(--raio-total);
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-cartao);
}

.barra-leitor-pagina {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}
</style>
