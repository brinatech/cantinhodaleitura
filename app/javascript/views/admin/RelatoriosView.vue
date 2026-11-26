<!--
  Relatórios da biblioteca (HU-22 Task 4), só para administradores. Sem tela no Figma.
  Filtro de período, cards com os números, a tabela dos livros mais acessados e a dos
  livros cadastrados por mês. Tabelas (e não gráficos) para funcionar com leitor de tela.
  "Leitores ativos" (proposta da equipe, a validar com a SESFA): leitores diferentes que abriram, leram ou
  baixaram algum livro no período. "Leitores cadastrados" continua ao lado, para comparar.
  Definições em docs/relatorios/definicao_indicadores.md.
-->
<script setup>
import { computed, onMounted, ref } from 'vue'
import LayoutLogado from '../../components/layout/LayoutLogado.vue'
import IndicadorCard from '../../components/admin/IndicadorCard.vue'
import Alerta from '../../components/ui/Alerta.vue'
import Botao from '../../components/ui/Botao.vue'
import EstadoVazio from '../../components/ui/EstadoVazio.vue'
import { buscarResumo } from '../../services/admin/relatoriosService.js'

// ===== Período =====
// Datas no formato da API (AAAA-MM-DD), no dia do computador de quem usa
const paraTexto = (data) =>
  `${data.getFullYear()}-${String(data.getMonth() + 1).padStart(2, '0')}-${String(data.getDate()).padStart(2, '0')}`

function periodoDe(opcao) {
  const hoje = new Date()
  if (opcao === 'mes-passado') {
    return {
      inicio: paraTexto(new Date(hoje.getFullYear(), hoje.getMonth() - 1, 1)),
      fim: paraTexto(new Date(hoje.getFullYear(), hoje.getMonth(), 0)),
    }
  }
  if (opcao === 'ultimos-30') {
    return { inicio: paraTexto(new Date(hoje.getFullYear(), hoje.getMonth(), hoje.getDate() - 29)), fim: paraTexto(hoje) }
  }
  return { inicio: paraTexto(new Date(hoje.getFullYear(), hoje.getMonth(), 1)), fim: paraTexto(hoje) } // este mês
}

const opcao = ref('este-mes')
const inicio = ref(periodoDe('este-mes').inicio)
const fim = ref(periodoDe('este-mes').fim)

function escolherOpcao() {
  if (opcao.value === 'escolher') return // a pessoa ajusta as datas e clica em "Ver relatório"
  const periodo = periodoDe(opcao.value)
  inicio.value = periodo.inicio
  fim.value = periodo.fim
  carregar()
}

// ===== Dados =====
const resumo = ref(null)
const carregando = ref(true)
const erro = ref('')

async function carregar() {
  carregando.value = true
  erro.value = ''
  try {
    resumo.value = await buscarResumo({ inicio: inicio.value, fim: fim.value })
  } catch (falha) {
    // 422: período inválido (a mensagem vem do servidor). Outro erro: não inventa zeros, mostra a falha.
    erro.value = falha.status === 422 ? falha.message : 'Não foi possível carregar os relatórios. Tente de novo.'
    if (falha.status !== 422) resumo.value = null
  } finally {
    carregando.value = false
  }
}

// ===== Textos =====
const numero = (valor) => (valor ?? 0).toLocaleString('pt-BR')
const dataBr = (texto) => (texto ? texto.split('-').reverse().join('/') : '')
const mesBr = (texto) => {
  const [ano, mes] = texto.split('-').map(Number)
  return new Date(ano, mes - 1, 1).toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' })
}

// " · 40% dos cadastrados" (sem cadastrados, não mostra porcentagem)
const porcentagemAtivos = (dados) =>
  dados.leitores_cadastrados
    ? ` · ${Math.round((dados.leitores_ativos / dados.leitores_cadastrados) * 100)}% dos cadastrados`
    : ''

const detalheAcesso = (dados) => `${numero(dados.leitores)} de leitores · ${numero(dados.visitantes)} de visitantes`

const cards = computed(() => {
  const dados = resumo.value
  if (!dados) return []
  return [
    {
      rotulo: 'Livros no acervo',
      valor: numero(dados.livros.total),
      detalhe: `${numero(dados.livros.novos_no_periodo)} novos no período`,
      icone: 'livro',
      cor: 'laranja',
    },
    {
      rotulo: 'Leitores ativos',
      valor: numero(dados.leitores_ativos),
      detalhe: `abriram, leram ou baixaram um livro${porcentagemAtivos(dados)}`,
      icone: 'estrela',
      cor: 'ceu',
    },
    { rotulo: 'Leitores cadastrados', valor: numero(dados.leitores_cadastrados), detalhe: 'contas de leitor', icone: 'usuario', cor: 'rosa' },
    { rotulo: 'Visualizações', valor: numero(dados.acessos.visualizacao.total), detalhe: detalheAcesso(dados.acessos.visualizacao), icone: 'olho', cor: 'ceu' },
    { rotulo: 'Leituras', valor: numero(dados.acessos.leitura.total), detalhe: detalheAcesso(dados.acessos.leitura), icone: 'livro', cor: 'coral' },
    // Sem card de "Downloads": o site não oferece mais botão de baixar (a API ainda conta, se alguém baixar pelo link)
  ]
})

onMounted(carregar)
</script>

<template>
  <LayoutLogado>
    <div class="relatorios">
      <header class="relatorios-topo">
        <h1 class="relatorios-titulo">Relatórios</h1>
        <p class="relatorios-subtitulo">Como a biblioteca está sendo usada.</p>
      </header>

      <form class="relatorios-filtro" aria-label="Período do relatório" @submit.prevent="carregar">
        <label class="campo">
          <span class="campo-rotulo">Período</span>
          <select v-model="opcao" class="campo-entrada" @change="escolherOpcao">
            <option value="este-mes">Este mês</option>
            <option value="mes-passado">Mês passado</option>
            <option value="ultimos-30">Últimos 30 dias</option>
            <option value="escolher">Escolher datas</option>
          </select>
        </label>

        <template v-if="opcao === 'escolher'">
          <label class="campo">
            <span class="campo-rotulo">De</span>
            <input v-model="inicio" class="campo-entrada" type="date" required>
          </label>
          <label class="campo">
            <span class="campo-rotulo">Até</span>
            <input v-model="fim" class="campo-entrada" type="date" required>
          </label>
          <Botao type="submit" :disabled="carregando">Ver relatório</Botao>
        </template>
      </form>

      <p v-if="resumo && !carregando" class="relatorios-periodo" aria-live="polite">
        De {{ dataBr(resumo.periodo.inicio) }} a {{ dataBr(resumo.periodo.fim) }}
      </p>

      <Alerta v-if="erro" tipo="erro">{{ erro }}</Alerta>

      <p v-if="carregando && !resumo" class="relatorios-aviso" role="status">Carregando relatórios…</p>

      <EstadoVazio
        v-else-if="!resumo && erro"
        class="relatorios-estado"
        titulo="Relatórios indisponíveis"
        descricao="Verifique sua conexão e tente de novo."
      >
        <template #acao><Botao tipo="contorno" @click="carregar">Tentar de novo</Botao></template>
      </EstadoVazio>

      <template v-else-if="resumo">
        <ul class="relatorios-cards" :aria-busy="carregando">
          <li v-for="card in cards" :key="card.rotulo">
            <IndicadorCard v-bind="card" :nivel="2" />
          </li>
        </ul>

        <section class="relatorios-secao" aria-labelledby="titulo-mais-acessados">
          <h2 id="titulo-mais-acessados" class="relatorios-secao-titulo">Livros mais acessados</h2>
          <p v-if="!resumo.mais_acessados.length" class="relatorios-aviso">Nenhum acesso no período.</p>
          <!-- tabindex: no celular a tabela rola para o lado, e quem usa teclado também precisa conseguir rolar -->
          <div v-else class="tabela-rolagem" tabindex="0" role="region" aria-label="Tabela dos livros mais acessados">
            <table class="tabela">
              <caption class="so-leitor">Os 10 livros com mais leituras no período</caption>
              <thead>
                <tr>
                  <th scope="col">#</th>
                  <th scope="col">Livro</th>
                  <th scope="col" class="numero">Leituras</th>
                  <th scope="col" class="numero">Visualizações</th>
                  <th scope="col" class="numero">Downloads</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(linha, indice) in resumo.mais_acessados" :key="linha.livro_id">
                  <td>{{ indice + 1 }}</td>
                  <th scope="row">{{ linha.titulo }}</th>
                  <td class="numero">{{ numero(linha.leituras) }}</td>
                  <td class="numero">{{ numero(linha.visualizacoes) }}</td>
                  <td class="numero">{{ numero(linha.downloads) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>

        <section class="relatorios-secao" aria-labelledby="titulo-por-mes">
          <h2 id="titulo-por-mes" class="relatorios-secao-titulo">Livros cadastrados por mês</h2>
          <p v-if="!resumo.livros.por_mes.length" class="relatorios-aviso">Nenhum livro novo no período.</p>
          <div v-else class="tabela-rolagem">
            <table class="tabela tabela--estreita">
              <caption class="so-leitor">Quantos livros entraram no acervo em cada mês do período</caption>
              <thead>
                <tr>
                  <th scope="col">Mês</th>
                  <th scope="col" class="numero">Livros novos</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="linha in resumo.livros.por_mes" :key="linha.mes">
                  <th scope="row" class="mes">{{ mesBr(linha.mes) }}</th>
                  <td class="numero">{{ numero(linha.total) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </template>
    </div>
  </LayoutLogado>
</template>

<style scoped>
.relatorios {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-24);
  max-width: 1096px;
  margin-inline: auto;
}

.relatorios-topo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
}

.relatorios-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.relatorios-subtitulo,
.relatorios-aviso {
  color: var(--texto-secundario);
  font: var(--fonte-corpo);
}

.relatorios-periodo {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}

.relatorios-estado {
  align-self: center;
}

/* ===== Filtro ===== */
.relatorios-filtro {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: var(--espaco-12) var(--espaco-16);
}

.campo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-4);
}

.campo-rotulo {
  color: var(--texto-principal);
  font: var(--fonte-botao);
}

.campo-entrada {
  min-height: 48px;
  padding: var(--espaco-8) var(--espaco-12);
  border: 1.5px solid var(--borda-forte);
  border-radius: var(--raio-8);
  background: var(--fundo-superficie);
  color: var(--texto-corpo);
  font: var(--fonte-interface);
}

.campo-entrada:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 1px;
}

/* ===== Cards ===== */
.relatorios-cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(min(200px, 100%), 1fr));
  gap: var(--espaco-16);
  list-style: none;
  transition: opacity 0.15s ease;
}

.relatorios-cards[aria-busy='true'] {
  opacity: 0.6; /* trocando de período: os números antigos ficam apagados até chegar a resposta */
}

/* ===== Tabelas ===== */
.relatorios-secao {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-12);
}

.relatorios-secao-titulo {
  color: var(--texto-principal);
  font: var(--fonte-subtitulo);
}

.tabela-rolagem {
  overflow-x: auto; /* no celular, a tabela rola para o lado em vez de apertar */
  border: 1px solid var(--borda-padrao);
  border-radius: var(--raio-12);
  background: var(--fundo-superficie);
}

.tabela-rolagem:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 2px;
}

.tabela {
  width: 100%;
  border-collapse: collapse;
  color: var(--texto-corpo);
  font: var(--fonte-interface);
}

.tabela--estreita {
  max-width: 420px;
}

.tabela th,
.tabela td {
  padding: var(--espaco-12) var(--espaco-16);
  border-bottom: 1px solid var(--borda-padrao);
  text-align: left;
}

.tabela thead th {
  background: var(--fundo-nuvem);
  color: var(--texto-principal);
  font: var(--fonte-rotulo);
  letter-spacing: var(--letras-rotulo);
  text-transform: uppercase;
  white-space: nowrap;
}

.tabela tbody th {
  color: var(--texto-principal);
  font: var(--fonte-botao);
}

.tabela tbody tr:last-child > * {
  border-bottom: 0;
}

.tabela .numero {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

.tabela .mes::first-letter {
  text-transform: uppercase;
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

/* Celular: células mais justas e o nome do livro com largura mínima
   (sem ela, o título quebra quase uma palavra por linha) */
@media (max-width: 640px) {
  .tabela th,
  .tabela td {
    padding: var(--espaco-8) var(--espaco-12);
  }

  .tabela tbody th {
    min-width: 10em;
  }
}

@media (prefers-reduced-motion: reduce) {
  .relatorios-cards {
    transition: none;
  }
}
</style>
