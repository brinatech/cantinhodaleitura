<!--
  Painel ilustrado da tela de acesso (Figma: "Painel ilustrado"). Fica à esquerda:
  imagem, logo e um cartão com os benefícios de ter conta. Só aparece em tela larga.
-->
<script setup>
import IconeBolha from '../ui/IconeBolha.vue'
import Selo from '../ui/Selo.vue'
import logo from '../../images/logo-header.png'
import fundo from '../../images/ilustracoes/acesso-painel.jpg'

const beneficios = [
  { texto: 'Leia e ouça no seu tempo', icone: 'livro', cor: 'laranja' },
  { texto: 'Ajuste o texto do seu jeito', icone: 'texto', cor: 'rosa' },
  { texto: 'Guarde favoritos e marcadores', icone: 'coracao', cor: 'ceu' },
]
</script>

<template>
  <aside class="painel" :style="{ backgroundImage: `url('${fundo}')` }">
    <img class="painel-logo" :src="logo" alt="Cantinho da Leitura" width="160">

    <div class="painel-mensagem">
      <Selo>Leitura que acolhe</Selo>
      <p class="painel-titulo">Toda história pode ser um novo começo.</p>
      <ul class="painel-lista">
        <li v-for="item in beneficios" :key="item.texto" class="painel-item">
          <IconeBolha :icone="item.icone" :cor="item.cor" :tamanho="36" :tamanho-icone="24" />
          {{ item.texto }}
        </li>
      </ul>
    </div>
  </aside>
</template>

<style scoped>
.painel {
  position: relative;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding: var(--espaco-32);
  overflow: hidden;
  border-radius: var(--raio-40);
  background-position: center;
  background-size: cover;
}

.painel-logo {
  align-self: flex-start;
  box-sizing: content-box;
  padding: 10px var(--espaco-16);
  border-radius: var(--raio-20);
  background: var(--fundo-superficie);
}

.painel-mensagem {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 14px;
  padding: 28px;
  border-radius: 28px;
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-flutuante);
}

.painel-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo-cartao);
}

.painel-lista {
  display: flex;
  flex-direction: column;
  gap: 14px;
  list-style: none;
}

.painel-item {
  display: flex;
  align-items: center;
  gap: var(--espaco-12);
  color: var(--texto-corpo);
  font: var(--fonte-interface);
}
</style>
