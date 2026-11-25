<!--
  Meu perfil. O Figma ainda não desenhou esta tela: segue o design system (mesma moldura
  da área logada, campos e botões do Cantinho). Formulários: dados (nome e e-mail),
  troca de senha (pede a senha atual) e, só para leitor, "Excluir minha conta" (HU-21):
  confirmação com a senha atual; o Rails anonimiza a conta (docs/decisoes-negocio/retencao_exclusao_dados.md).
-->
<script setup>
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import LayoutLogado from '../components/layout/LayoutLogado.vue'
import Alerta from '../components/ui/Alerta.vue'
import Botao from '../components/ui/Botao.vue'
import CampoFormulario from '../components/ui/CampoFormulario.vue'
import ModalConfirmacao from '../components/ui/ModalConfirmacao.vue'
import { ErroApi } from '../services/api.js'
import { buscarPerfil, excluirConta, salvarPerfil, trocarSenha } from '../services/perfilService.js'
import { useAuthStore } from '../stores/auth.js'

const auth = useAuthStore()
const roteador = useRouter()

const dados = reactive({ nome: '', email: '' })
const senhas = reactive({ atual: '', nova: '' })
const errosDados = reactive({ nome: '', email: '' })
const errosSenha = reactive({ atual: '', nova: '' })
const avisoDados = reactive({ tipo: 'sucesso', texto: '' })
const avisoSenha = reactive({ tipo: 'sucesso', texto: '' })
const carregando = ref(true)
const salvando = ref(false)

const SEM_SERVIDOR = 'Não conseguimos conectar ao servidor. Tente de novo.'

const limpar = (...objetos) => objetos.forEach((o) => Object.keys(o).forEach((k) => (o[k] = '')))

onMounted(async () => {
  try {
    Object.assign(dados, await buscarPerfil())
  } catch {
    Object.assign(avisoDados, { tipo: 'erro', texto: SEM_SERVIDOR })
  } finally {
    carregando.value = false
  }
})

// Mostra os erros por campo que o Rails devolve ({ campo: [mensagens] }); sem campo, o aviso geral
function mostrarErros(erro, erros, aviso, campos) {
  if (!(erro instanceof ErroApi)) return Object.assign(aviso, { tipo: 'erro', texto: SEM_SERVIDOR })
  let achou = false
  for (const [campoApi, [local, rotulo]] of Object.entries(campos)) {
    const mensagem = erro.erros?.[campoApi]?.[0]
    if (mensagem) {
      erros[local] = `${rotulo} ${mensagem}.`
      achou = true
    }
  }
  if (!achou) Object.assign(aviso, { tipo: 'erro', texto: erro.message })
}

async function salvarDados() {
  limpar(errosDados, avisoDados)
  if (!dados.nome.trim()) return (errosDados.nome = 'Diga como você quer ser chamado.')
  salvando.value = true
  try {
    auth.usuario = await salvarPerfil(dados)
    Object.assign(avisoDados, { tipo: 'sucesso', texto: 'Dados salvos.' })
  } catch (erro) {
    mostrarErros(erro, errosDados, avisoDados, { nome: ['nome', 'Nome'], email: ['email', 'E-mail'] })
  } finally {
    salvando.value = false
  }
}

async function salvarSenha() {
  limpar(errosSenha, avisoSenha)
  if (!senhas.atual) return (errosSenha.atual = 'Digite sua senha atual.')
  if (senhas.nova.length < 8) return (errosSenha.nova = 'Use pelo menos 8 caracteres.')
  salvando.value = true
  try {
    await trocarSenha(senhas.atual, senhas.nova)
    limpar(senhas)
    Object.assign(avisoSenha, { tipo: 'sucesso', texto: 'Senha trocada.' })
  } catch (erro) {
    mostrarErros(erro, errosSenha, avisoSenha, { senha_atual: ['atual', 'Senha atual'], password: ['nova', 'Senha nova'] })
  } finally {
    salvando.value = false
  }
}

// Excluir a conta: o botão abre o modal; lá a pessoa digita a senha e confirma
const modalExclusao = ref(null)
const senhaExclusao = ref('')
const erroSenhaExclusao = ref('')
const erroExclusao = ref('')
const excluindo = ref(false)

function pedirExclusao() {
  senhaExclusao.value = ''
  erroSenhaExclusao.value = ''
  erroExclusao.value = ''
  modalExclusao.value.abrir()
}

async function confirmarExclusao() {
  erroSenhaExclusao.value = ''
  if (!senhaExclusao.value) return (erroSenhaExclusao.value = 'Digite sua senha para confirmar.')
  excluindo.value = true
  try {
    await excluirConta(senhaExclusao.value)
    excluindo.value = false
    modalExclusao.value.fechar()
    auth.esquecer()
    roteador.replace({ path: '/entrar', query: { aviso: 'conta-excluida' } })
  } catch (erro) {
    excluindo.value = false
    const senhaErrada = erro instanceof ErroApi && erro.erros?.senha_atual?.[0]
    if (senhaErrada) erroSenhaExclusao.value = `Senha ${senhaErrada}.`
    else erroExclusao.value = erro instanceof ErroApi ? erro.message : SEM_SERVIDOR
  }
}
</script>

<template>
  <LayoutLogado>
    <div class="perfil">
      <h1 class="perfil-titulo">Meu perfil</h1>

      <form class="cartao" novalidate :aria-busy="carregando" @submit.prevent="salvarDados">
        <h2 class="cartao-titulo">Seus dados</h2>
        <Alerta v-if="avisoDados.texto" :tipo="avisoDados.tipo">{{ avisoDados.texto }}</Alerta>
        <CampoFormulario v-model="dados.nome" label="Como você quer ser chamado?" name="nome" autocomplete="nickname" :erro="errosDados.nome" @input="errosDados.nome = ''" />
        <CampoFormulario v-model="dados.email" label="E-mail" type="email" name="email" autocomplete="email" :erro="errosDados.email" @input="errosDados.email = ''" />
        <Botao type="submit" :disabled="carregando || salvando">Salvar dados</Botao>
      </form>

      <form class="cartao" novalidate @submit.prevent="salvarSenha">
        <h2 class="cartao-titulo">Trocar senha</h2>
        <Alerta v-if="avisoSenha.texto" :tipo="avisoSenha.tipo">{{ avisoSenha.texto }}</Alerta>
        <CampoFormulario v-model="senhas.atual" label="Senha atual" type="password" name="senha-atual" autocomplete="current-password" :erro="errosSenha.atual" @input="errosSenha.atual = ''" />
        <CampoFormulario v-model="senhas.nova" label="Senha nova" type="password" name="senha-nova" autocomplete="new-password" ajuda="Mínimo de 8 caracteres." :erro="errosSenha.nova" @input="errosSenha.nova = ''" />
        <Botao type="submit" :disabled="salvando">Trocar senha</Botao>
      </form>

      <section v-if="!auth.ehAdministrador" class="cartao cartao--exclusao" aria-labelledby="titulo-exclusao">
        <h2 id="titulo-exclusao" class="cartao-titulo">Excluir minha conta</h2>
        <p class="cartao-texto">
          Seus favoritos, listas de leitura, marcadores e histórico são apagados, e seu nome e e-mail saem da biblioteca.
          Ficam só contagens sem identificação (quantas vezes cada livro foi lido), usadas nos relatórios da ONG.
          Não dá para desfazer, mas você pode criar uma conta nova depois com o mesmo e-mail.
        </p>
        <Botao tipo="contorno" @click="pedirExclusao">Excluir minha conta</Botao>
      </section>
    </div>

    <ModalConfirmacao
      ref="modalExclusao"
      titulo="Excluir sua conta?"
      texto-confirmar="Excluir conta"
      texto-carregando="Excluindo..."
      :carregando="excluindo"
      :erro="erroExclusao"
      @confirmar="confirmarExclusao"
    >
      <p>Esta ação não pode ser desfeita. Para confirmar, digite sua senha.</p>
      <CampoFormulario
        v-model="senhaExclusao"
        class="campo-exclusao"
        label="Sua senha"
        type="password"
        name="senha-exclusao"
        autocomplete="current-password"
        :erro="erroSenhaExclusao"
        @input="erroSenhaExclusao = ''"
        @keydown.enter.prevent="confirmarExclusao"
      />
    </ModalConfirmacao>
  </LayoutLogado>
</template>

<style scoped>
.perfil {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-24);
  max-width: 560px;
  margin-inline: auto;
}

.perfil-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
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

/* Ação sem volta: borda de alerta para não ser confundida com os outros formulários */
.cartao--exclusao {
  box-shadow: var(--sombra-cartao), inset 0 0 0 1.5px var(--apoio-coral);
}

.campo-exclusao {
  margin-top: var(--espaco-16);
}
</style>
