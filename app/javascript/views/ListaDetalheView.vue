<!--
  Detalhe de uma lista de leitura (HU-13 Task 4). Sem tela no Figma.
  Mostra o nome, a descrição e os livros da lista (o adicionado mais recentemente primeiro).
  Dá para editar o nome/descrição, excluir a lista (com confirmação) e tirar um livro.
  Livros entram na lista pela página do livro ("Adicionar à lista").
  Lista de outra pessoa ou que não existe: a API responde 404 e a tela mostra "não encontrada".
-->
<script setup>
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import LayoutLogado from '../components/layout/LayoutLogado.vue'
import FormLista from '../components/listas/FormLista.vue'
import Alerta from '../components/ui/Alerta.vue'
import Botao from '../components/ui/Botao.vue'
import CardLivro from '../components/ui/CardLivro.vue'
import EstadoVazio from '../components/ui/EstadoVazio.vue'
import ModalConfirmacao from '../components/ui/ModalConfirmacao.vue'
import { buscarLista, excluirLista, removerLivro, salvarLista } from '../services/listasService.js'

const rota = useRoute()
const roteador = useRouter()

const lista = ref(null)
const carregando = ref(true)
const erro = ref(null) // ErroApi (status 404 = não encontrada)

const editando = ref(false)
const salvando = ref(false)
const errosServidor = ref({})
const erroAcao = ref('')
const aviso = ref('') // confirmação lida pelo leitor de tela

const contagem = computed(() => (lista.value?.livros.length === 1 ? '1 livro' : `${lista.value?.livros.length ?? 0} livros`))

async function carregar(id) {
  carregando.value = true
  erro.value = null
  lista.value = null
  editando.value = false
  try {
    lista.value = await buscarLista(id)
  } catch (falha) {
    erro.value = falha
  } finally {
    carregando.value = false
  }
}

async function salvar(dados) {
  salvando.value = true
  errosServidor.value = {}
  erroAcao.value = ''
  try {
    const atualizada = await salvarLista(lista.value.id, dados)
    lista.value = { ...lista.value, nome: atualizada.nome, descricao: atualizada.descricao }
    editando.value = false
    aviso.value = 'Lista atualizada.'
  } catch (falha) {
    if (falha.status === 422) errosServidor.value = falha.erros ?? {}
    else erroAcao.value = 'Não foi possível salvar. Tente de novo.'
  } finally {
    salvando.value = false
  }
}

// ===== Tirar um livro =====
const removendo = ref(null) // id do livro que está saindo (trava o botão)

async function tirar(livro) {
  removendo.value = livro.id
  erroAcao.value = ''
  try {
    await removerLivro(lista.value.id, livro.id)
    lista.value.livros = lista.value.livros.filter((item) => item.id !== livro.id)
    aviso.value = `${livro.titulo} saiu da lista.`
  } catch (falha) {
    // 404: já tinha saído (em outra aba). Só acerta a tela.
    if (falha.status === 404) lista.value.livros = lista.value.livros.filter((item) => item.id !== livro.id)
    else erroAcao.value = `Não foi possível tirar ${livro.titulo} da lista. Tente de novo.`
  } finally {
    removendo.value = null
  }
}

// ===== Excluir a lista =====
const modalExcluir = ref(null)
const excluindo = ref(false)
const erroExcluir = ref('')

function pedirExclusao() {
  erroExcluir.value = ''
  modalExcluir.value.abrir()
}

async function excluir() {
  excluindo.value = true
  try {
    await excluirLista(lista.value.id)
    modalExcluir.value.fechar()
    roteador.push('/listas-de-leitura')
  } catch {
    erroExcluir.value = 'Não foi possível excluir a lista. Tente de novo.'
  } finally {
    excluindo.value = false
  }
}

watch(() => rota.params.id, carregar, { immediate: true })
</script>

<template>
  <LayoutLogado>
    <div class="lista">
      <Botao class="lista-voltar" tipo="contorno" to="/listas-de-leitura">← Minhas listas</Botao>

      <p v-if="carregando" class="lista-aviso" role="status">Carregando lista…</p>

      <EstadoVazio
        v-else-if="erro?.status === 404"
        class="lista-estado"
        :nivel="1"
        titulo="Lista não encontrada"
        descricao="Ela pode ter sido excluída."
      >
        <template #acao><Botao tipo="contorno" to="/listas-de-leitura">Ver minhas listas</Botao></template>
      </EstadoVazio>

      <EstadoVazio
        v-else-if="erro"
        class="lista-estado"
        :nivel="1"
        titulo="Não conseguimos carregar a lista"
        descricao="Verifique sua conexão e tente de novo."
      >
        <template #acao><Botao tipo="contorno" @click="carregar(rota.params.id)">Tentar de novo</Botao></template>
      </EstadoVazio>

      <template v-else-if="lista">
        <header v-if="!editando" class="lista-topo">
          <h1 class="lista-titulo">{{ lista.nome }}</h1>
          <p v-if="lista.descricao" class="lista-descricao">{{ lista.descricao }}</p>
          <p class="lista-contagem" aria-live="polite">{{ contagem }}</p>
          <div class="lista-acoes">
            <Botao tipo="contorno" @click="editando = true">Editar lista</Botao>
            <Botao tipo="contorno" @click="pedirExclusao">Excluir lista</Botao>
          </div>
        </header>

        <section v-else class="lista-cartao" aria-labelledby="titulo-editar">
          <h1 id="titulo-editar" class="lista-cartao-titulo">Editar lista</h1>
          <FormLista
            :inicial="lista"
            texto-salvar="Salvar"
            :salvando="salvando"
            :erros-servidor="errosServidor"
            @salvar="salvar"
            @cancelar="editando = false"
          />
        </section>

        <p class="so-leitor" role="status">{{ aviso }}</p>
        <Alerta v-if="erroAcao" tipo="erro">{{ erroAcao }}</Alerta>

        <EstadoVazio
          v-if="!lista.livros.length"
          class="lista-estado"
          :nivel="2"
          titulo="Esta lista ainda está vazia"
          descricao="Abra um livro no acervo e use &quot;Adicionar à lista&quot;."
        >
          <template #acao><Botao tipo="contorno" to="/acervo">Explorar o acervo</Botao></template>
        </EstadoVazio>

        <ul v-else class="lista-grade">
          <li v-for="livro in lista.livros" :key="livro.id" class="lista-item">
            <CardLivro
              :nivel="2"
              :titulo="livro.titulo"
              :autor="livro.autor || ''"
              :categoria="livro.categoria?.nome"
              :capa-url="livro.capa_url"
              :to="{ name: 'livro-detalhe-logado', params: { id: livro.id } }"
              :mostrar-favoritar="false"
            />
            <Botao
              tipo="contorno"
              class="lista-tirar"
              :disabled="removendo === livro.id"
              :aria-label="`${removendo === livro.id ? 'Tirando...' : 'Tirar da lista'}: ${livro.titulo}`"
              @click="tirar(livro)"
            >
              {{ removendo === livro.id ? 'Tirando...' : 'Tirar da lista' }}
            </Botao>
          </li>
        </ul>
      </template>

      <ModalConfirmacao
        ref="modalExcluir"
        titulo="Excluir esta lista?"
        texto-confirmar="Excluir"
        texto-carregando="Excluindo..."
        :carregando="excluindo"
        :erro="erroExcluir"
        @confirmar="excluir"
      >
        A lista <strong>{{ lista?.nome }}</strong> vai ser apagada. Os livros continuam no acervo.
      </ModalConfirmacao>
    </div>
  </LayoutLogado>
</template>

<style scoped>
.lista {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-24);
  max-width: 1096px;
  margin-inline: auto;
}

.lista-voltar {
  align-self: flex-start;
}

.lista-topo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
}

.lista-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
  overflow-wrap: anywhere;
}

.lista-descricao {
  max-width: 720px;
  color: var(--texto-corpo);
  font: var(--fonte-corpo);
}

.lista-contagem,
.lista-aviso {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}

.lista-acoes {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-12);
  margin-top: var(--espaco-8);
}

.lista-cartao {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-16);
  max-width: 560px;
  padding: var(--espaco-24);
  border-radius: var(--raio-20);
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-cartao);
}

.lista-cartao-titulo {
  color: var(--texto-principal);
  font: var(--fonte-subtitulo);
}

.lista-estado {
  align-self: center;
}

/* Mesma grade do acervo, com o botão "Tirar da lista" embaixo de cada card */
.lista-grade {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(min(240px, calc(50% - 10px)), 1fr)); /* no celular: 2 colunas (50% menos meio espaço de 20px) */
  gap: 20px;
  list-style: none;
}

.lista-item {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
}

.lista-item > :first-child {
  flex: 1;
}

.lista-tirar {
  width: 100%;
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
