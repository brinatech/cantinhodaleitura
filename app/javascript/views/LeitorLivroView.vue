<!--
  Leitura do livro (HU-10 Task 4): abre o PDF ou toca o áudio dentro do site.
  /livros/:id/ler é a do visitante; /acervo/:id/ler é a mesma, dentro da área logada.
  Tela única: o PDF no centro e, se o livro tiver audiobook, o player numa faixa presa embaixo.
-->
<script setup>
import { computed, onBeforeUnmount, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import LayoutLogado from '../components/layout/LayoutLogado.vue'
import MenuSuperior from '../components/layout/MenuSuperior.vue'
import Rodape from '../components/layout/Rodape.vue'
import Alerta from '../components/ui/Alerta.vue'
import Botao from '../components/ui/Botao.vue'
import EstadoVazio from '../components/ui/EstadoVazio.vue'
import LeitorAudio from '../components/leitor/LeitorAudio.vue'
import ControleMarcador from '../components/leitor/ControleMarcador.vue'
import LeitorPdf from '../components/leitor/LeitorPdf.vue'
import { useMarcadorPagina } from '../composables/useMarcadorPagina.js'
import { buscarLivro, ErroApiLivros } from '../services/livrosService.js'

const rota = useRoute()

// Marcador de página (HU-15): só para quem está logado e só no PDF
const leitorPdf = ref(null)
const marcador = useMarcadorPagina(() => rota.params.id)

function continuarDoMarcador() {
  leitorPdf.value?.irPara(marcador.paginaSalva.value)
  marcador.dispensar()
}
const logada = computed(() => rota.meta.logada === true)
// "Voltar" leva para a página do livro, na mesma moldura (visitante ou área logada)
const voltarPara = computed(() => `${logada.value ? '/acervo' : '/livros'}/${rota.params.id}`)

const livro = ref(null)
const carregando = ref(true)
const erro = ref(null)
let controladorAtual = null

// Uma tela só: o PDF no centro e, se o livro tiver audiobook, o player preso embaixo.
// Cada um é o arquivo do livro (com a url da API para abrir) ou null, se o livro não tem.
const arquivoDo = (tipo) => livro.value?.formatos?.find((item) => item.tipo === tipo) ?? null
const texto = computed(() => arquivoDo('texto'))
const audio = computed(() => arquivoDo('audio'))

async function carregarLivro(id) {
  controladorAtual?.abort()
  const controlador = new AbortController()
  controladorAtual = controlador
  carregando.value = true
  erro.value = null
  livro.value = null

  try {
    livro.value = await buscarLivro(id, { signal: controlador.signal })
  } catch (falha) {
    if (falha.name === 'AbortError') return
    erro.value = falha instanceof ErroApiLivros ? falha : new Error('Não foi possível carregar o livro.')
  } finally {
    if (controladorAtual === controlador) carregando.value = false
  }
}

watch(() => rota.params.id, carregarLivro, { immediate: true })
onBeforeUnmount(() => controladorAtual?.abort())
</script>

<template>
  <component :is="logada ? LayoutLogado : 'div'">
    <MenuSuperior v-if="!logada" />

    <component :is="logada ? 'div' : 'main'" class="leitor" :class="{ 'leitor--logado': logada }">
      <p v-if="carregando" class="leitor-estado" role="status">Carregando livro...</p>

      <EstadoVazio
        v-else-if="erro?.status === 404"
        :nivel="1"
        titulo="Livro não encontrado"
        descricao="O livro que você procura não está disponível no acervo."
      >
        <template #acao><Botao tipo="contorno" :to="logada ? '/acervo' : '/acervo-publico'">Voltar ao acervo</Botao></template>
      </EstadoVazio>

      <div v-else-if="erro" class="leitor-estado">
        <Alerta tipo="erro">Não foi possível carregar este livro. Tente novamente.</Alerta>
        <Botao tipo="contorno" :to="voltarPara">Voltar ao livro</Botao>
      </div>

      <article v-else-if="livro" class="leitor-conteudo">
        <div class="leitor-topo">
          <Botao tipo="contorno" :to="voltarPara">← Voltar ao livro</Botao>
          <div>
            <p class="leitor-rotulo">{{ texto ? 'Lendo' : 'Ouvindo' }}</p>
            <h1 class="leitor-titulo">{{ livro.titulo }}</h1>
            <p v-if="livro.autor" class="leitor-autor">{{ livro.autor }}</p>
          </div>
        </div>

        <!-- Marcador (HU-15): "Você parou na página X". Fica fora da cadeia v-if abaixo, para o PDF aparecer junto -->
        <ControleMarcador
          v-if="texto && marcador.oferecerContinuar.value"
          :pagina="marcador.paginaSalva.value"
          @continuar="continuarDoMarcador"
          @dispensar="marcador.dispensar"
        />

        <EstadoVazio
          v-if="!texto && !audio"
          titulo="Livro ainda sem arquivo"
          descricao="Este livro ainda não tem o texto disponível para leitura."
        >
          <template #acao><Botao tipo="contorno" :to="voltarPara">Voltar ao livro</Botao></template>
        </EstadoVazio>

        <!-- O PDF no centro; o audiobook, se existir, numa faixa presa embaixo da tela -->
        <LeitorPdf
          v-else-if="texto"
          ref="leitorPdf"
          :url="texto.url"
          :titulo="livro.titulo"
          @aberto="marcador.aoAbrirPdf"
          @mudou-pagina="marcador.aoMudarPagina"
        >
          <template v-if="audio" #rodape>
            <LeitorAudio
              compacto
              :url="audio.url"
              :titulo="livro.titulo"
              :autor="livro.autor || ''"
              :capa-url="livro.capa_url"
            />
          </template>
        </LeitorPdf>

        <!-- Livro só com áudio (antigo: o PDF ainda não era obrigatório): o player completo -->
        <LeitorAudio
          v-else
          :url="audio.url"
          :titulo="livro.titulo"
          :autor="livro.autor || ''"
          :capa-url="livro.capa_url"
        />
      </article>
    </component>

    <Rodape v-if="!logada" />
  </component>
</template>

<style scoped>
.leitor {
  min-height: 60vh;
  padding: var(--espaco-48) clamp(var(--espaco-24), 9.8vw, 141px) var(--espaco-64);
  background: var(--fundo-pagina);
}

/* Na área logada, quem dá o espaçamento e o fundo é o LayoutLogado */
.leitor.leitor--logado {
  min-height: 0;
  padding: 0;
  background: none;
}

.leitor-conteudo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-24);
  max-width: 1096px;
  margin-inline: auto;
}

.leitor-topo {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-16);
}

.leitor-rotulo {
  margin-bottom: var(--espaco-4);
  color: var(--texto-secundario);
  font: var(--fonte-rotulo);
  letter-spacing: var(--letras-rotulo);
  text-transform: uppercase;
}

.leitor-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.leitor-autor {
  color: var(--texto-secundario);
  font: var(--fonte-interface);
}

.leitor-estado {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-16);
  max-width: 1096px;
  margin-inline: auto;
  color: var(--texto-secundario);
  font: var(--fonte-interface);
}
</style>
