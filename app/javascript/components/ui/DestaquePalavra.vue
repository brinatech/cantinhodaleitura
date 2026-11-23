<!--
  Destaque de palavra (Figma: "Destaque de palavra"). Marca-texto atrás de UMA
  palavra do título (ex.: "Encontre sua próxima <história>"). No máximo uma vez
  por seção. Herda o tamanho do título onde está (as medidas são em em).
  Cores: rosa, laranja, ceu.
-->
<script setup>
defineProps({
  cor: {
    type: String,
    default: 'rosa',
    validator: (valor) => ['rosa', 'laranja', 'ceu'].includes(valor),
  },
})
</script>

<template>
  <mark class="destaque" :class="`destaque--${cor}`"><slot /></mark>
</template>

<style scoped>
.destaque {
  --marca: var(--apoio-rosa);

  position: relative;
  z-index: 0; /* cria o contexto para o marca-texto ficar atrás do texto */
  display: inline-block;
  padding: 0 var(--espaco-4);
  background: none;
  color: inherit;
  line-height: inherit;
}

/* Metade de baixo da linha, como no Figma (4.2px de baixo e 16px de altura a 32px de fonte) */
.destaque::before {
  content: '';
  position: absolute;
  z-index: -1;
  right: 0;
  bottom: 0.131em;
  left: 0;
  height: 0.499em;
  border-radius: 6px;
  background: var(--marca);
}

.destaque--laranja {
  --marca: var(--apoio-laranja);
}

.destaque--ceu {
  --marca: var(--destaque-ceu);
}
/* No tema escuro o marca-texto fica mais fraco: a regra está em styles/tema-escuro.css */
</style>
