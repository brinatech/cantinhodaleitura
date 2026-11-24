<script setup>
// Link "Pular para o conteúdo" (HU-16). Não usa href="#id": o roteador é por hash (/#/rota)
// e uma âncora trocaria de tela. Em vez disso, leva o foco ao <main> (ou ao <h1>, se a tela não tiver <main>).
function pularParaConteudo() {
  const alvo = document.querySelector('main') ?? document.querySelector('h1')
  if (!alvo) return
  alvo.setAttribute('tabindex', '-1') // só para poder receber foco por código; não entra na ordem do Tab
  alvo.focus()
  alvo.scrollIntoView()
}
</script>

<template>
  <!-- Moldura do app: só mostra a tela da rota atual (ver router/index.js).
       Cada view decide seu cabeçalho (variante) e se tem rodapé. -->
  <a class="pular-conteudo" href="#conteudo" @click.prevent="pularParaConteudo">Pular para o conteúdo</a>
  <RouterView />
</template>

<style>
/* Escondido até receber foco pelo teclado (primeiro Tab da página) */
.pular-conteudo {
  position: fixed;
  top: 8px;
  left: 8px;
  z-index: 1000;
  padding: 12px 20px;
  border-radius: 8px;
  background: var(--texto-principal);
  color: var(--fundo-superficie);
  font: var(--fonte-botao);
  transform: translateY(-200%);
}

.pular-conteudo:focus-visible {
  transform: none;
  outline: 3px solid var(--borda-foco);
  outline-offset: 2px;
}
</style>
