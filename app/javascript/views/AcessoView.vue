<!--
  Telas de acesso (Figma: "Acesso · Entrar", "Entrar com erro" e "Criar conta").
  Entrar e Criar conta são abas da mesma tela (rotas /entrar e /criar-conta). Esqueci a senha
  (/esqueci-senha) e Redefinir senha (/redefinir-senha, aberta pelo link do email) usam a mesma
  moldura e os mesmos campos: o Figma ainda não desenhou essas duas, então seguem o design system.
  A validação do navegador é só para ajudar; quem decide é o servidor (erros por campo do Rails).
-->
<script setup>
import { computed, nextTick, reactive, ref, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import PainelAcesso from '../components/acesso/PainelAcesso.vue'
import BotaoAcessibilidade from '../components/layout/BotaoAcessibilidade.vue'
import AbasAcesso from '../components/ui/AbasAcesso.vue'
import Alerta from '../components/ui/Alerta.vue'
import Botao from '../components/ui/Botao.vue'
import CampoFormulario from '../components/ui/CampoFormulario.vue'
import DestaquePalavra from '../components/ui/DestaquePalavra.vue'
import Icone from '../components/ui/Icone.vue'
import { ErroApi } from '../services/api.js'
import { redefinirSenha, solicitarRecuperacao } from '../services/authService.js'
import { useAuthStore } from '../stores/auth.js'
import logo from '../images/logo-header.png'
import nuvem from '../images/ilustracoes/acesso-nuvem.png'
import meninaLendo from '../images/ilustracoes/acesso-menina-lendo.png'

const rota = useRoute()
const roteador = useRouter()
const auth = useAuthStore()

const modo = computed(() => ({ '/criar-conta': 'criar', '/esqueci-senha': 'esqueci', '/redefinir-senha': 'redefinir' })[rota.path] ?? 'entrar')
const criando = computed(() => modo.value === 'criar')
const comAbas = computed(() => modo.value === 'entrar' || modo.value === 'criar')
const senhaRedefinida = computed(() => modo.value === 'entrar' && rota.query.aviso === 'senha-redefinida')
const aba = computed({
  get: () => (criando.value ? 'criar-conta' : 'entrar'),
  set: (valor) => roteador.push(`/${valor}`),
})

const campos = reactive({ nome: '', email: '', senha: '' })
const erros = reactive({ nome: '', email: '', senha: '' })
const avisoDoServidor = ref('')
const avisoDeSucesso = ref('')
const enviando = ref(false)

// Trocar de tela começa sem erros (o que foi digitado fica)
watch(modo, () => {
  Object.keys(erros).forEach((chave) => (erros[chave] = ''))
  avisoDoServidor.value = ''
  avisoDeSucesso.value = ''
})

const emailValido = (texto) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(texto.trim())

function validar() {
  const m = modo.value
  erros.nome = m === 'criar' && !campos.nome.trim() ? 'Diga como você quer ser chamado.' : ''
  erros.email = m === 'redefinir' || emailValido(campos.email) ? '' : 'Digite um e-mail válido, como maria@email.com.'
  if (m === 'esqueci') erros.senha = ''
  else if (!campos.senha) erros.senha = m === 'entrar' ? 'Digite sua senha.' : 'Crie uma senha.'
  else if (m !== 'entrar' && campos.senha.length < 8) erros.senha = 'Use pelo menos 8 caracteres.'
  else erros.senha = ''
  return !Object.values(erros).some(Boolean)
}

// O Rails devolve { campo: [mensagens] } ou { erros: ["Email já está em uso", ...] }
const CAMPOS_DA_API = { nome: ['nome', 'Nome'], email: ['email', 'E-mail'], password: ['senha', 'Senha'] }

function mostrarErroDoServidor(erro) {
  if (!(erro instanceof ErroApi)) {
    avisoDoServidor.value = 'Não conseguimos conectar ao servidor. Tente de novo.'
    return
  }

  // Caso 1: Rails devolveu array de mensagens completas (ex: ["Email já está em uso"])
  if (Array.isArray(erro.erros) && erro.erros.length) {
    const gerais = []
    for (const msg of erro.erros) {
      const texto = msg.toLowerCase()
      if (texto.includes('nome')) erros.nome = msg
      else if (texto.includes('e-mail') || texto.includes('email')) erros.email = msg
      else if (texto.includes('senha') || texto.includes('password')) erros.senha = msg
      else gerais.push(msg)
    }
    if (gerais.length) avisoDoServidor.value = gerais.join(' ')
    return
  }

  // Caso 2: Rails devolveu objeto { campo: [mensagens] }
  const doCampo = Object.entries(erro.erros ?? {}).filter(([campo]) => CAMPOS_DA_API[campo])
  doCampo.forEach(([campo, mensagens]) => {
    const [local, rotulo] = CAMPOS_DA_API[campo]
    erros[local] = `${rotulo} ${mensagens[0]}.`
  })
  if (doCampo.length) return

  if (erro.status === 401) {
    erros.senha = 'E-mail ou senha incorretos.'
    avisoDoServidor.value = 'Não encontramos uma conta com esses dados. Confira e tente de novo.'
  } else if (erro.erros?.token) {
    avisoDoServidor.value = 'Este link venceu ou já foi usado. Peça um novo em "Esqueci minha senha".'
  } else {
    avisoDoServidor.value = erro.message
  }
}

function irParaAreaLogada() {
  const destino = rota.query.redirect
  roteador.push(typeof destino === 'string' && destino.startsWith('/') ? destino : '/minhas-leituras')
}

async function enviarAoServidor() {
  const { nome, email, senha } = campos
  switch (modo.value) {
    case 'entrar':
      await auth.entrar(email, senha)
      return irParaAreaLogada()
    case 'criar':
      await auth.cadastrar({ nome, email, senha })
      return irParaAreaLogada()
    case 'esqueci':
      await solicitarRecuperacao(email)
      avisoDeSucesso.value = 'Se existe uma conta com esse e-mail, enviamos o link para criar uma senha nova. Ele vale por 15 minutos.'
      return
    case 'redefinir':
      await redefinirSenha(rota.query.token ?? '', senha)
      campos.senha = '' // a senha nova não deve ficar escrita no campo do login
      return roteador.push({ path: '/entrar', query: { aviso: 'senha-redefinida' } })
  }
}

async function enviar() {
  avisoDoServidor.value = ''
  avisoDeSucesso.value = ''
  if (validar()) {
    enviando.value = true
    try {
      await enviarAoServidor()
    } catch (erro) {
      mostrarErroDoServidor(erro)
    } finally {
      enviando.value = false
    }
  }
  await nextTick()
  document.querySelector('[aria-invalid="true"]')?.focus() // leva o foco ao primeiro erro
}
</script>

<template>
  <div class="acesso">
    <PainelAcesso class="acesso-painel" />

    <div class="acesso-lado">
      <header class="acesso-topo">
        <RouterLink class="acesso-voltar" to="/">
          <Icone nome="seta-esquerda" :tamanho="20" />
          Voltar ao início
        </RouterLink>
        <!-- Abre o painel de ajustes de leitura (antes levava para a página "Em breve") -->
        <BotaoAcessibilidade />
      </header>

      <main class="acesso-centro">
        <img class="acesso-logo" :src="logo" alt="Cantinho da Leitura" width="160">

        <form id="painel-acesso" class="acesso-campos" :role="comAbas ? 'tabpanel' : undefined" aria-label="Acesso" novalidate @submit.prevent="enviar">
          <AbasAcesso v-if="comAbas" v-model="aba" painel="painel-acesso" />

          <div class="acesso-titulo">
            <h1 class="acesso-titulo-linha">
              <template v-if="modo === 'criar'">Crie sua <DestaquePalavra>conta</DestaquePalavra></template>
              <template v-else-if="modo === 'esqueci'">Recupere sua <DestaquePalavra cor="laranja">senha</DestaquePalavra></template>
              <template v-else-if="modo === 'redefinir'">Crie uma nova <DestaquePalavra cor="laranja">senha</DestaquePalavra></template>
              <template v-else>Entrar no seu <DestaquePalavra cor="laranja">cantinho</DestaquePalavra></template>
            </h1>
            <p class="acesso-subtitulo">
              <template v-if="modo === 'criar'">É rápido e gratuito. Só precisamos do básico para guardar suas leituras.</template>
              <template v-else-if="modo === 'esqueci'">Digite o e-mail da sua conta. Vamos enviar um link para você criar uma senha nova.</template>
              <template v-else-if="modo === 'redefinir'">Escolha uma senha nova para voltar ao seu cantinho.</template>
              <template v-else>Use seu e-mail e senha para continuar suas leituras.</template>
            </p>
          </div>

          <Alerta v-if="avisoDoServidor" tipo="erro">{{ avisoDoServidor }}</Alerta>
          <Alerta v-if="avisoDeSucesso" tipo="sucesso">{{ avisoDeSucesso }}</Alerta>
          <Alerta v-if="senhaRedefinida" tipo="sucesso">Senha nova salva. Agora é só entrar.</Alerta>

          <div class="acesso-entradas">
            <CampoFormulario
              v-if="criando"
              v-model="campos.nome"
              label="Como você quer ser chamado?"
              placeholder="Seu nome ou apelido"
              ajuda="Aparece no seu cantinho."
              :erro="erros.nome"
              name="nome"
              autocomplete="nickname"
              @input="erros.nome = ''"
            />
            <CampoFormulario
              v-if="modo !== 'redefinir'"
              v-model="campos.email"
              label="E-mail"
              type="email"
              placeholder="seu@email.com"
              :ajuda="modo === 'esqueci' ? 'O e-mail que você usou para criar a conta.' : 'Usaremos só para entrar na sua conta.'"
              :erro="erros.email"
              name="email"
              autocomplete="email"
              @input="erros.email = ''"
            />
            <CampoFormulario
              v-if="modo !== 'esqueci'"
              v-model="campos.senha"
              :label="modo === 'entrar' ? 'Senha' : modo === 'redefinir' ? 'Nova senha' : 'Crie uma senha'"
              type="password"
              :placeholder="modo === 'entrar' ? '' : 'Crie uma senha'"
              :ajuda="modo === 'entrar' ? '' : 'Mínimo de 8 caracteres.'"
              :erro="erros.senha"
              name="senha"
              :autocomplete="modo === 'entrar' ? 'current-password' : 'new-password'"
              @input="erros.senha = ''"
            />
          </div>

          <RouterLink v-if="modo === 'entrar'" class="acesso-esqueci" to="/esqueci-senha">Esqueci minha senha</RouterLink>

          <Alerta v-if="criando">Tem menos de 18 anos? Peça a um responsável para criar a conta com você.</Alerta>

          <Botao v-if="criando" tipo="destaque" type="submit" :disabled="enviando">
            <template #icone><Icone nome="estrela" /></template>
            Criar minha conta
          </Botao>
          <Botao v-else type="submit" :disabled="enviando">
            <template #icone><Icone nome="seta-direita" /></template>
            {{ modo === 'esqueci' ? 'Enviar link' : modo === 'redefinir' ? 'Salvar nova senha' : 'Entrar' }}
          </Botao>

          <p v-if="modo === 'esqueci' || modo === 'redefinir'" class="acesso-ja-tem">
            <RouterLink to="/entrar">Voltar para entrar</RouterLink>
          </p>

          <template v-else>
            <div class="acesso-ou"><span>ou</span></div>

            <p v-if="criando" class="acesso-ja-tem">
              Já tem conta? <RouterLink to="/entrar">Entrar</RouterLink>
            </p>
            <template v-else>
              <Botao tipo="contorno" to="/acervo-publico">
                <template #icone><Icone nome="bussola" /></template>
                Explorar o acervo sem conta
              </Botao>
              <p class="acesso-nota">Visitantes leem os livros abertos. Com conta você guarda favoritos, listas e marcadores.</p>
            </template>
          </template>
        </form>
      </main>

      <div class="acesso-adesivos" aria-hidden="true">
        <img class="acesso-nuvem" :src="nuvem" alt="">
        <img class="acesso-menina" :src="meninaLendo" alt="">
      </div>
    </div>
  </div>
</template>

<style scoped>
.acesso {
  display: flex;
  gap: var(--espaco-24);
  min-height: 100vh;
  padding: var(--espaco-24);
  background: var(--fundo-pagina);
}

.acesso-painel {
  flex: 0 0 640px;
}

.acesso-lado {
  position: relative;
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.acesso-topo {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--espaco-8) var(--espaco-16) var(--espaco-8) calc(var(--espaco-32) + var(--espaco-8));
}

.acesso-voltar {
  display: inline-flex;
  align-items: center;
  gap: var(--espaco-8);
  color: var(--texto-principal);
  font: var(--fonte-botao);
  text-decoration: none;
}

.acesso-voltar:hover {
  text-decoration: underline;
}

.acesso-voltar:focus-visible,
.acesso-esqueci:focus-visible,
.acesso-ja-tem a:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 3px;
  border-radius: var(--raio-8);
}

.acesso-centro {
  position: relative;
  z-index: 1;
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--espaco-24);
}

.acesso-logo {
  display: none; /* o painel ilustrado já mostra o logo; em telas sem painel ele entra aqui */
  margin-bottom: var(--espaco-24);
}

.acesso-campos {
  display: flex;
  flex-direction: column;
  gap: 18px;
  width: 100%;
  max-width: 420px;
}

.acesso-titulo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
}

.acesso-titulo-linha {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.acesso-subtitulo {
  color: var(--texto-corpo);
  font: var(--fonte-corpo);
}

.acesso-entradas {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-12);
}

.acesso-esqueci {
  align-self: flex-end;
  color: var(--texto-principal);
  font: var(--fonte-botao);
}

/* Linha com "ou" no meio */
.acesso-ou {
  display: flex;
  align-items: center;
  gap: var(--espaco-12);
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}

.acesso-ou::before,
.acesso-ou::after {
  content: '';
  flex: 1;
  height: 1px;
  background: var(--borda-padrao);
}

.acesso-nota {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
  text-align: center;
}

.acesso-ja-tem {
  color: var(--texto-corpo);
  font: var(--fonte-interface);
  text-align: center;
}

.acesso-ja-tem a {
  color: var(--texto-principal);
  font: var(--fonte-botao);
}

/* Adesivos no canto de baixo (decorativos) */
.acesso-adesivos {
  position: absolute;
  right: 0;
  bottom: 0;
  width: 260px;
  height: 130px;
  pointer-events: none;
}

.acesso-nuvem {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: contain;
  opacity: 0.8;
}

.acesso-menina {
  position: absolute;
  right: 28px;
  bottom: 12px;
  width: 96px;
  height: 105px;
  object-fit: contain;
}

/* Sem espaço para o painel ilustrado */
@media (max-width: 1100px) {
  .acesso-painel {
    display: none;
  }

  .acesso-logo {
    display: block;
  }
}

@media (max-width: 640px) {
  .acesso {
    padding: var(--espaco-16);
  }

  .acesso-topo {
    padding-inline: 0;
    gap: var(--espaco-8);
  }

  .acesso-centro {
    padding: var(--espaco-24) 0 var(--espaco-64);
  }

  .acesso-adesivos {
    width: 180px;
    height: 90px;
  }

  .acesso-menina {
    width: 66px;
    height: 72px;
    right: 18px;
  }
}
</style>
