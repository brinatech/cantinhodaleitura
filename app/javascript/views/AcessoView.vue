<!--
  Tela de acesso (Figma: "Acesso · Entrar", "Entrar com erro" e "Criar conta").
  As duas telas são uma só: as abas trocam a rota (/entrar e /criar-conta).
  Validação feita aqui, no navegador. O envio ao servidor ainda não existe
  (o backend não tem API de login/cadastro): ver "enviar".
-->
<script setup>
import { computed, nextTick, reactive, ref, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import PainelAcesso from '../components/acesso/PainelAcesso.vue'
import AbasAcesso from '../components/ui/AbasAcesso.vue'
import Alerta from '../components/ui/Alerta.vue'
import Botao from '../components/ui/Botao.vue'
import CampoFormulario from '../components/ui/CampoFormulario.vue'
import DestaquePalavra from '../components/ui/DestaquePalavra.vue'
import Icone from '../components/ui/Icone.vue'
import logo from '../images/logo-header.png'
import nuvem from '../images/ilustracoes/acesso-nuvem.png'
import meninaLendo from '../images/ilustracoes/acesso-menina-lendo.png'

const rota = useRoute()
const roteador = useRouter()

const criando = computed(() => rota.path === '/criar-conta')
const aba = computed({
  get: () => (criando.value ? 'criar-conta' : 'entrar'),
  set: (valor) => roteador.push(`/${valor}`),
})

const campos = reactive({ nome: '', email: '', senha: '' })
const erros = reactive({ nome: '', email: '', senha: '' })
const avisoDoServidor = ref('')

// Trocar de aba começa um formulário limpo de erros (o que foi digitado fica)
watch(criando, () => {
  Object.keys(erros).forEach((chave) => (erros[chave] = ''))
  avisoDoServidor.value = ''
})

const emailValido = (texto) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(texto.trim())

function validar() {
  erros.nome = criando.value && !campos.nome.trim() ? 'Diga como você quer ser chamado.' : ''
  erros.email = emailValido(campos.email) ? '' : 'Digite um e-mail válido, como maria@email.com.'
  if (!campos.senha) erros.senha = criando.value ? 'Crie uma senha.' : 'Digite sua senha.'
  else if (criando.value && campos.senha.length < 8) erros.senha = 'Use pelo menos 8 caracteres.'
  else erros.senha = ''
  return !Object.values(erros).some(Boolean)
}

async function enviar() {
  avisoDoServidor.value = ''
  if (!validar()) {
    await nextTick()
    document.querySelector('[aria-invalid="true"]')?.focus() // leva o foco ao primeiro erro
    return
  }
  // shortcut: o backend ainda não tem login nem cadastro. Quando existir, trocar por
  // uma chamada à API; erro de credencial vira erros.senha + avisoDoServidor (Figma "Entrar com erro").
  avisoDoServidor.value = 'Ainda não conseguimos conectar ao servidor. Tente de novo mais tarde.'
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
        <Botao tipo="contorno" to="/acessibilidade">
          <template #icone><Icone nome="acessibilidade" /></template>
          Acessibilidade
        </Botao>
      </header>

      <main class="acesso-centro">
        <img class="acesso-logo" :src="logo" alt="Cantinho da Leitura" width="160">

        <form id="painel-acesso" class="acesso-campos" role="tabpanel" aria-label="Acesso" novalidate @submit.prevent="enviar">
          <AbasAcesso v-model="aba" painel="painel-acesso" />

          <div class="acesso-titulo">
            <h1 class="acesso-titulo-linha">
              <template v-if="criando">Crie sua <DestaquePalavra>conta</DestaquePalavra></template>
              <template v-else>Entrar no seu <DestaquePalavra cor="laranja">cantinho</DestaquePalavra></template>
            </h1>
            <p class="acesso-subtitulo">
              {{ criando
                ? 'É rápido e gratuito. Só precisamos do básico para guardar suas leituras.'
                : 'Use seu e-mail e senha para continuar suas leituras.' }}
            </p>
          </div>

          <Alerta v-if="avisoDoServidor" tipo="erro">{{ avisoDoServidor }}</Alerta>

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
              v-model="campos.email"
              label="E-mail"
              type="email"
              placeholder="seu@email.com"
              ajuda="Usaremos só para entrar na sua conta."
              :erro="erros.email"
              name="email"
              autocomplete="email"
              @input="erros.email = ''"
            />
            <CampoFormulario
              v-model="campos.senha"
              :label="criando ? 'Crie uma senha' : 'Senha'"
              type="password"
              :placeholder="criando ? 'Crie uma senha' : ''"
              ajuda="Mínimo de 8 caracteres."
              :erro="erros.senha"
              name="senha"
              :autocomplete="criando ? 'new-password' : 'current-password'"
              @input="erros.senha = ''"
            />
          </div>

          <RouterLink v-if="!criando" class="acesso-esqueci" to="/esqueci-senha">Esqueci minha senha</RouterLink>

          <Alerta v-if="criando">Tem menos de 18 anos? Peça a um responsável para criar a conta com você.</Alerta>

          <Botao v-if="criando" tipo="destaque" type="submit">
            <template #icone><Icone nome="estrela" /></template>
            Criar minha conta
          </Botao>
          <Botao v-else type="submit">
            <template #icone><Icone nome="seta-direita" /></template>
            Entrar
          </Botao>

          <div class="acesso-ou"><span>ou</span></div>

          <p v-if="criando" class="acesso-ja-tem">
            Já tem conta? <RouterLink to="/entrar">Entrar</RouterLink>
          </p>
          <template v-else>
            <Botao tipo="contorno" to="/acervo">
              <template #icone><Icone nome="bussola" /></template>
              Explorar o acervo sem conta
            </Botao>
            <p class="acesso-nota">Visitantes leem os livros abertos. Com conta você guarda favoritos, listas e marcadores.</p>
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
