<!--
  Acervo (Figma: "Acervo · área logada"). Lista os livros do catálogo com busca e filtros.
  A busca por texto fica na barra de cima (LayoutLogado), que manda para /acervo?busca=...;
  esta tela lê a URL e mostra os livros que combinam (HU-02, Task 2 do backlog).
  A estante (filtros + cards) é o CatalogoLivros, que também servirá ao acervo do visitante.
  Os livros vêm do GET /api/v1/livros para que os IDs dos cards correspondam aos
  registros usados pela página de detalhes.
-->
<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import LayoutLogado from '../components/layout/LayoutLogado.vue'
import CatalogoLivros from '../components/livros/CatalogoLivros.vue'
import Alerta from '../components/ui/Alerta.vue'
import Botao from '../components/ui/Botao.vue'
import { listarLivros, ErroApiLivros } from '../services/livros.js'

const rota = useRoute()
const roteador = useRouter()

// A busca vem da URL (/acervo?busca=lua), que a barra de cima preenche
const busca = computed(() => (typeof rota.query.busca === 'string' ? rota.query.busca : ''))

// Tira só o ?busca= da URL e mantém o resto; replace: não cria um passo a mais no "voltar"
const limparBusca = () => {
  const { busca: _removida, ...resto } = rota.query
  roteador.replace({ query: resto })
}

const livros = ref([])
const carregando = ref(true)
const erro = ref(null)
let controladorAtual = null

const carregarLivros = async () => {
  controladorAtual?.abort()
  const controlador = new AbortController()
  controladorAtual = controlador
  carregando.value = true
  erro.value = null

  try {
    livros.value = await listarLivros({ signal: controlador.signal })
  } catch (falha) {
    if (falha.name === 'AbortError') return
    erro.value = falha instanceof ErroApiLivros ? falha : new Error('Não foi possível carregar o acervo.')
  } finally {
    if (controladorAtual === controlador) carregando.value = false
  }
}

onMounted(carregarLivros)
onBeforeUnmount(() => controladorAtual?.abort())
</script>

<template>
  <LayoutLogado>
    <div class="acervo">
      <header class="acervo-topo">
        <h1 class="acervo-titulo">Acervo</h1>
        <p class="acervo-subtitulo">Encontre uma história que combine com seu momento.</p>
      </header>

      <div v-if="carregando" class="acervo-estado" role="status" aria-live="polite">
        Carregando acervo...
      </div>

      <div v-else-if="erro" class="acervo-estado">
        <Alerta tipo="erro">Não foi possível carregar o acervo. Tente novamente.</Alerta>
        <Botao tipo="contorno" @click="carregarLivros">Tentar novamente</Botao>
      </div>

      <CatalogoLivros v-else :livros="livros" :busca="busca" @limpar-busca="limparBusca" />
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

.acervo-estado {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--espaco-16);
  min-height: 180px;
  padding: var(--espaco-32);
  color: var(--texto-secundario);
  font: var(--fonte-interface);
  text-align: center;
}
</style>
