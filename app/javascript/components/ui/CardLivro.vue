<!--
  Card de livro (Figma: "Card de livro"). Largura fluida: quem usa decide a coluna.
  A categoria (nome como vem da API, ex.: "Fantasia") define a cor provisória da
  capa e o selo de categoria. Com "capaUrl" a imagem da capa substitui a cor.
  Título com até 2 linhas. O título é o link do card (com "to") e o clique vale
  para o card inteiro; o coração (favoritar) é um botão à parte.
  O estado Foco do Figma aparece quando o link do título recebe foco do teclado.
-->
<script setup>
import { computed } from 'vue'
import { RouterLink } from 'vue-router'
import Icone from './Icone.vue'
import TagFormato from './TagFormato.vue'
import { chaveCategoria } from './categorias.js'

const props = defineProps({
  titulo: { type: String, required: true },
  autor: { type: String, default: '' },
  categoria: { type: String, default: '' },
  capaUrl: { type: String, default: null },
  formato: { type: String, default: '' }, // ex.: "Texto e audiobook". Vazio = não mostra a tag
  iconeFormato: { type: String, default: 'fones' }, // ícone da tag: "fones" com áudio, "livro" só texto
  to: { type: [String, Object], default: null },
  mostrarCategoria: { type: Boolean, default: true },
  mostrarFavoritar: { type: Boolean, default: true },
})

defineEmits(['favoritar'])

const chave = computed(() => chaveCategoria(props.categoria))
const rotuloCategoria = computed(() => props.categoria || 'Diversos')
</script>

<template>
  <article class="card" :class="`cat-${chave}`">
    <p class="card-marca" aria-hidden="true">Cantinho · da · leitura</p>

    <div class="card-capa">
      <img v-if="capaUrl" class="card-capa-img" :src="capaUrl" alt="">
      <Icone v-else class="card-capa-icone" nome="livro" :tamanho="48" />

      <span v-if="mostrarCategoria" class="card-categoria">
        <span class="card-categoria-ponto" aria-hidden="true"></span>
        {{ rotuloCategoria }}
      </span>

      <button
        v-if="mostrarFavoritar"
        type="button"
        class="card-favoritar"
        :aria-label="`Favoritar ${titulo}`"
        @click="$emit('favoritar')"
      >
        <Icone nome="coracao" :tamanho="20" />
      </button>
    </div>

    <div class="card-info">
      <h3 class="card-titulo">
        <RouterLink v-if="to" class="card-link" :to="to">{{ titulo }}</RouterLink>
        <template v-else>{{ titulo }}</template>
      </h3>
      <p v-if="autor" class="card-autor">{{ autor }}</p>
    </div>

    <TagFormato v-if="formato" :icone="iconeFormato">{{ formato }}</TagFormato>
  </article>
</template>

<style scoped>
.card {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--espaco-12);
  width: 100%;
  padding: var(--espaco-16);
  border: 1px solid var(--borda-padrao);
  border-radius: var(--raio-20);
  background: var(--fundo-pagina);
  box-shadow: var(--sombra-cartao);
}

/* Foco (Figma): borda de 3px. Parte do traço vem do anel interno, para o card não mudar de tamanho */
.card:has(.card-link:focus-visible),
.card.estado-foco {
  border-color: var(--borda-foco);
  box-shadow: inset 0 0 0 2px var(--borda-foco), var(--sombra-cartao);
}

.card-marca {
  color: var(--texto-principal);
  font: var(--fonte-selo);
  letter-spacing: var(--letras-selo);
  text-transform: uppercase;
  white-space: nowrap;
}

/* ===== Capa ===== */
.card-capa {
  position: relative;
  width: 100%;
  height: 260px;
  flex-shrink: 0;
  overflow: hidden;
  border-radius: var(--raio-12);
  background: var(--cat-capa);
}

.card-capa-img {
  width: 100%;
  height: 100%;
  object-fit: contain; /* capas reais são verticais: não corta título nem autor; sobra o fundo da categoria */
}

.card-capa-icone {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: var(--texto-principal);
}

.card-categoria {
  position: absolute;
  top: var(--espaco-8);
  left: var(--espaco-8);
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: var(--espaco-4) 10px var(--espaco-4) var(--espaco-8);
  border-radius: var(--raio-total);
  background: var(--fundo-superficie);
  color: var(--texto-principal);
  font: var(--fonte-rotulo);
  letter-spacing: var(--letras-rotulo);
  text-transform: uppercase;
  white-space: nowrap;
}

.card-categoria-ponto {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: var(--cat);
}

.card-favoritar {
  position: absolute;
  top: var(--espaco-8);
  right: var(--espaco-8);
  z-index: 1; /* acima da área clicável do link do título */
  display: inline-flex;
  padding: var(--espaco-8);
  border: 0;
  border-radius: var(--raio-total);
  background: var(--fundo-superficie);
  color: var(--texto-principal);
  cursor: pointer;
}

.card-favoritar:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 2px;
}

/* ===== Informações ===== */
.card-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--espaco-4);
  width: 100%;
  text-align: center;
}

.card-titulo {
  display: -webkit-box;
  width: 100%;
  height: 48px; /* 2 linhas */
  overflow: hidden;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  color: var(--texto-principal);
  font: var(--fonte-botao);
}

.card-link {
  color: inherit;
  text-decoration: none;
}

.card-link:focus-visible {
  outline: none; /* o foco aparece na borda do card (regra acima) */
}

.card-link::after {
  content: '';
  position: absolute;
  inset: 0; /* o card inteiro vira área de clique do link */
}

.card-autor {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}
</style>
