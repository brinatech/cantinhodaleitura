<!--
  Selo (Figma: "Selo"). Rótulo curto em caixa alta acima de títulos de seção
  (eyebrow) e para categorias. O texto vai no slot.
  Tons: ceu, suave, coral, laranja, rosa.
-->
<script setup>
defineProps({
  tom: {
    type: String,
    default: 'ceu',
    validator: (valor) => ['ceu', 'suave', 'coral', 'laranja', 'rosa'].includes(valor),
  },
})
</script>

<template>
  <span class="selo" :class="`selo--${tom}`"><slot /></span>
</template>

<style scoped>
.selo {
  --fundo: var(--destaque-ceu);
  --cor: var(--texto-principal);

  display: inline-flex;
  align-items: center;
  padding: var(--espaco-4) var(--espaco-12);
  border-radius: var(--raio-total);
  background: var(--fundo);
  color: var(--cor);
  font: var(--fonte-rotulo);
  letter-spacing: var(--letras-rotulo);
  text-transform: uppercase;
  white-space: nowrap;
}

.selo--suave {
  --fundo: var(--fundo-suave);
}

.selo--coral {
  --fundo: var(--apoio-coral-suave);
  --cor: var(--texto-erro);
}

.selo--laranja {
  --fundo: var(--apoio-laranja-suave);
}

.selo--rosa {
  --fundo: var(--apoio-rosa-suave);
}
</style>
