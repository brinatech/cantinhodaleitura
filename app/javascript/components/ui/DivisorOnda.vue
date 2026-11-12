<!--
  Divisor de onda (Figma: "Divisor de onda"). Transição ondulada entre seções.
  Coloque no fim de uma seção com a cor da PRÓXIMA seção. Decorativo.
  Cores: nuvem, laranja-suave, rosa-suave, pagina, superficie.
-->
<script setup>
defineProps({
  cor: {
    type: String,
    default: 'nuvem',
    validator: (valor) => ['nuvem', 'laranja-suave', 'rosa-suave', 'pagina', 'superficie'].includes(valor),
  },
})
</script>

<template>
  <svg
    class="onda"
    :class="`onda--${cor}`"
    viewBox="0 0 1440 56"
    preserveAspectRatio="none"
    aria-hidden="true"
    focusable="false"
  >
    <path d="M0 46.8306V18.8306C180 -5.16937 360 -5.16937 540 12.8306C720 30.8306 900 42.8306 1080 24.8306C1260 6.83063 1350 -5.16937 1440 6.83063V46.8306H0Z" />
  </svg>
</template>

<style scoped>
.onda {
  --preenchimento: var(--fundo-nuvem);

  display: block;
  width: 100%;
  height: 56px;
  overflow: visible; /* a curva sobe um pouco acima do quadro, como no Figma */
}

.onda path {
  fill: var(--preenchimento);
}

.onda--laranja-suave {
  --preenchimento: var(--apoio-laranja-suave);
}

.onda--rosa-suave {
  --preenchimento: var(--apoio-rosa-suave);
}

.onda--pagina {
  --preenchimento: var(--fundo-pagina);
}

.onda--superficie {
  --preenchimento: var(--fundo-superficie);
}
</style>
