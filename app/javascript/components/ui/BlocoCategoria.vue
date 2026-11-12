<!--
  Bloco de categoria (Figma: "Bloco de categoria"). Atalho "Explorar por categoria".
  Cada categoria tem cor e ícone próprios (a cor se repete no card, no chip e no
  selo do livro). "categoria" é o nome como vem da API; "quantidade" é o texto
  ("12 livros"). Com "to" vira link do router.
-->
<script setup>
import { computed } from 'vue'
import { RouterLink } from 'vue-router'
import Icone from './Icone.vue'
import { chaveCategoria } from './categorias.js'

const props = defineProps({
  categoria: { type: String, required: true },
  quantidade: { type: String, default: '' },
  to: { type: [String, Object], default: null },
})

const iconesPorCategoria = {
  aventura: 'bussola',
  fantasia: 'varinha',
  natureza: 'folha',
  classicos: 'livro',
}

const chave = computed(() => chaveCategoria(props.categoria))
const icone = computed(() => iconesPorCategoria[chave.value] ?? 'livro')
const tag = computed(() => (props.to ? RouterLink : 'div'))
</script>

<template>
  <component :is="tag" class="bloco" :class="`cat-${chave}`" :to="to ?? undefined">
    <span class="bloco-bolha"><Icone :nome="icone" :tamanho="32" /></span>
    <span class="bloco-nome">{{ categoria }}</span>
    <span v-if="quantidade" class="bloco-quantidade">{{ quantidade }}</span>
  </component>
</template>

<style scoped>
.bloco {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-12);
  width: 100%;
  padding: var(--espaco-24);
  border: 2px solid var(--cat);
  border-radius: var(--raio-20);
  background: var(--cat-suave);
  color: var(--texto-principal);
  text-decoration: none;
}

.bloco:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 3px;
}

.bloco-bolha {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  border-radius: var(--raio-total);
  background: var(--cat);
}

.bloco-nome {
  font: var(--fonte-titulo-cartao);
}

.bloco-quantidade {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}
</style>
