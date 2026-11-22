<script setup>
import { computed, onBeforeUnmount, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import LayoutLogado from '../components/layout/LayoutLogado.vue'
import MenuSuperior from '../components/layout/MenuSuperior.vue'
import Rodape from '../components/layout/Rodape.vue'
import BotaoFavorito from '../components/livros/BotaoFavorito.vue'
import Alerta from '../components/ui/Alerta.vue'
import Botao from '../components/ui/Botao.vue'
import EstadoVazio from '../components/ui/EstadoVazio.vue'
import Icone from '../components/ui/Icone.vue'
import TagFormato from '../components/ui/TagFormato.vue'
import { chaveCategoria } from '../components/ui/categorias.js'
import { buscarLivro, ErroApiLivros } from '../services/livrosService.js'
import { rotuloTipo } from '../services/tiposClassificacao.js'
import { useAuthStore } from '../stores/auth.js'

const rota = useRoute()
const auth = useAuthStore()
const administrador = computed(() => auth.usuario?.tipo_usuario === 'administrador')

// /livros/:id é o detalhe do visitante; /acervo/:id é o mesmo, dentro da área logada
const logada = computed(() => rota.meta.logada === true)
const voltarPara = computed(() => (logada.value ? '/acervo' : '/acervo-publico'))
const livro = ref(null)
const carregando = ref(true)
const erro = ref(null)
let controladorAtual = null

const categoria = computed(() => livro.value?.categoria?.nome || '')
const classificacoes = computed(() => (Array.isArray(livro.value?.classificacoes)
  ? livro.value.classificacoes.filter((item) => item?.nome || item?.tipo || item?.descricao)
  : []))
const formatos = computed(() => (Array.isArray(livro.value?.formatos)
  ? livro.value.formatos.filter((formato) => formato && typeof formato === 'object' && formato.tipo)
  : []))

const textoFormato = (tipo) => ({ texto: 'Texto', audio: 'Audiobook' }[tipo] || tipo)
const chaveFormato = (formato, indice) => `${formato.tipo || 'formato'}-${indice}`
const chaveClassificacao = (classificacao, indice) => `${classificacao.tipo || 'classificacao'}-${classificacao.nome || 'item'}-${indice}`

const carregarLivro = async (id) => {
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

    <component :is="logada ? 'div' : 'main'" class="livro-detalhe" :class="{ 'livro-detalhe--logado': logada }">
      <div v-if="carregando" class="livro-estado" role="status" aria-live="polite">
        <p class="livro-estado-titulo">Carregando livro...</p>
        <div class="livro-carregando" aria-hidden="true"></div>
      </div>

      <EstadoVazio
        v-else-if="erro?.status === 404"
        class="livro-estado"
        :nivel="1"
        titulo="Livro não encontrado"
        descricao="O livro que você procura não está disponível no acervo."
      >
        <template #acao><Botao tipo="contorno" :to="voltarPara">Voltar ao acervo</Botao></template>
      </EstadoVazio>

      <div v-else-if="erro?.status === 401 || erro?.status === 403" class="livro-estado">
        <Alerta tipo="erro">Este material é restrito e não pode ser exibido.</Alerta>
        <Botao tipo="contorno" :to="voltarPara">Voltar ao acervo</Botao>
      </div>

      <div v-else-if="erro" class="livro-estado">
        <Alerta tipo="erro">Não foi possível carregar este livro. Tente novamente.</Alerta>
        <Botao tipo="contorno" :to="voltarPara">Voltar ao acervo</Botao>
      </div>

      <article v-else-if="livro" class="livro-conteudo" :class="`cat-${chaveCategoria(categoria)}`">
        <Botao class="livro-voltar" tipo="contorno" :to="voltarPara">← Voltar ao acervo</Botao>

        <div class="livro-cabecalho">
          <div class="livro-capa">
            <img v-if="livro.capa_url" :src="livro.capa_url" :alt="`Capa de ${livro.titulo}`">
            <Icone v-else nome="livro" :tamanho="64" aria-hidden="true" />
          </div>

          <div class="livro-resumo">
            <p v-if="categoria" class="livro-categoria">{{ categoria }}</p>
            <h1 class="livro-titulo">{{ livro.titulo }}</h1>
            <p v-if="livro.autor" class="livro-autor">{{ livro.autor }}</p>

            <div v-if="formatos.length" class="livro-formatos" aria-label="Formatos disponíveis">
              <TagFormato v-for="(formato, indice) in formatos" :key="chaveFormato(formato, indice)" :icone="formato.tipo === 'audio' ? 'fones' : 'livro'">
                {{ textoFormato(formato.tipo) }}
              </TagFormato>
            </div>

            <BotaoFavorito v-if="auth.usuario" class="livro-favorito" :livro-id="livro.id" :titulo="livro.titulo" />

            <Botao v-if="administrador" class="livro-admin" tipo="contorno" :to="`/admin/livros/${livro.id}/classificacoes`">
              Editar classificações
            </Botao>
          </div>
        </div>

        <section v-if="livro.descricao" class="livro-secao" aria-labelledby="titulo-descricao">
          <h2 id="titulo-descricao">Sobre o livro</h2>
          <p>{{ livro.descricao }}</p>
        </section>

        <section v-if="classificacoes.length" class="livro-secao" aria-labelledby="titulo-classificacoes">
          <h2 id="titulo-classificacoes">Classificações</h2>
          <ul class="livro-classificacoes">
            <li v-for="(classificacao, indice) in classificacoes" :key="chaveClassificacao(classificacao, indice)">
              <strong v-if="classificacao.tipo">{{ rotuloTipo(classificacao.tipo) }}</strong>
              <span v-if="classificacao.nome">{{ classificacao.nome }}</span>
              <p v-if="classificacao.descricao">{{ classificacao.descricao }}</p>
            </li>
          </ul>
        </section>
      </article>
    </component>

    <Rodape v-if="!logada" />
  </component>
</template>

<style scoped>
.livro-detalhe {
  min-height: 60vh;
  padding: var(--espaco-48) clamp(var(--espaco-24), 9.8vw, 141px) var(--espaco-64);
  background: var(--fundo-pagina);
}

/* Na área logada, quem dá o espaçamento e o fundo é o LayoutLogado */
.livro-detalhe.livro-detalhe--logado {
  min-height: 0;
  padding: 0;
  background: none;
}

.livro-conteudo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-32);
  max-width: 1096px;
  margin-inline: auto;
}

.livro-voltar {
  align-self: flex-start;
}

.livro-cabecalho {
  display: grid;
  grid-template-columns: minmax(220px, 320px) 1fr;
  gap: var(--espaco-48);
  align-items: center;
}

.livro-capa {
  display: grid;
  place-items: center;
  min-height: 380px;
  overflow: hidden;
  border-radius: var(--raio-20);
  background: var(--cat-capa);
  color: var(--texto-principal);
}

.livro-capa img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.livro-resumo {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-12);
}

.livro-categoria {
  color: var(--texto-principal);
  font: var(--fonte-rotulo);
  letter-spacing: var(--letras-rotulo);
  text-transform: uppercase;
}

.livro-titulo {
  color: var(--texto-principal);
  font: var(--fonte-display);
}

.livro-autor {
  color: var(--texto-secundario);
  font: var(--fonte-corpo);
}

.livro-formatos {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-8);
  margin-top: var(--espaco-8);
}

.livro-favorito,
.livro-admin {
  margin-top: var(--espaco-8);
}

.livro-secao {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-12);
  max-width: 760px;
}

.livro-secao h2 {
  color: var(--texto-principal);
  font: var(--fonte-subtitulo);
}

.livro-secao > p {
  color: var(--texto-corpo);
  font: var(--fonte-corpo);
  white-space: pre-line;
}

.livro-classificacoes {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: var(--espaco-16);
  list-style: none;
}

.livro-classificacoes li {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-4);
  padding: var(--espaco-16);
  border-radius: var(--raio-12);
  background: var(--fundo-nuvem);
  color: var(--texto-corpo);
  font: var(--fonte-legenda);
}

.livro-classificacoes strong {
  color: var(--texto-principal);
  font: var(--fonte-rotulo);
  text-transform: uppercase;
}

.livro-classificacoes p {
  color: var(--texto-secundario);
}

/* ===== Carregando, não encontrado e erro ===== */
.livro-estado {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--espaco-24);
  max-width: 520px;
  margin: 0 auto;
  padding-top: var(--espaco-48);
  text-align: center;
}

.livro-estado-titulo {
  color: var(--texto-principal);
  font: var(--fonte-subtitulo);
}

.livro-carregando {
  width: 100%;
  height: 180px;
  border-radius: var(--raio-20);
  background: linear-gradient(90deg, var(--fundo-suave), var(--fundo-nuvem), var(--fundo-suave));
  background-size: 200% 100%;
  animation: carregando 1.2s infinite;
}

@keyframes carregando {
  to {
    background-position: -200% 0;
  }
}

/* Quem pediu menos movimento vê o esqueleto parado */
@media (prefers-reduced-motion: reduce) {
  .livro-carregando {
    animation: none;
  }
}

@media (max-width: 640px) {
  .livro-detalhe {
    padding-top: var(--espaco-32);
  }

  .livro-cabecalho {
    grid-template-columns: 1fr;
    gap: var(--espaco-24);
  }

  .livro-capa {
    min-height: 300px;
  }

  .livro-titulo {
    font: var(--fonte-titulo);
  }
}
</style>
