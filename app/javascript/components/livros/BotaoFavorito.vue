<!--
  Botão de favoritar/desfavoritar um livro (HU-12 Task 3).
  O estado vem da store de favoritos e só muda depois que o servidor confirma.
  Só aparece para quem está logado. Se a sessão expirar, vai para o login e volta para esta mesma página.
  O texto do botão muda ("Favoritar" / "Tirar dos favoritos") e um aviso escondido confirma a ação ao leitor de tela.
-->
<script setup>
import { computed } from 'vue'
import Alerta from '../ui/Alerta.vue'
import Botao from '../ui/Botao.vue'
import Icone from '../ui/Icone.vue'
import { useFavoritar } from '../../composables/useFavoritar.js'

const props = defineProps({
  livroId: { type: [Number, String], required: true },
  titulo: { type: String, required: true },
})

const { alternar: alternarFavorito, erro, aviso, ehFavorito, estaPendente } = useFavoritar()

const favorito = computed(() => ehFavorito(props.livroId))
const pendente = computed(() => estaPendente(props.livroId))
const alternar = () => alternarFavorito(props.livroId, props.titulo)
</script>

<template>
  <div class="favorito">
    <Botao
      tipo="contorno"
      class="favorito-botao"
      :class="{ 'favorito-botao--ativo': favorito }"
      :disabled="pendente"
      @click="alternar"
    >
      <template #icone><Icone nome="coracao" /></template>
      {{ favorito ? 'Tirar dos favoritos' : 'Favoritar' }}
    </Botao>

    <p class="favorito-aviso" role="status">{{ aviso }}</p>
    <Alerta v-if="erro" tipo="erro">{{ erro }}</Alerta>
  </div>
</template>

<style scoped>
.favorito {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-8);
}

/* Só para leitor de tela */
.favorito-aviso {
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip-path: inset(50%);
  white-space: nowrap;
}

/* Favorito: coração cheio em coral */
.favorito-botao--ativo :deep(.botao-icone) {
  color: var(--apoio-coral);
}

.favorito-botao--ativo :deep(path) {
  fill: currentColor;
}
</style>
