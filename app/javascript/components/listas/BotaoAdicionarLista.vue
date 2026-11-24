<!--
  "Adicionar à lista" na página do livro (HU-13 Task 4). Só para quem está logado.
  Abre uma janela (<dialog> nativo, como o ModalConfirmacao) com as listas do leitor:
  cada uma é uma caixinha marcada se o livro já está nela. Marcar põe o livro, desmarcar tira,
  na hora (a caixinha só muda depois que o servidor confirma).
  Também dá para criar uma lista nova ali mesmo: ela já nasce com este livro.
-->
<script setup>
import { computed, ref, useId } from 'vue'
import Alerta from '../ui/Alerta.vue'
import Botao from '../ui/Botao.vue'
import CampoFormulario from '../ui/CampoFormulario.vue'
import Icone from '../ui/Icone.vue'
import { adicionarLivro, criarLista, listarListas, removerLivro } from '../../services/listasService.js'

const props = defineProps({
  livroId: { type: [Number, String], required: true },
  titulo: { type: String, required: true },
})

const id = computed(() => Number(props.livroId))
const dialogo = ref(null)
const idTitulo = useId()

const listas = ref([])
const carregando = ref(false)
const erroCarregar = ref(false)
const pendentes = ref([]) // ids das listas com pedido a caminho
const erro = ref('')
const aviso = ref('')

const estaNaLista = (lista) => lista.livro_ids.includes(id.value)
const quantasTem = computed(() => listas.value.filter(estaNaLista).length)

async function carregar() {
  carregando.value = true
  erroCarregar.value = false
  try {
    listas.value = await listarListas()
  } catch {
    erroCarregar.value = true
  } finally {
    carregando.value = false
  }
}

function abrir() {
  erro.value = ''
  aviso.value = ''
  nomeNova.value = ''
  erroNova.value = ''
  dialogo.value.showModal()
  carregar() // sempre atualizado (pode ter mudado em outra tela)
}

const fechar = () => dialogo.value.close()
const cliqueNoFundo = (evento) => evento.target === dialogo.value && fechar()

async function alternar(lista) {
  if (pendentes.value.includes(lista.id)) return
  erro.value = ''
  aviso.value = ''
  const tinha = estaNaLista(lista)
  pendentes.value.push(lista.id)
  try {
    if (tinha) await removerLivro(lista.id, id.value)
    else await adicionarLivro(lista.id, id.value)
    marcar(lista, !tinha)
  } catch (falha) {
    // 409 (já estava) e 404 (já tinha saído): outra aba mexeu; só acerta a caixinha
    if (falha.status === 409) marcar(lista, true)
    else if (falha.status === 404 && tinha) marcar(lista, false)
    else erro.value = tinha ? `Não foi possível tirar da lista "${lista.nome}".` : `Não foi possível pôr na lista "${lista.nome}".`
  } finally {
    pendentes.value = pendentes.value.filter((item) => item !== lista.id)
  }
}

function marcar(lista, dentro) {
  lista.livro_ids = dentro ? [...lista.livro_ids, id.value] : lista.livro_ids.filter((item) => item !== id.value)
  lista.total_livros = lista.livro_ids.length
  aviso.value = dentro ? `${props.titulo} entrou na lista "${lista.nome}".` : `${props.titulo} saiu da lista "${lista.nome}".`
}

// ===== Lista nova, já com este livro =====
const nomeNova = ref('')
const erroNova = ref('')
const criando = ref(false)

async function criarComLivro() {
  const nome = nomeNova.value.trim()
  if (!nome) {
    erroNova.value = 'Dê um nome para a lista.'
    return
  }
  criando.value = true
  erroNova.value = ''
  try {
    const nova = await criarLista({ nome, descricao: '' })
    await adicionarLivro(nova.id, id.value)
    nova.livro_ids = [id.value]
    nova.total_livros = 1
    listas.value = [nova, ...listas.value]
    nomeNova.value = ''
    aviso.value = `Lista "${nova.nome}" criada com ${props.titulo}.`
  } catch (falha) {
    erroNova.value = falha.erros?.nome?.[0] ? `O nome ${falha.erros.nome[0]}.` : 'Não foi possível criar a lista. Tente de novo.'
  } finally {
    criando.value = false
  }
}
</script>

<template>
  <Botao tipo="contorno" @click="abrir">
    <template #icone><Icone nome="lista" /></template>
    Adicionar à lista
  </Botao>

  <dialog ref="dialogo" class="janela" :aria-labelledby="idTitulo" @click="cliqueNoFundo">
    <div class="janela-conteudo">
      <div class="janela-topo">
        <h2 :id="idTitulo" class="janela-titulo">Adicionar à lista</h2>
        <button type="button" class="janela-fechar" aria-label="Fechar" @click="fechar">
          <Icone nome="fechar" :tamanho="20" />
        </button>
      </div>
      <p class="janela-texto">Marque as listas onde <strong>{{ titulo }}</strong> deve ficar.</p>

      <p v-if="carregando && !listas.length" class="janela-texto" role="status">Carregando suas listas…</p>

      <div v-else-if="erroCarregar" class="janela-erro">
        <Alerta tipo="erro">Não conseguimos carregar suas listas.</Alerta>
        <Botao tipo="contorno" @click="carregar">Tentar de novo</Botao>
      </div>

      <template v-else>
        <p v-if="!listas.length" class="janela-texto">Você ainda não tem listas. Crie a primeira abaixo.</p>

        <fieldset v-else class="janela-listas">
          <legend class="so-leitor">Suas listas ({{ quantasTem }} com este livro)</legend>
          <label v-for="lista in listas" :key="lista.id" class="janela-opcao">
            <input
              type="checkbox"
              :checked="estaNaLista(lista)"
              :disabled="pendentes.includes(lista.id)"
              @click.prevent="alternar(lista)"
            >
            <span class="janela-opcao-nome">{{ lista.nome }}</span>
            <span class="janela-opcao-total">{{ lista.total_livros === 1 ? '1 livro' : `${lista.total_livros} livros` }}</span>
          </label>
        </fieldset>

        <form class="janela-nova" novalidate @submit.prevent="criarComLivro">
          <CampoFormulario
            v-model="nomeNova"
            label="Nova lista com este livro"
            placeholder="Ex.: Para ler nas férias"
            maxlength="100"
            :erro="erroNova"
          />
          <Botao type="submit" tipo="contorno" :disabled="criando">{{ criando ? 'Criando...' : 'Criar e adicionar' }}</Botao>
        </form>
      </template>

      <p class="so-leitor" role="status">{{ aviso }}</p>
      <Alerta v-if="erro" tipo="erro">{{ erro }}</Alerta>

      <div class="janela-acoes">
        <Botao tipo="escuro" @click="fechar">Pronto</Botao>
      </div>
    </div>
  </dialog>
</template>

<style scoped>
/* Mesmo visual do ModalConfirmacao */
.janela::backdrop {
  background: color-mix(in srgb, var(--texto-corpo) 40%, transparent);
}

.janela {
  margin: auto; /* o reset do application.css zera a margem que centraliza o <dialog> */
  width: 480px;
  max-width: calc(100vw - 32px);
  max-height: calc(100vh - 32px);
  padding: 0;
  border: 1px solid var(--borda-padrao);
  border-radius: 24px;
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-flutuante);
  color: var(--texto-corpo);
}

.janela-conteudo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-16);
  padding: var(--espaco-24);
}

.janela-topo {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--espaco-12);
}

.janela-titulo {
  color: var(--texto-principal);
  font: var(--fonte-subtitulo);
}

.janela-fechar {
  display: inline-flex;
  padding: var(--espaco-8);
  border: 0;
  border-radius: var(--raio-total);
  background: transparent;
  color: var(--texto-principal);
  cursor: pointer;
  transition: transform var(--duracao-rapida) var(--curva), background-color var(--duracao-rapida) var(--curva);
}

.janela-fechar:hover {
  transform: scale(var(--crescer));
  background: var(--camada-hover);
}

.janela-fechar:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 2px;
}

.janela-texto {
  color: var(--texto-corpo);
  font: var(--fonte-interface);
}

.janela-erro {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-12);
}

.janela-listas {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
  max-height: 260px;
  margin: 0;
  padding: 0;
  overflow-y: auto;
  border: 0;
}

/* Cada lista é uma linha inteira clicável, com área de toque de 44px */
.janela-opcao {
  display: flex;
  align-items: center;
  gap: var(--espaco-12);
  min-height: 44px;
  padding: var(--espaco-8) var(--espaco-12);
  border-radius: var(--raio-12);
  background: var(--fundo-nuvem);
  cursor: pointer;
  transition: background-color var(--duracao-rapida) var(--curva);
}

.janela-opcao:hover {
  background: color-mix(in srgb, var(--fundo-nuvem), var(--texto-principal) 8%);
}

.janela-opcao:has(input:focus-visible) {
  box-shadow: inset 0 0 0 3px var(--borda-foco);
}

.janela-opcao input {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
  accent-color: var(--destaque-escuro);
}

.janela-opcao-nome {
  flex: 1;
  color: var(--texto-principal);
  font: var(--fonte-interface);
  overflow-wrap: anywhere;
}

.janela-opcao-total {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
  white-space: nowrap;
}

.janela-nova {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-12);
  padding-top: var(--espaco-16);
  border-top: 1px solid var(--borda-padrao);
}

.janela-nova > :first-child {
  width: 100%;
}

.janela-acoes {
  display: flex;
  justify-content: flex-end;
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
