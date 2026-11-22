<!--
  Catálogo de livros: filtros (categoria e audiobook), contagem e a grade de cards.
  É a "estante" do acervo: a mesma para o leitor logado e para o visitante; quem usa
  decide a moldura em volta (LayoutLogado ou a página pública).
  Recebe os livros no mesmo formato da API (GET /api/v1/livros):
    { id, titulo, autor, capa_url, categoria: { nome }, formatos: [{ tipo: 'texto' | 'audio' }] }
  As categorias dos chips saem dos próprios livros: não precisa de endpoint de categorias.
  A busca por texto vem de fora (prop "busca"), porque o campo fica na barra de cima;
  o catálogo só avisa com "limpar-busca" quando a pessoa quer tirar a busca.
  Os filtros ficam no endereço (?categoria=Fantasia&audio=1), como a busca (HU-02 Task 2, item 4):
  assim o "Voltar" depois de abrir um livro, o F5 e um link compartilhado mantêm o que foi escolhido.
-->
<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import Alerta from '../ui/Alerta.vue'
import Botao from '../ui/Botao.vue'
import CardLivro from '../ui/CardLivro.vue'
import ChipFiltro from '../ui/ChipFiltro.vue'
import EstadoVazio from '../ui/EstadoVazio.vue'
import Icone from '../ui/Icone.vue'
import { chaveCategoria } from '../ui/categorias.js'
import { useFavoritar } from '../../composables/useFavoritar.js'
import { useAuthStore } from '../../stores/auth.js'

const props = defineProps({
  livros: { type: Array, required: true },
  busca: { type: String, default: '' }, // texto buscado em título e autor
  detalhe: { type: String, default: 'livro-detalhe' }, // nome da rota aberta ao clicar num card
})

const emit = defineEmits(['limpar-busca'])

// ===== Favoritos (coração dos cards) =====
// Só quem tem conta vê o coração: visitante não guarda favoritos (backlog, HU-12)
const auth = useAuthStore()
const { alternar: alternarFavorito, erro: erroFavorito, aviso: avisoFavorito, ehFavorito, estaPendente } = useFavoritar()

// ===== Busca =====
// Tira acentos e deixa minúsculo: "Dragão" → "dragao". Assim "joao" acha "João".
const normalizar = (texto = '') =>
  texto
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .trim()

const termo = computed(() => normalizar(props.busca))

const combinaComBusca = (livro) =>
  !termo.value ||
  normalizar(livro.titulo).includes(termo.value) ||
  normalizar(livro.autor ?? '').includes(termo.value)

// ===== Filtros (guardados no endereço) =====
const rota = useRoute()
const roteador = useRouter()

// Categorias que existem nos livros, sem repetir, em ordem alfabética
const categorias = computed(() => {
  const nomes = props.livros.map((livro) => livro.categoria?.nome).filter(Boolean)
  return [...new Set(nomes)].sort((a, b) => a.localeCompare(b, 'pt-BR'))
})

// ?categoria=Fantasia. Categoria que não existe mais (link antigo) vale como "Todas".
// null = "Todas as categorias"
const categoriaSelecionada = computed(() => {
  const nome = rota.query.categoria
  return typeof nome === 'string' && categorias.value.includes(nome) ? nome : null
})
const soAudiobook = computed(() => rota.query.audio === '1') // ?audio=1

// Troca só o filtro pedido e mantém o resto do endereço (a busca, por exemplo).
// replace: escolher filtros não cria passos a mais no "Voltar" do navegador.
function mudarFiltros(mudancas) {
  const query = { ...rota.query }
  Object.entries(mudancas).forEach(([chave, valor]) => {
    if (valor) query[chave] = valor
    else delete query[chave]
  })
  return roteador.replace({ query })
}

const temAudio = (livro) => livro.formatos?.some((formato) => formato.tipo === 'audio')

const livrosFiltrados = computed(() =>
  props.livros.filter((livro) => {
    if (!combinaComBusca(livro)) return false
    if (categoriaSelecionada.value && livro.categoria?.nome !== categoriaSelecionada.value) return false
    if (soAudiobook.value && !temAudio(livro)) return false
    return true
  }),
)

// Clicar na categoria já selecionada desmarca (volta para "Todas")
const escolherCategoria = (nome) => mudarFiltros({ categoria: categoriaSelecionada.value === nome ? null : nome })
const alternarAudiobook = () => mudarFiltros({ audio: soAudiobook.value ? null : '1' })

// Tira tudo: categoria, audiobook e a busca, numa troca só de endereço.
// Espera o endereço mudar antes de avisar quem tem o campo de busca (senão as duas trocas se atropelam).
async function limparFiltros() {
  const tinhaBusca = Boolean(props.busca)
  await mudarFiltros({ categoria: null, audio: null, busca: null })
  if (tinhaBusca) emit('limpar-busca')
}

// ===== Textos =====
const buscaVisivel = computed(() => props.busca.trim())

const contagem = computed(() => {
  const total = livrosFiltrados.value.length
  const livros = total === 1 ? '1 livro' : `${total} livros`
  return buscaVisivel.value ? `${livros} para “${buscaVisivel.value}”` : livros
})

const descricaoVazio = computed(() =>
  buscaVisivel.value
    ? `Nada combina com “${buscaVisivel.value}”. Confira a escrita ou tente outro título ou autor.`
    : 'Tente outra categoria ou tire o filtro de audiobook.',
)

// Lista de formatos da API → texto da tag do card
const textoFormato = (livro) => {
  const tipos = (livro.formatos ?? []).map((formato) => formato.tipo)
  const texto = tipos.includes('texto')
  const audio = tipos.includes('audio')
  if (texto && audio) return 'Texto e audiobook'
  if (audio) return 'Audiobook'
  if (texto) return 'Texto'
  return ''
}
</script>

<template>
  <section class="catalogo" aria-labelledby="titulo-catalogo">
    <h2 id="titulo-catalogo" class="so-leitor">Livros do acervo</h2>

    <div class="catalogo-filtros" role="group" aria-label="Filtrar livros">
      <ChipFiltro :selecionado="categoriaSelecionada === null" @click="mudarFiltros({ categoria: null })">
        Todas as categorias
      </ChipFiltro>

      <ChipFiltro
        v-for="nome in categorias"
        :key="nome"
        :cor="chaveCategoria(nome)"
        :selecionado="categoriaSelecionada === nome"
        @click="escolherCategoria(nome)"
      >
        {{ nome }}
      </ChipFiltro>

      <span class="catalogo-divisor" aria-hidden="true"></span>

      <ChipFiltro :selecionado="soAudiobook" @click="alternarAudiobook">
        Com audiobook
      </ChipFiltro>
    </div>

    <div class="catalogo-resumo">
      <!-- aria-live: o leitor de tela anuncia a nova contagem quando um filtro ou a busca muda -->
      <p class="catalogo-contagem" aria-live="polite">{{ contagem }}</p>

      <Botao v-if="buscaVisivel" tipo="contorno" class="catalogo-limpar-busca" @click="emit('limpar-busca')">
        <template #icone><Icone nome="fechar" /></template>
        Limpar busca
      </Botao>
    </div>

    <p class="so-leitor" role="status">{{ avisoFavorito }}</p>
    <Alerta v-if="erroFavorito" tipo="erro">{{ erroFavorito }}</Alerta>

    <!-- aparecer-em-cascata (styles/animacoes.css): os cards aparecem um depois do outro -->
    <ul v-if="livrosFiltrados.length" class="catalogo-grade aparecer-em-cascata">
      <li v-for="(livro, indice) in livrosFiltrados" :key="livro.id" :style="{ '--ordem': indice }">
        <CardLivro
          :titulo="livro.titulo"
          :autor="livro.autor"
          :categoria="livro.categoria?.nome"
          :capa-url="livro.capa_url"
          :formato="textoFormato(livro)"
          :icone-formato="temAudio(livro) ? 'fones' : 'livro'"
          :to="{ name: detalhe, params: { id: livro.id } }"
          :mostrar-favoritar="Boolean(auth.usuario)"
          :favorito="ehFavorito(livro.id)"
          :favoritando="estaPendente(livro.id)"
          @favoritar="alternarFavorito(livro.id, livro.titulo)"
        />
      </li>
    </ul>

    <EstadoVazio
      v-else
      class="catalogo-vazio"
      :nivel="3"
      titulo="Nenhum livro encontrado"
      :descricao="descricaoVazio"
    >
      <template #acao>
        <Botao tipo="contorno" @click="limparFiltros">Limpar filtros</Botao>
      </template>
    </EstadoVazio>
  </section>
</template>

<style scoped>
.catalogo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-24);
}

/* Título só para leitores de tela: organiza a página sem aparecer na tela */
.so-leitor {
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip-path: inset(50%);
  white-space: nowrap;
}

/* ===== Filtros ===== */
.catalogo-filtros {
  display: flex;
  flex-wrap: wrap;                    /* em telas menores os chips descem para a linha de baixo */
  align-items: center;
  gap: var(--espaco-12);
}

/* Separa os filtros de categoria do filtro de formato */
.catalogo-divisor {
  width: 1px;
  height: var(--espaco-24);
  background: var(--borda-padrao);
}

/* Contagem e, quando há busca, o botão de limpar na mesma linha */
.catalogo-resumo {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: var(--espaco-16);
}

.catalogo-contagem {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}

/* ===== Grade de cards (mesma da seção "Novidades" em Minhas leituras) ===== */
.catalogo-grade {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(min(240px, 100%), 1fr));
  gap: 20px;
  list-style: none;
}

.catalogo-grade > li {
  display: flex;
}

.catalogo-grade > li > * {
  flex: 1;
}

/* Nenhum resultado: o quadro fica no meio da página, não colado à esquerda */
.catalogo-vazio {
  align-self: center;
}

/* Celular: o divisor some quando os chips quebram em várias linhas */
@media (max-width: 640px) {
  .catalogo-divisor {
    display: none;
  }
}
</style>
