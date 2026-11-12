<script setup>
import MenuSuperior from '../components/layout/MenuSuperior.vue'
import Rodape from '../components/layout/Rodape.vue'
</script>

<template>
  <MenuSuperior />

  <main class="livro-detalhe">
    <!-- Conteúdo dos detalhes será desenvolvido aqui -->
  </main>

  <Rodape />
</template>

<style scoped>
.livro-detalhe {
  min-height: 60vh;
  background: var(--fundo-pagina);
}
</style>