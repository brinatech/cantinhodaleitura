<script setup>
import MenuSuperior from '../components/layout/MenuSuperior.vue'
import Rodape from '../components/layout/Rodape.vue'
import Botao from '../components/ui/Botao.vue'
</script>

<template>
  <div class="pagina-404">
    <MenuSuperior />
    <main class="conteudo" aria-labelledby="titulo-404">
      <span class="codigo" aria-hidden="true">404</span>
      <h1 id="titulo-404">Não encontramos essa página</h1>
      <p>O endereço pode estar incorreto ou a página pode ter sido movida.</p>
      <Botao to="/">Voltar ao início</Botao>
    </main>
    <Rodape />
  </div>
</template>

<style scoped>
.pagina-404 { min-height: 100vh; display: flex; flex-direction: column; background: var(--fundo-pagina); color: var(--texto-corpo); font: var(--fonte-interface); }
.conteudo { flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: var(--espaco-64) var(--espaco-24); text-align: center; }
.codigo { color: var(--destaque-escuro); font: var(--fonte-display); }
h1 { margin: var(--espaco-16) 0; color: var(--texto-principal); font: var(--fonte-titulo); }
p { margin: 0 0 var(--espaco-24); }
</style>
