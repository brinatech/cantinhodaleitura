<template>
  <!-- Moldura do app: só mostra a tela atual.
       Cada view decide seu cabeçalho (variante) e se tem rodapé.
       Quando tiver o vue-router, trocar <HomeView /> por <RouterView />. -->
  <HomeView />
</template>

<script setup>
import HomeView from '../views/HomeView.vue'
</script>
