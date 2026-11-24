<!--
  Editor das classificações de um livro (HU-09 Task 3), só para administrador.
  Lista as classificações agrupadas por tipo, adiciona (tipo, nome, descrição) e remove.
  Feito para encaixar na futura tela admin de livros (HU-07 Task 4): basta passar o livro-id.
  A proteção de verdade é do Rails (401/403); aqui só mostramos a mensagem certa.
-->
<script setup>
import { computed, reactive, ref, watch } from 'vue'
import Alerta from '../ui/Alerta.vue'
import Botao from '../ui/Botao.vue'
import CampoFormulario from '../ui/CampoFormulario.vue'
import Icone from '../ui/Icone.vue'
import { ErroApi } from '../../services/api.js'
import { criarClassificacao, excluirClassificacao, listarClassificacoes } from '../../services/admin/classificacoesService.js'
import { RECURSOS_ACESSIBILIDADE, TIPOS_CLASSIFICACAO } from '../../services/tiposClassificacao.js'

const props = defineProps({
  livroId: { type: [String, Number], required: true },
})

const classificacoes = ref([])
const carregando = ref(true)
const erroLista = ref('')
const salvando = ref(false)
const removendo = ref(null) // id da classificação que está sendo removida
const nova = reactive({ tipo: '', nome: '', descricao: '' })
const erros = reactive({ tipo: '', nome: '', descricao: '' })
const aviso = reactive({ tipo: 'sucesso', texto: '' })

const SEM_SERVIDOR = 'Não conseguimos conectar ao servidor. Tente de novo.'
const ROTULOS = { tipo: 'Tipo', nome: 'Nome', descricao: 'Descrição' }

function mensagemDoErro(erro) {
  if (!(erro instanceof ErroApi)) return SEM_SERVIDOR
  if (erro.status === 401) return 'Sua sessão terminou. Entre de novo para continuar.'
  if (erro.status === 403) return 'Só administradores podem editar classificações.'
  return erro.message
}

// Um grupo por tipo, na ordem da lista. Tipo fora da lista (dado antigo) vai para "Outros".
const grupos = computed(() => {
  const valores = TIPOS_CLASSIFICACAO.map((tipo) => tipo.valor)
  const conhecidos = TIPOS_CLASSIFICACAO.map(({ valor, rotulo }) => ({
    valor,
    rotulo,
    itens: classificacoes.value.filter((item) => item.tipo === valor),
  }))
  const outros = { valor: 'outros', rotulo: 'Outros', itens: classificacoes.value.filter((item) => !valores.includes(item.tipo)) }
  return [...conhecidos, outros].filter((grupo) => grupo.itens.length)
})

async function carregar() {
  carregando.value = true
  erroLista.value = ''
  try {
    classificacoes.value = await listarClassificacoes(props.livroId)
  } catch (erro) {
    erroLista.value = mensagemDoErro(erro)
  } finally {
    carregando.value = false
  }
}

watch(() => props.livroId, carregar, { immediate: true })

// Acessibilidade tem lista fechada de recursos (HU-17): o nome vira uma escolha, não texto livre
const ehAcessibilidade = computed(() => nova.tipo === 'acessibilidade')
watch(() => nova.tipo, () => (nova.nome = '')) // o nome de um tipo não vale no outro

function limparMensagens() {
  Object.assign(erros, { tipo: '', nome: '', descricao: '' })
  aviso.texto = ''
}

async function adicionar() {
  limparMensagens()
  // Validação só para ajudar quem digita; quem decide é o Rails (422 com erros por campo)
  if (!nova.tipo) erros.tipo = 'Escolha um tipo.'
  if (!nova.nome.trim()) erros.nome = ehAcessibilidade.value ? 'Escolha um recurso.' : 'Escreva o nome da classificação.'
  if (erros.tipo || erros.nome) return

  salvando.value = true
  try {
    const criada = await criarClassificacao(props.livroId, { ...nova, nome: nova.nome.trim() })
    classificacoes.value.push(criada)
    Object.assign(nova, { nome: '', descricao: '' }) // mantém o tipo: facilita cadastrar várias do mesmo tipo
    Object.assign(aviso, { tipo: 'sucesso', texto: `Classificação "${criada.nome}" adicionada.` })
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

async function remover(classificacao) {
  if (!window.confirm(`Remover a classificação "${classificacao.nome}"?`)) return
  limparMensagens()
  removendo.value = classificacao.id
  const tirarDaLista = () => (classificacoes.value = classificacoes.value.filter((item) => item.id !== classificacao.id))
  try {
    await excluirClassificacao(props.livroId, classificacao.id)
    tirarDaLista()
    Object.assign(aviso, { tipo: 'sucesso', texto: `Classificação "${classificacao.nome}" removida.` })
  } catch (erro) {
    if (erro instanceof ErroApi && erro.status === 404) tirarDaLista() // alguém já tinha removido
    Object.assign(aviso, { tipo: 'erro', texto: mensagemDoErro(erro) })
  } finally {
    removendo.value = null
  }
}
</script>

<template>
  <div class="classificacoes">
    <Alerta v-if="aviso.texto" :tipo="aviso.tipo">{{ aviso.texto }}</Alerta>

    <section class="cartao" aria-labelledby="titulo-classificacoes-atuais" :aria-busy="carregando">
      <h2 id="titulo-classificacoes-atuais" class="cartao-titulo">Classificações do livro</h2>

      <p v-if="carregando" class="cartao-texto" role="status">Carregando classificações...</p>
      <Alerta v-else-if="erroLista" tipo="erro">{{ erroLista }}</Alerta>
      <p v-else-if="!grupos.length" class="cartao-texto">Este livro ainda não tem classificações.</p>

      <div v-else class="grupos">
        <section v-for="grupo in grupos" :key="grupo.valor" class="grupo" :aria-labelledby="`grupo-${grupo.valor}`">
          <h3 :id="`grupo-${grupo.valor}`" class="grupo-titulo">{{ grupo.rotulo }}</h3>
          <ul class="grupo-lista">
            <li v-for="item in grupo.itens" :key="item.id" class="item">
              <div class="item-texto">
                <span class="item-nome">{{ item.nome || 'Sem nome' }}</span>
                <span v-if="item.descricao" class="item-descricao">{{ item.descricao }}</span>
              </div>
              <Botao
                tipo="contorno"
                :disabled="removendo === item.id"
                :aria-label="`Remover ${item.nome || 'classificação sem nome'}`"
                @click="remover(item)"
              >
                {{ removendo === item.id ? 'Removendo...' : 'Remover' }}
              </Botao>
            </li>
          </ul>
        </section>
      </div>
    </section>

    <form v-if="!erroLista" class="cartao" novalidate @submit.prevent="adicionar">
      <h2 class="cartao-titulo">Adicionar classificação</h2>

      <!-- O design system ainda não tem um select: segue o mesmo visual do CampoFormulario -->
      <div class="campo" :class="{ 'campo--erro': erros.tipo }">
        <label class="campo-label" for="classificacao-tipo">Tipo</label>
        <select
          id="classificacao-tipo"
          v-model="nova.tipo"
          class="campo-entrada"
          :aria-invalid="erros.tipo ? 'true' : undefined"
          :aria-describedby="erros.tipo ? 'classificacao-tipo-erro' : undefined"
          @change="erros.tipo = ''"
        >
          <option value="" disabled>Escolha um tipo</option>
          <option v-for="tipo in TIPOS_CLASSIFICACAO" :key="tipo.valor" :value="tipo.valor">{{ tipo.rotulo }}</option>
        </select>
        <p v-if="erros.tipo" id="classificacao-tipo-erro" class="campo-erro">
          <Icone nome="info" :tamanho="16" />
          {{ erros.tipo }}
        </p>
      </div>

      <div v-if="ehAcessibilidade" class="campo" :class="{ 'campo--erro': erros.nome }">
        <label class="campo-label" for="classificacao-recurso">Recurso</label>
        <select
          id="classificacao-recurso"
          v-model="nova.nome"
          class="campo-entrada"
          :aria-invalid="erros.nome ? 'true' : undefined"
          :aria-describedby="erros.nome ? 'classificacao-recurso-erro' : undefined"
          @change="erros.nome = ''"
        >
          <option value="" disabled>Escolha um recurso</option>
          <option v-for="recurso in RECURSOS_ACESSIBILIDADE" :key="recurso" :value="recurso">{{ recurso }}</option>
        </select>
        <p v-if="erros.nome" id="classificacao-recurso-erro" class="campo-erro">
          <Icone nome="info" :tamanho="16" />
          {{ erros.nome }}
        </p>
      </div>

      <CampoFormulario
        v-else
        v-model="nova.nome"
        label="Nome"
        name="nome"
        maxlength="100"
        ajuda="Ex.: 6+, Fantasia, PDF."
        :erro="erros.nome"
        @input="erros.nome = ''"
      />
      <CampoFormulario
        v-model="nova.descricao"
        label="Descrição (opcional)"
        name="descricao"
        :erro="erros.descricao"
        @input="erros.descricao = ''"
      />

      <Botao type="submit" :disabled="salvando || carregando">{{ salvando ? 'Adicionando...' : 'Adicionar' }}</Botao>
    </form>
  </div>
</template>

<style scoped>
.classificacoes {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-24);
}

.cartao {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-16);
  padding: var(--espaco-32);
  border-radius: var(--raio-20);
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-cartao);
}

.cartao > * {
  align-self: stretch;
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

.grupos {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-24);
}

.grupo-titulo {
  margin-bottom: var(--espaco-8);
  color: var(--texto-secundario);
  font: var(--fonte-rotulo);
  letter-spacing: var(--letras-rotulo);
  text-transform: uppercase;
}

.grupo-lista {
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
}

.item-descricao {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}

/* Mesmo visual do CampoFormulario, para o select */
.campo {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-8);
}

.campo-label {
  color: var(--texto-principal);
  font: var(--fonte-botao);
}

.campo-entrada {
  width: 100%;
  padding: var(--espaco-12) var(--espaco-16);
  border: 0;
  border-radius: var(--raio-8);
  background: var(--fundo-superficie);
  box-shadow: inset 0 0 0 1.5px var(--borda-padrao);
  color: var(--texto-corpo);
  font: var(--fonte-interface);
  outline: none;
}

.campo-entrada:focus {
  box-shadow: inset 0 0 0 2px var(--borda-foco);
}

.campo--erro .campo-entrada {
  box-shadow: inset 0 0 0 2px var(--borda-erro);
}

.campo-erro {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--texto-erro);
  font: var(--fonte-legenda);
}

@media (max-width: 520px) {
  .cartao {
    padding: var(--espaco-24) var(--espaco-16);
  }

  .item {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
