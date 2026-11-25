<!--
  Favoritos do leitor logado (HU-12). Sem tela no Figma: segue o Acervo (título, grade de cards).
  A lista vem da store de favoritos (GET /api/v1/favoritos), sempre buscada de novo ao abrir a página.
  Tirar o coração de um card tira o livro da lista na hora (depois que o servidor confirma).
-->
<script setup>
import { computed, onMounted, ref } from 'vue'
import LayoutLogado from '../components/layout/LayoutLogado.vue'
import Alerta from '../components/ui/Alerta.vue'
import Botao from '../components/ui/Botao.vue'
import CardLivro from '../components/ui/CardLivro.vue'
import EstadoVazio from '../components/ui/EstadoVazio.vue'
import { useFavoritar } from '../composables/useFavoritar.js'
import { useFavoritosStore } from '../stores/favoritos.js'

const favoritos = useFavoritosStore()
const { alternar, erro: erroFavorito, aviso, estaPendente } = useFavoritar()

const carregando = ref(true)
const erro = ref(false)
const livros = computed(() => favoritos.favoritos.map((favorito) => favorito.livro))

const contagem = computed(() => (livros.value.length === 1 ? '1 livro' : `${livros.value.length} livros`))

async function carregar() {
  carregando.value = true
  erro.value = false
  try {
    await favoritos.carregar({ forcar: true }) // pode ter mudado em outra aba ou aparelho
  } catch {
    erro.value = true
  } finally {
    carregando.value = false
  }
}

onMounted(carregar)
</script>

<template>
  <LayoutLogado>
    <div class="favoritos">
      <header class="favoritos-topo">
        <h1 class="favoritos-titulo">Favoritos</h1>
        <p class="favoritos-subtitulo">Os livros que você guardou para encontrar depressa.</p>
      </header>

      <p v-if="carregando" class="favoritos-aviso" role="status">Carregando favoritos…</p>

      <EstadoVazio
        v-else-if="erro"
        class="favoritos-estado"
        titulo="Não conseguimos carregar seus favoritos"
        descricao="Verifique sua conexão e tente de novo."
      >
        <template #acao>
          <Botao tipo="contorno" @click="carregar">Tentar de novo</Botao>
        </template>
      </EstadoVazio>

      <EstadoVazio
        v-else-if="!livros.length"
        class="favoritos-estado"
        titulo="Você ainda não tem favoritos"
        descricao="Toque no coração de um livro no acervo para guardá-lo aqui."
      >
        <template #acao>
          <Botao tipo="contorno" to="/acervo">Explorar o acervo</Botao>
        </template>
      </EstadoVazio>

      <template v-else>
        <p class="favoritos-contagem" aria-live="polite">{{ contagem }}</p>
        <p class="so-leitor" role="status">{{ aviso }}</p>
        <Alerta v-if="erroFavorito" tipo="erro">{{ erroFavorito }}</Alerta>

        <ul class="favoritos-grade">
          <li v-for="livro in livros" :key="livro.id">
            <CardLivro
              :nivel="2"
              :titulo="livro.titulo"
              :autor="livro.autor"
              :categoria="livro.categoria?.nome"
              :capa-url="livro.capa_url"
              :to="{ name: 'livro-detalhe-logado', params: { id: livro.id } }"
              favorito
              :favoritando="estaPendente(livro.id)"
              @favoritar="alternar(livro.id, livro.titulo)"
            />
          </li>
        </ul>
      </template>
    </div>
  </LayoutLogado>
</template>

<style scoped>
.favoritos {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-32);
  max-width: 1096px; /* mesma largura do Acervo */
  margin-inline: auto;
}

.favoritos-topo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
}

.favoritos-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.favoritos-subtitulo,
.favoritos-aviso {
  color: var(--texto-secundario);
  font: var(--fonte-corpo);
}

.favoritos-contagem {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}

.favoritos-estado {
  align-self: center;
}

/* Mesma grade do CatalogoLivros */
.favoritos-grade {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(min(240px, calc(50% - 10px)), 1fr)); /* no celular: 2 colunas (50% menos meio espaço de 20px) */
  gap: 20px;
  list-style: none;
}

.favoritos-grade > li {
  display: flex;
}

.favoritos-grade > li > * {
  flex: 1;
}

/* Só para leitor de tela */
.so-leitor {
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip-path: inset(50%);
  white-space: nowrap;
}
</style>
