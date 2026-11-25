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
import CampoBusca from '../components/ui/CampoBusca.vue'
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

// Atualiza a URL conforme o visitante digita (replace: sem poluir o histórico)
function atualizarBusca() {
  const termo = termoInput.value.trim()
  if (termo === busca.value) return // nada mudou (ex.: só um espaço no fim)

  const { busca: _anterior, ...resto } = rota.query
  roteador.replace({ query: termo ? { ...resto, busca: termo } : resto })
}

watch(termoInput, atualizarBusca)

// "Limpar busca" do CatalogoLivros: esvaziar o campo já tira o ?busca= da URL (watch acima)
const limparBusca = () => {
  termoInput.value = ''
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
          <h1 class="acervo-titulo">Acervo</h1>
          <p class="acervo-subtitulo">
            Explore histórias e materiais liberados gratuitamente para leitura e audição.
          </p>
        </div>

        <!-- Campo de busca do design system (o mesmo da barra de cima da área logada).
             O visitante não tem essa barra, então a busca fica aqui, ao lado do título. -->
        <form class="acervo-busca" role="search" @submit.prevent="atualizarBusca">
          <CampoBusca v-model="termoInput" />
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
  background-color: var(--fundo-pagina);
}

/* Mesma largura e espaçamento do acervo logado (AcervoView) */
.acervo-container {
  flex: 1;
  width: 100%;
  max-width: 1096px;
  margin-inline: auto;
  padding: var(--espaco-32) var(--espaco-24);
  display: flex;
  flex-direction: column;
  gap: var(--espaco-32);
}

.acervo-topo {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  align-items: flex-end;
  gap: var(--espaco-24);
}

.acervo-cabecalho-texto {
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

/* Mesma largura máxima da busca da barra de cima (LayoutLogado) */
.acervo-busca {
  flex: 1 1 min(320px, 100%); /* em tela de 320px a base fixa de 320px passava da borda */
  min-width: 0; /* sem isso o campo não encolhe abaixo da largura natural do input e passa da borda a 320px */
  max-width: 440px;
}

.acervo-aviso {
  color: var(--texto-secundario);
  font: var(--fonte-corpo);
}

.acervo-erro {
  align-self: center;
}
</style>