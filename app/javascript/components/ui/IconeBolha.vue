<!--
  Ícone em bolha (Figma: "Ícone em bolha"). Ícone dentro de um círculo colorido,
  estilo adesivo. Use no menu lateral, nos destaques de recursos e nas categorias.
  O ícone é sempre azul escuro. "tamanho" é o diâmetro (48 no Figma; 36 e 40 em
  algumas telas); o ícone ocupa metade dele, ou "tamanhoIcone" quando o Figma
  fixa outro (a bolha de 36 leva ícone de 24, por exemplo).
-->
<script setup>
import Icone from './Icone.vue'

defineProps({
  cor: {
    type: String,
    default: 'ceu',
    validator: (valor) => ['ceu', 'laranja', 'rosa', 'coral', 'suave'].includes(valor),
  },
  icone: { type: String, default: 'livro' },
  tamanho: { type: Number, default: 48 },
  tamanhoIcone: { type: Number, default: null },
})
</script>

<template>
  <span class="bolha" :class="`bolha--${cor}`" :style="{ '--tamanho': `${tamanho}px` }">
    <Icone :nome="icone" :tamanho="tamanhoIcone ?? tamanho / 2" />
  </span>
</template>

<style scoped>
.bolha {
  --fundo: var(--destaque-ceu);

  display: inline-flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  width: var(--tamanho);
  height: var(--tamanho);
  border-radius: var(--raio-total);
  background: var(--fundo);
  color: var(--texto-sobre-cor);
}

.bolha--laranja {
  --fundo: var(--apoio-laranja);
}

.bolha--rosa {
  --fundo: var(--apoio-rosa);
}

.bolha--coral {
  --fundo: var(--apoio-coral);
}

.bolha--suave {
  --fundo: var(--fundo-suave);
  color: var(--texto-principal); /* fundo suave: segue o tema */
}
</style>
