<!--
  Meu perfil. O Figma ainda não desenhou esta tela: segue o design system (mesma moldura
  da área logada, campos e botões do Cantinho). Dois formulários: dados (nome e e-mail)
  e troca de senha (pede a senha atual). Exclusão de conta fica de fora até a SESFA
  definir a política de retenção de dados.
-->
<script setup>
import { onMounted, reactive, ref } from 'vue'
import LayoutLogado from '../components/layout/LayoutLogado.vue'
import Alerta from '../components/ui/Alerta.vue'
import Botao from '../components/ui/Botao.vue'
import CampoFormulario from '../components/ui/CampoFormulario.vue'
import { ErroApi } from '../services/api.js'
import { buscarPerfil, salvarPerfil, trocarSenha } from '../services/perfilService.js'
import { useAuthStore } from '../stores/auth.js'

const auth = useAuthStore()

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
    </div>
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
</style>
