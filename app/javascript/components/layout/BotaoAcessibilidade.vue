<!--
  Botão de acessibilidade das telas públicas (sem Figma: decisão da equipe).
  Redondo, só com o ícone; a etiqueta "Acessibilidade" aparece ao passar o mouse ou com o foco do teclado.
  Abre o mesmo painel "Ajustes de leitura" da área logada (PainelAcessibilidade): tamanho do texto,
  espaço entre linhas, contraste, modo calmo. Os ajustes valem no site todo e ficam salvos no navegador.
  Usado no menu da área pública (MenuSuperior) e na tela de entrar/cadastrar (AcessoView).
  O nome para o leitor de tela vem do aria-label; a etiqueta é só visual (para não ler duas vezes).
-->
<script setup>
import { ref } from 'vue'
import Icone from '../ui/Icone.vue'
import PainelAcessibilidade from './PainelAcessibilidade.vue'

const painel = ref(null)
</script>

<template>
  <span class="acessibilidade">
    <button type="button" class="acessibilidade-botao" aria-label="Acessibilidade" aria-haspopup="dialog" @click="painel.abrir()">
      <Icone nome="acessibilidade" />
      <span class="acessibilidade-etiqueta" aria-hidden="true">Acessibilidade</span>
    </button>

    <PainelAcessibilidade ref="painel" />
  </span>
</template>

<style scoped>
.acessibilidade {
  display: inline-flex;
  flex-shrink: 0;
}

.acessibilidade-botao {
  position: relative;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  padding: 0;
  border: 1.5px solid var(--borda-padrao);
  border-radius: 50%;
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-cartao); /* destaca do fundo (na home, da imagem do banner) */
  color: var(--texto-principal);
  cursor: pointer;
  transition: transform var(--duracao-rapida) var(--curva), background-color var(--duracao-rapida) var(--curva);
}

.acessibilidade-botao:hover {
  transform: scale(var(--crescer));
  background: color-mix(in srgb, var(--fundo-superficie), var(--texto-principal) 8%);
}

.acessibilidade-botao:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 3px;
}

/* Etiqueta embaixo do botão: aparece com o foco do teclado e, em quem tem mouse, ao passar o mouse */
.acessibilidade-etiqueta {
  position: absolute;
  top: calc(100% + var(--espaco-8));
  left: 50%;
  z-index: 10;
  padding: var(--espaco-4) var(--espaco-12);
  border-radius: var(--raio-8);
  background: var(--destaque-escuro);
  color: var(--texto-inverso);
  font: var(--fonte-legenda);
  white-space: nowrap;
  pointer-events: none;
  opacity: 0;
  transform: translateX(-50%);
  transition: opacity var(--duracao-rapida) var(--curva);
}

.acessibilidade-botao:focus-visible .acessibilidade-etiqueta {
  opacity: 1;
}

@media (hover: hover) {
  .acessibilidade-botao:hover .acessibilidade-etiqueta {
    opacity: 1;
  }
}
</style>
