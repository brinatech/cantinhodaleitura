<!--
  Categorias do acervo (HU-08 Task 3), só para administrador.
  Sem tela no Figma: montada com os componentes do design system.
  Um formulário serve para criar e para editar; a lista fica embaixo.
  A proteção de verdade é do Rails (401/403); aqui só mostramos a mensagem certa.
-->
<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import LayoutLogado from '../../components/layout/LayoutLogado.vue'
import Alerta from '../../components/ui/Alerta.vue'
import Botao from '../../components/ui/Botao.vue'
import CampoFormulario from '../../components/ui/CampoFormulario.vue'
import EstadoVazio from '../../components/ui/EstadoVazio.vue'
import ModalConfirmacao from '../../components/ui/ModalConfirmacao.vue'
import { ErroApi } from '../../services/api.js'
import {
  criarCategoria,
  editarCategoria,
  excluirCategoria,
  listarCategorias,
} from '../../services/admin/categoriasAdminService.js'

const categorias = ref([])
const carregando = ref(true)
const erroLista = ref('')
const salvando = ref(false)
const excluindo = ref(null) // id da categoria que está sendo excluída
const editando = ref(null) // categoria em edição; null = criando uma nova
const formulario = reactive({ nome: '', descricao: '' })
const erros = reactive({ nome: '', descricao: '' })
const aviso = reactive({ tipo: 'sucesso', texto: '' })
const campoNome = ref(null)
const modalExclusao = ref(null)
const paraExcluir = ref(null) // categoria escolhida no botão "Excluir"
const erroExclusao = ref('')

const SEM_SERVIDOR = 'Não conseguimos conectar ao servidor. Tente de novo.'
const ROTULOS = { nome: 'Nome', descricao: 'Descrição' }

const tituloFormulario = computed(() => (editando.value ? `Editar "${editando.value.nome}"` : 'Nova categoria'))

function mensagemDoErro(erro) {
  if (!(erro instanceof ErroApi)) return SEM_SERVIDOR
  if (erro.status === 401) return 'Sua sessão terminou. Entre de novo para continuar.'
  if (erro.status === 403) return 'Só administradores podem gerenciar categorias.'
  return erro.message
}

const ordenar = (lista) => [...lista].sort((a, b) => a.nome.localeCompare(b.nome, 'pt-BR'))

async function carregar() {
  carregando.value = true
  erroLista.value = ''
  try {
    categorias.value = ordenar(await listarCategorias())
  } catch (erro) {
    erroLista.value = mensagemDoErro(erro)
  } finally {
    carregando.value = false
  }
}

onMounted(carregar)

function limparMensagens() {
  Object.assign(erros, { nome: '', descricao: '' })
  aviso.texto = ''
}

function limparFormulario() {
  editando.value = null
  Object.assign(formulario, { nome: '', descricao: '' })
  Object.assign(erros, { nome: '', descricao: '' })
}

function comecarEdicao(categoria) {
  limparMensagens()
  editando.value = categoria
  Object.assign(formulario, { nome: categoria.nome, descricao: categoria.descricao ?? '' })
  campoNome.value?.$el.scrollIntoView({ behavior: 'smooth', block: 'center' })
  campoNome.value?.$el.querySelector('input')?.focus({ preventScroll: true })
}

async function salvar() {
  limparMensagens()
  // Validação só para ajudar quem digita; quem decide é o Rails (422 com erros por campo)
  const nome = formulario.nome.trim()
  if (!nome) erros.nome = 'Escreva o nome da categoria.'
  if (nome.length > 100) erros.nome = 'O nome pode ter no máximo 100 caracteres.'
  if (erros.nome) return

  salvando.value = true
  const dados = { nome, descricao: formulario.descricao.trim() }
  try {
    if (editando.value) {
      const atualizada = await editarCategoria(editando.value.id, dados)
      categorias.value = ordenar(categorias.value.map((item) => (item.id === atualizada.id ? atualizada : item)))
      Object.assign(aviso, { tipo: 'sucesso', texto: `Categoria "${atualizada.nome}" atualizada.` })
    } else {
      const criada = await criarCategoria(dados)
      categorias.value = ordenar([...categorias.value, criada])
      Object.assign(aviso, { tipo: 'sucesso', texto: `Categoria "${criada.nome}" criada.` })
    }
    limparFormulario()
  } catch (erro) {
    let achou = false
    for (const [campo, rotulo] of Object.entries(ROTULOS)) {
      const mensagem = erro instanceof ErroApi ? erro.erros?.[campo]?.[0] : null
      if (mensagem) {
        erros[campo] = `${rotulo} ${mensagem}.`
        achou = true
      }
    }
    if (!achou) Object.assign(aviso, { tipo: 'erro', texto: mensagemDoErro(erro) })
  } finally {
    salvando.value = false
  }
}

// "Excluir" na lista só abre o modal; a exclusão acontece no botão do modal
function pedirExclusao(categoria) {
  limparMensagens()
  paraExcluir.value = categoria
  erroExclusao.value = ''
  modalExclusao.value.abrir()
}

async function confirmarExclusao() {
  const categoria = paraExcluir.value
  excluindo.value = categoria.id
  erroExclusao.value = ''
  const tirarDaLista = () => (categorias.value = categorias.value.filter((item) => item.id !== categoria.id))
  try {
    await excluirCategoria(categoria.id)
    tirarDaLista()
    if (editando.value?.id === categoria.id) limparFormulario()
    Object.assign(aviso, { tipo: 'sucesso', texto: `Categoria "${categoria.nome}" excluída.` })
    excluindo.value = null
    modalExclusao.value.fechar()
  } catch (erro) {
    excluindo.value = null
    if (erro instanceof ErroApi && erro.status === 404) {
      // alguém já tinha excluído: tira da lista e avisa fora do modal
      tirarDaLista()
      modalExclusao.value.fechar()
      Object.assign(aviso, { tipo: 'erro', texto: `A categoria "${categoria.nome}" já tinha sido excluída.` })
      return
    }
    // 409 e outros erros ficam dentro do modal, perto de quem tentou excluir
    erroExclusao.value =
      erro instanceof ErroApi && erro.status === 409
        ? 'Esta categoria tem livros e não pode ser excluída. Mude esses livros de categoria antes.'
        : mensagemDoErro(erro)
  }
}
</script>

<template>
  <LayoutLogado>
    <div class="admin-pagina">
      <div>
        <p class="admin-rotulo">Administração</p>
        <h1 class="admin-titulo">Categorias</h1>
        <p class="admin-subtitulo">Organize o acervo. Cada livro pertence a uma categoria.</p>
      </div>

      <Alerta v-if="aviso.texto" :tipo="aviso.tipo">{{ aviso.texto }}</Alerta>

      <form v-if="!erroLista" class="cartao" novalidate @submit.prevent="salvar">
        <h2 class="cartao-titulo">{{ tituloFormulario }}</h2>

        <CampoFormulario
          ref="campoNome"
          v-model="formulario.nome"
          label="Nome"
          name="nome"
          maxlength="100"
          ajuda="Ex.: Fantasia, Aventura, Poesia."
          :erro="erros.nome"
          @input="erros.nome = ''"
        />
        <CampoFormulario
          v-model="formulario.descricao"
          label="Descrição (opcional)"
          name="descricao"
          :erro="erros.descricao"
          @input="erros.descricao = ''"
        />

        <div class="cartao-acoes">
          <Botao type="submit" :disabled="salvando || carregando">
            {{ salvando ? 'Salvando...' : editando ? 'Salvar alterações' : 'Criar categoria' }}
          </Botao>
          <Botao v-if="editando" tipo="contorno" :disabled="salvando" @click="limparFormulario">
            Cancelar edição
          </Botao>
        </div>
      </form>

      <section class="cartao" aria-labelledby="titulo-lista-categorias" :aria-busy="carregando">
        <h2 id="titulo-lista-categorias" class="cartao-titulo">
          Categorias cadastradas<span v-if="!carregando && !erroLista"> ({{ categorias.length }})</span>
        </h2>

        <p v-if="carregando" class="cartao-texto" role="status">Carregando categorias...</p>

        <template v-else-if="erroLista">
          <Alerta tipo="erro">{{ erroLista }}</Alerta>
          <Botao tipo="contorno" @click="carregar">Tentar de novo</Botao>
        </template>

        <EstadoVazio
          v-else-if="!categorias.length"
          :nivel="3"
          titulo="Nenhuma categoria cadastrada"
          descricao="Crie a primeira categoria no formulário acima."
        />

        <ul v-else class="lista">
          <li v-for="categoria in categorias" :key="categoria.id" class="item">
            <div class="item-texto">
              <span class="item-nome">{{ categoria.nome }}</span>
              <span v-if="categoria.descricao" class="item-descricao">{{ categoria.descricao }}</span>
            </div>
            <div class="item-acoes">
              <Botao
                tipo="contorno"
                :disabled="excluindo === categoria.id"
                :aria-label="`Editar ${categoria.nome}`"
                @click="comecarEdicao(categoria)"
              >
                Editar
              </Botao>
              <Botao
                tipo="contorno"
                :disabled="excluindo === categoria.id"
                :aria-label="`Excluir ${categoria.nome}`"
                @click="pedirExclusao(categoria)"
              >
                Excluir
              </Botao>
            </div>
          </li>
        </ul>
      </section>
    </div>

    <ModalConfirmacao
      ref="modalExclusao"
      titulo="Excluir categoria?"
      texto-confirmar="Excluir"
      texto-carregando="Excluindo..."
      :carregando="excluindo !== null"
      :erro="erroExclusao"
      @confirmar="confirmarExclusao"
      @fechado="paraExcluir = null"
    >
      <p v-if="paraExcluir">
        A categoria <strong>{{ paraExcluir.nome }}</strong> será excluída. Essa ação não pode ser desfeita.
      </p>
    </ModalConfirmacao>
  </LayoutLogado>
</template>

<style scoped>
.admin-pagina {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-24);
  max-width: 720px;
  margin-inline: auto;
}

.admin-rotulo {
  margin-bottom: var(--espaco-4);
  color: var(--texto-secundario);
  font: var(--fonte-rotulo);
  letter-spacing: var(--letras-rotulo);
  text-transform: uppercase;
}

.admin-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.admin-subtitulo {
  margin-top: var(--espaco-8);
  color: var(--texto-secundario);
  font: var(--fonte-interface);
}

.cartao {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-16);
  padding: var(--espaco-32);
  border-radius: var(--raio-20);
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-cartao);
}

.cartao > :deep(.vazio) {
  align-self: center;
}

.cartao > button {
  align-self: flex-start;
}

.cartao-titulo {
  color: var(--texto-principal);
  font: var(--fonte-subtitulo);
}

.cartao-texto {
  color: var(--texto-secundario);
  font: var(--fonte-interface);
}

.cartao-acoes {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-12);
}

.lista {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
  padding: 0;
  list-style: none;
}

.item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--espaco-16);
  padding: var(--espaco-12) var(--espaco-16);
  border-radius: var(--raio-12);
  background: var(--fundo-nuvem);
}

.item-texto {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-4);
  min-width: 0;
}

.item-nome {
  color: var(--texto-principal);
  font: var(--fonte-botao);
  overflow-wrap: anywhere;
}

.item-descricao {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
  overflow-wrap: anywhere;
}

.item-acoes {
  display: flex;
  flex-shrink: 0;
  gap: var(--espaco-8);
}

@media (max-width: 520px) {
  .cartao {
    padding: var(--espaco-24) var(--espaco-16);
  }

  .item {
    flex-direction: column;
    align-items: stretch;
  }

  .item-acoes > * {
    flex: 1;
  }
}
</style>
