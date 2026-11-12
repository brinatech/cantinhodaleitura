<!--
  Item de menu lateral (Figma: "Item de menu lateral"). Navegação do "Meu espaço".
  Cada item tem o seu ícone (nome em "icone"). Com "to" vira link do router e fica
  ativo sozinho na rota atual; sem "to", é <button>. "ativo" força o estado Ativo.
  O texto vai no slot.
-->
<script setup>
import { computed } from 'vue'
import { RouterLink } from 'vue-router'
import Icone from './Icone.vue'

const props = defineProps({
  icone: { type: String, required: true },
  to: { type: [String, Object], default: null },
  ativo: { type: Boolean, default: false },
})

const tag = computed(() => (props.to ? RouterLink : 'button'))
</script>

<template>
  <component
    :is="tag"
    class="item-menu"
    :class="{ ativo }"
    :to="to ?? undefined"
    :type="tag === 'button' ? 'button' : undefined"
    v-bind="ativo ? { 'aria-current': 'page' } : {}"
  >
    <Icone :nome="icone" :tamanho="20" />
    <slot />
  </component>
</template>

<style scoped>
.item-menu {
  display: flex;
  align-items: center;
  gap: var(--espaco-12);
  width: 100%;
  height: 48px;
  padding: 0 var(--espaco-16);
  border: 0;
  border-radius: var(--raio-12);
  background: transparent;
  color: var(--texto-principal);
  font: var(--fonte-interface);
  text-align: left;
  text-decoration: none;
  cursor: pointer;
}

/* Ativo: o RouterLink põe a classe sozinho na rota atual */
.item-menu.ativo,
.item-menu.router-link-exact-active {
  background: var(--destaque-ceu);
  font: var(--fonte-botao);
}

/* Anel interno de 2px, como o traço do Figma */
.item-menu:focus-visible,
.item-menu.estado-foco {
  box-shadow: inset 0 0 0 2px var(--borda-foco);
  outline: none;
}
</style>
