<!--
  Tag de formato (Figma: "Tag de formato"). Indica o formato disponível do livro
  (texto, audiobook, Libras...). Só mostrar formatos que realmente existem para
  o material. O texto vai no slot; o ícone (16px) é o Fones, a menos que se
  passe outro em "icone".
-->
<script setup>
import Icone from './Icone.vue'

defineProps({
  icone: { type: String, default: 'fones' },
})
</script>

<template>
  <span class="tag-formato">
    <Icone :nome="icone" :tamanho="16" />
    <slot />
  </span>
</template>

<style scoped>
.tag-formato {
  display: inline-flex;
  align-items: center;
  gap: var(--espaco-8);
  padding: var(--espaco-4) var(--espaco-12);
  border-radius: var(--raio-8);
  background: var(--fundo-suave);
  color: var(--texto-principal);
  font: var(--fonte-legenda);
  white-space: nowrap;
}
</style>
