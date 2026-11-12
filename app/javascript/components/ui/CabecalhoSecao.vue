<!--
  Cabeçalho de seção (Figma: "Cabeçalho de seção"). Abre cada seção de conteúdo.
  A ilustração pequena (dos adesivos) vai no slot "ilustracao", como uma <img>;
  é decorativa, então fica escondida de leitores de tela (use alt="").
  "nivel" é o nível do título (2 = h2); use o que couber na estrutura da página.
-->
<script setup>
defineProps({
  titulo: { type: String, required: true },
  subtitulo: { type: String, default: '' },
  nivel: { type: Number, default: 2, validator: (valor) => valor >= 1 && valor <= 6 },
})
</script>

<template>
  <header class="cabecalho-secao">
    <div v-if="$slots.ilustracao" class="cabecalho-secao-ilustracao" aria-hidden="true">
      <slot name="ilustracao" />
    </div>

    <div class="cabecalho-secao-textos">
      <component :is="`h${nivel}`" class="cabecalho-secao-titulo">{{ titulo }}</component>
      <p v-if="subtitulo" class="cabecalho-secao-subtitulo">{{ subtitulo }}</p>
    </div>
  </header>
</template>

<style scoped>
.cabecalho-secao {
  display: flex;
  align-items: center;
  gap: var(--espaco-12);
}

.cabecalho-secao-ilustracao {
  width: 73px;
  height: 89px;
  flex-shrink: 0;
}

.cabecalho-secao-ilustracao :slotted(img) {
  width: 100%;
  height: 100%;
  object-fit: contain; /* a ilustração aparece inteira, qualquer que seja a proporção dela */
}

.cabecalho-secao-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.cabecalho-secao-subtitulo {
  color: var(--texto-secundario);
  font: var(--fonte-subtitulo);
}
</style>
