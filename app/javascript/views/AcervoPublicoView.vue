<!--
  Acervo Público (Visitante).
  Atende à HU-01 e HU-02 do backlog: acesso sem login, busca por texto na URL e filtros.
  Reaproveita o mesmo CatalogoLivros usado na área logada.
-->
<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
// Ajuste os caminhos abaixo caso seus componentes públicos tenham outro nome
import MenuSuperior from '../components/layout/MenuSuperior.vue'
import Rodape from '../components/layout/Rodape.vue'
import CatalogoLivros from '../components/livros/CatalogoLivros.vue'
import Botao from '../components/ui/Botao.vue'
import EstadoVazio from '../components/ui/EstadoVazio.vue'
import { listarLivros } from '../services/livrosService.js'

const rota = useRoute()
const roteador = useRouter()

// Lê o termo de busca direto da URL (/acervo-publico?busca=...)
const busca = computed(() => (typeof rota.query.busca === 'string' ? rota.query.busca : ''))
const termoInput = ref(busca.value)

// Mantém o input sincronizado se a URL mudar externamente (ex: botão voltar do navegador)
watch(busca, (novoValor) => {
  termoInput.value = novoValor
})

// Atualiza a URL conforme o visitante digita (sem poluir o histórico)
function atualizarBusca() {
  const query = { ...rota.query }
  if (termoInput.value.trim()) {
    query.busca = termoInput.value.trim()
  } else {
    delete query.busca
  }
  roteador.replace({ query })
}

const limparBusca = () => {
  termoInput.value = ''
  const { busca: _removida, ...resto } = rota.query
  roteador.replace({ query: resto })
}

const livros = ref([])
const carregando = ref(true)
const erro = ref(false)

async function carregarLivros() {
  carregando.value = true
  erro.value = false
  try {
    // O endpoint GET /api/v1/livros já retorna os materiais públicos quando não há sessão (HU-01)
    livros.value = await listarLivros()
  } catch {
    erro.value = true
  } finally {
    carregando.value = false
  }
}

onMounted(carregarLivros)
</script>

<template>
  <div class="pagina-publica">
    <!-- Cabeçalho da área de visitante (o mesmo da HomeView) -->
    <MenuSuperior />

    <main class="acervo-container">
      <header class="acervo-topo">
        <div class="acervo-cabecalho-texto">
          <h1 class="acervo-titulo">Acervo Público</h1>
          <p class="acervo-subtitulo">
            Explore histórias e materiais liberados gratuitamente para leitura e audição.
          </p>
        </div>

        <!-- Campo de pesquisa exigido na HU-02 (Task 2) para visitantes sem LayoutLogado -->
        <form class="acervo-busca-form" role="search" @submit.prevent="atualizarBusca">
          <label for="busca-acervo-publico" class="sr-only">
            Pesquisar livros por título ou autor
          </label>
          <input
            id="busca-acervo-publico"
            v-model="termoInput"
            type="search"
            class="acervo-busca-input"
            placeholder="Buscar por título ou autor..."
            @input="atualizarBusca"
          />
          <button
            v-if="termoInput"
            type="button"
            class="acervo-busca-limpar"
            aria-label="Limpar pesquisa"
            @click="limparBusca"
          >
            ✕
          </button>
        </form>
      </header>

      <!-- Estado de Carregamento (HU-01) -->
      <p v-if="carregando" class="acervo-aviso" role="status">
        Carregando livros disponíveis…
      </p>

      <!-- Estado de Erro (HU-01) -->
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

      <!-- Estante com filtros e cards (reaproveitada do AcervoView) -->
      <CatalogoLivros
        v-else
        :livros="livros"
        :busca="busca"
        @limpar-busca="limparBusca"
      />
    </main>

    <Rodape />
  </div>
</template>

<style scoped>
.pagina-publica {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: var(--fundo-pagina, #f8fafc);
}

.acervo-container {
  flex: 1;
  width: 100%;
  max-width: 1096px;
  margin-inline: auto;
  padding: var(--espaco-32, 32px) var(--espaco-24, 24px);
  display: flex;
  flex-direction: column;
  gap: var(--espaco-32, 32px);
}

.acervo-topo {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  align-items: flex-end;
  gap: var(--espaco-24, 24px);
}

.acervo-cabecalho-texto {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8, 8px);
}

.acervo-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.acervo-subtitulo {
  color: var(--texto-secundario);
  font: var(--fonte-corpo);
}

.acervo-busca-form {
  position: relative;
  display: flex;
  align-items: center;
  width: 100%;
  max-width: 360px;
}

.acervo-busca-input {
  width: 100%;
  padding: 10px 36px 10px 14px;
  border: 1px solid var(--borda-padrao, #cbd5e1);
  border-radius: var(--raio-medio, 8px);
  font: var(--fonte-corpo);
  color: var(--texto-principal);
  background: #ffffff;
}

.acervo-busca-input:focus {
  outline: 2px solid var(--cor-primaria, #38bdf8);
  outline-offset: 2px;
}

.acervo-busca-limpar {
  position: absolute;
  right: 10px;
  background: none;
  border: none;
  color: var(--texto-secundario);
  cursor: pointer;
  padding: 4px;
}

.acervo-aviso {
  color: var(--texto-secundario);
  font: var(--fonte-corpo);
}

.acervo-erro {
  align-self: center;
}

/* Classe utilitária para acessibilidade (leitores de tela - HU-16) */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
</style>