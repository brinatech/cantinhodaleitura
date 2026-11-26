<!--
  Chip de filtro (Figma: "Chip de filtro"). Filtro do acervo.
  cor="neutro" para filtros gerais (Todos, formato); cor="<categoria>" para
  categorias de livro (aventura, fantasia, natureza, classicos; e as da equipe: infantil, poesia, ciencias).
  Selecionado sempre mostra o check além da cor. É um botão liga/desliga
  (aria-pressed). O texto vai no slot. O chip não troca de estado sozinho:
  quem usa controla, ex.: <ChipFiltro :selecionado="ativo" @click="ativo = !ativo">.
  Classicos selecionado usa o coral suave com borda coral, por contraste
  (texto escuro sobre coral cheio não passa).
-->
<script setup>
import Icone from './Icone.vue'
import { CATEGORIAS_COM_COR } from './categorias.js'

defineProps({
  cor: {
    type: String,
    default: 'neutro',
    validator: (valor) => ['neutro', ...CATEGORIAS_COM_COR].includes(valor),
  },
  selecionado: { type: Boolean, default: false },
})
</script>

<template>
  <button
    type="button"
    class="chip"
    :class="[`cat-${cor}`, { 'chip--selecionado': selecionado }]"
    :aria-pressed="selecionado"
  >
    <Icone v-if="selecionado" nome="check" :tamanho="16" />
    <span v-else-if="cor !== 'neutro'" class="chip-ponto" aria-hidden="true"></span>
    <slot />
  </button>
</template>

<style scoped>
.chip {
  --fundo: var(--fundo-superficie);
  --cor: var(--texto-principal);
  --anel-largura: 1.5px;
  --anel-cor: var(--borda-padrao);

  display: inline-flex;
  align-items: center;
  gap: var(--espaco-8);
  padding: var(--espaco-8) var(--espaco-16);
  border: 0;
  border-radius: var(--raio-total);
  background: var(--fundo);
  /* Anel interno como o traço do Figma: trocar de estado não muda o tamanho */
  box-shadow: inset 0 0 0 var(--anel-largura) var(--anel-cor);
  color: var(--cor);
  font: var(--fonte-botao);
  max-width: 100%; /* nome de categoria comprido quebra em linhas em vez de passar da tela */
  text-align: left;
  overflow-wrap: anywhere;
  cursor: pointer;
  transition: background-color var(--duracao-rapida) var(--curva);
}

/* Passar o mouse num chip não selecionado: fundo levemente mais escuro */
.chip:not(.chip--selecionado):hover {
  --fundo: color-mix(in srgb, var(--fundo-superficie), var(--texto-principal) 8%);
}

.chip-ponto {
  width: 12px;
  height: 12px;
  flex-shrink: 0;
  border-radius: 50%;
  background: var(--cat);
}

.chip--selecionado.cat-neutro {
  --fundo: var(--destaque-escuro);
  --cor: var(--texto-inverso);
  --anel-cor: var(--destaque-escuro);
}

.chip--selecionado:not(.cat-neutro) {
  --fundo: var(--cat);
  --cor: var(--texto-sobre-cor);
  --anel-cor: var(--cat);
}

.chip--selecionado.cat-classicos {
  --fundo: var(--cat-suave);
  --cor: var(--texto-principal); /* fundo suave: segue o tema */
  --anel-largura: 2.5px;
}

/* Foco por último: vale também para o chip selecionado */
.chip:focus-visible,
.chip.estado-foco {
  --anel-largura: 3px;
  --anel-cor: var(--borda-foco);
  outline: none; /* o anel acima é o indicador de foco */
}
</style>
