<!--
  Histórico de leitura (HU-14 Task 3). Sem tela no Figma: segue Favoritos/Acervo e usa o
  CardContinuarLendo (horizontal) do design system.
  Os livros que a pessoa abriu, do lido mais recentemente para o mais antigo, com o progresso,
  a data da última leitura e "Continuar leitura" (abre o leitor, que oferece voltar à página do marcador).
  Os dados vêm de GET /api/v1/historico, que o leitor preenche sozinho ao abrir o livro e trocar de página.
-->
<script setup>
import { computed, onMounted, ref } from 'vue'
import LayoutLogado from '../components/layout/LayoutLogado.vue'
import Botao from '../components/ui/Botao.vue'
import CardContinuarLendo from '../components/ui/CardContinuarLendo.vue'
import ChipFiltro from '../components/ui/ChipFiltro.vue'
import EstadoVazio from '../components/ui/EstadoVazio.vue'
import { listarHistorico } from '../services/historicoService.js'

const itens = ref([])
const carregando = ref(true)
const erro = ref(false)

// Filtro: todos, em andamento (menos de 100%) ou lidos (100%)
const filtro = ref('todos')
const lido = (item) => item.progresso_percentual >= 100
const itensFiltrados = computed(() => {
  if (filtro.value === 'andamento') return itens.value.filter((item) => !lido(item))
  if (filtro.value === 'lidos') return itens.value.filter(lido)
  return itens.value
})

const contagem = computed(() => (itensFiltrados.value.length === 1 ? '1 livro' : `${itensFiltrados.value.length} livros`))

// "hoje", "ontem" ou a data (22/11/2026)
function quando(dataTexto) {
  if (!dataTexto) return ''
  const data = new Date(dataTexto)
  const dias = Math.round((inicioDoDia(new Date()) - inicioDoDia(data)) / 86_400_000)
  if (dias === 0) return 'hoje'
  if (dias === 1) return 'ontem'
  return `em ${data.toLocaleDateString('pt-BR')}`
}
const inicioDoDia = (data) => new Date(data.getFullYear(), data.getMonth(), data.getDate())

const detalhe = (item) => [item.livro.autor, `Última leitura ${quando(item.data_ultima_leitura)}`].filter(Boolean).join(' · ')

function rotuloProgresso(item) {
  if (lido(item)) return 'Livro lido'
  if (item.pagina_atual) return `Parou na página ${item.pagina_atual}`
  return 'Começou a ler'
}

async function carregar() {
  carregando.value = true
  erro.value = false
  try {
    itens.value = await listarHistorico()
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
    <div class="historico">
      <header class="historico-topo">
        <h1 class="historico-titulo">Histórico</h1>
        <p class="historico-subtitulo">Os livros que você abriu, do mais recente para o mais antigo.</p>
      </header>

      <p v-if="carregando" class="historico-aviso" role="status">Carregando histórico…</p>

      <EstadoVazio
        v-else-if="erro"
        class="historico-estado"
        titulo="Não conseguimos carregar seu histórico"
        descricao="Verifique sua conexão e tente de novo."
      >
        <template #acao>
          <Botao tipo="contorno" @click="carregar">Tentar de novo</Botao>
        </template>
      </EstadoVazio>

      <EstadoVazio
        v-else-if="!itens.length"
        class="historico-estado"
        titulo="Seu histórico ainda está vazio"
        descricao="Quando você abrir um livro para ler, ele aparece aqui."
      >
        <template #acao>
          <Botao tipo="contorno" to="/acervo">Explorar o acervo</Botao>
        </template>
      </EstadoVazio>

      <template v-else>
        <div class="historico-filtros" role="group" aria-label="Filtrar histórico">
          <ChipFiltro :selecionado="filtro === 'todos'" @click="filtro = 'todos'">Todos</ChipFiltro>
          <ChipFiltro :selecionado="filtro === 'andamento'" @click="filtro = 'andamento'">Em andamento</ChipFiltro>
          <ChipFiltro :selecionado="filtro === 'lidos'" @click="filtro = 'lidos'">Lidos</ChipFiltro>
        </div>

        <p class="historico-contagem" aria-live="polite">{{ contagem }}</p>

        <ul v-if="itensFiltrados.length" class="historico-lista">
          <li v-for="item in itensFiltrados" :key="item.livro_id">
            <CardContinuarLendo
              :titulo="item.livro.titulo"
              :detalhe="detalhe(item)"
              :categoria="item.livro.categoria?.nome"
              :capa-url="item.livro.capa_url"
              :progresso="item.progresso_percentual"
              :rotulo-progresso="rotuloProgresso(item)"
              :to="{ name: 'livro-leitura-logado', params: { id: item.livro_id } }"
            />
          </li>
        </ul>

        <p v-else class="historico-aviso">
          {{ filtro === 'lidos' ? 'Nenhum livro lido até o fim ainda.' : 'Nenhum livro em andamento.' }}
        </p>
      </template>
    </div>
  </LayoutLogado>
</template>

<style scoped>
.historico {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-24);
  max-width: 1096px; /* mesma largura do Acervo */
  margin-inline: auto;
}

.historico-topo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
}

.historico-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.historico-subtitulo,
.historico-aviso {
  color: var(--texto-secundario);
  font: var(--fonte-corpo);
}

.historico-filtros {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-12);
}

.historico-contagem {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}

.historico-estado {
  align-self: center;
}

.historico-lista {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-16);
  list-style: none;
}
</style>
