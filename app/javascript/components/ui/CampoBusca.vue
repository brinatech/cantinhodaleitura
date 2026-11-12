<!--
  Campo de busca (Figma: "Campo de busca"). Busca do acervo (RF04).
  É um <input type="search"> com v-model. Sempre com nome acessível: "rotulo"
  vira o aria-label (mostre um label visível ao lado quando o layout permitir).
  Foco: anel de 2px. Ouça a tecla Enter no próprio componente: @keyup.enter="buscar".
-->
<script setup>
import Icone from './Icone.vue'

defineProps({
  rotulo: { type: String, default: 'Buscar livros' },
  placeholder: { type: String, default: 'Busque por título ou autor' },
})

const texto = defineModel({ type: String, default: '' })
</script>

<template>
  <label class="campo-busca">
    <Icone nome="busca" :tamanho="20" />
    <input v-model="texto" class="campo-busca-entrada" type="search" :placeholder="placeholder" :aria-label="rotulo">
  </label>
</template>

<style scoped>
.campo-busca {
  display: flex;
  align-items: center;
  gap: var(--espaco-12);
  width: 100%;
  height: 52px;
  padding: 0 var(--espaco-16);
  border-radius: var(--raio-total);
  background: var(--fundo-superficie);
  /* Anel interno como o traço do Figma: o foco não muda o tamanho */
  box-shadow: inset 0 0 0 1.5px var(--borda-padrao);
  color: var(--texto-principal);
  cursor: text;
}

.campo-busca:focus-within,
.campo-busca.estado-foco {
  box-shadow: inset 0 0 0 2px var(--borda-foco);
}

.campo-busca-entrada {
  flex: 1;
  min-width: 0;
  border: 0;
  background: transparent;
  color: var(--texto-corpo);
  font: var(--fonte-interface);
  outline: none; /* o anel do campo é o indicador de foco */
}

.campo-busca-entrada::placeholder {
  color: var(--texto-secundario);
  opacity: 1;
}
</style>
