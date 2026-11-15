<!--
  Acervo (Figma: "Acervo · área logada"). Lista os livros do catálogo com busca e filtros.
  A busca por texto fica na barra de cima (LayoutLogado), que manda para /acervo?busca=...;
  esta tela lê a URL e mostra os livros que combinam (HU-02, Task 2 do backlog).
  A estante (filtros + cards) é o CatalogoLivros, que também servirá ao acervo do visitante.
  Os livros vêm do GET /api/v1/livros (services/livrosService.js); a busca e os
  filtros ainda são feitos no navegador.
-->
<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import LayoutLogado from '../components/layout/LayoutLogado.vue'
import CatalogoLivros from '../components/livros/CatalogoLivros.vue'
import Botao from '../components/ui/Botao.vue'
import EstadoVazio from '../components/ui/EstadoVazio.vue'
import { listarLivros } from '../services/livrosService.js'

const rota = useRoute()
const roteador = useRouter()

// A busca vem da URL (/acervo?busca=lua), que a barra de cima preenche
const busca = computed(() => (typeof rota.query.busca === 'string' ? rota.query.busca : ''))

// Tira só o ?busca= da URL e mantém o resto; replace: não cria um passo a mais no "voltar"
const limparBusca = () => {
  const { busca: _removida, ...resto } = rota.query
  roteador.replace({ query: resto })
}

const livros = ref([]) // começa vazia; enche quando a API responder
const carregando = ref(true) // true enquanto espera a resposta
const erro = ref(false) // true se a API falhar

async function carregarLivros() {
  carregando.value = true
  erro.value = false
  try {
    livros.value = await listarLivros()
  } catch {
    erro.value = true
  } finally {
    carregando.value = false // "finally" roda dando certo ou errado
  }
}

onMounted(carregarLivros) // quando a tela abrir, busca os livros
</script>

<template>
  <LayoutLogado>
    <div class="acervo">
      <header class="acervo-topo">
        <h1 class="acervo-titulo">Acervo</h1>
        <p class="acervo-subtitulo">Encontre uma história que combine com seu momento.</p>
      </header>

      <p v-if="carregando" class="acervo-aviso" role="status">Carregando livros…</p>

      <EstadoVazio
        v-else-if="erro"
        class="acervo-erro"
        titulo="Não conseguimos carregar o acervo"
        descricao="Verifique sua conexão e tente de novo."
      >
        <template #acao>
          <Botao tipo="contorno" @click="carregarLivros">Tentar de novo</Botao>
        </template>
      </EstadoVazio>

      <CatalogoLivros v-else :livros="livros" :busca="busca" detalhe="livro-detalhe-logado" @limpar-busca="limparBusca" />
    </div>
  </LayoutLogado>
</template>

<style scoped>
.acervo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-32);
  max-width: 1096px; /* largura do conteúdo no Figma (igual a Minhas leituras) */
  margin-inline: auto;
}

.acervo-topo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
}

.acervo-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.acervo-subtitulo {
  color: var(--texto-secundario);
  font: var(--fonte-corpo);
}

.acervo-aviso {
  color: var(--texto-secundario);
  font: var(--fonte-corpo);
}

.acervo-erro {
  align-self: center;
}
</style>
