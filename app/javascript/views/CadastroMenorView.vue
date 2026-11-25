<!--
  Conta para criança ou adolescente (HU-20 Task 3) — VERSÃO PROPOSTA, aguardando a SESFA.
  Quem preenche é o responsável. A conta nasce bloqueada: ele confirma pelo link que chega no e-mail
  (AutorizacaoMenorView). A criança entra com o nome de usuário, sem precisar de e-mail.
  Sem Figma: moldura pública (menu de cima e rodapé) com os componentes do design system.
  Regras em docs/decisoes-negocio/cadastro_menores.md.
-->
<script setup>
import { nextTick, reactive, ref } from 'vue'
import { RouterLink } from 'vue-router'
import AvisoPrivacidadeMenor from '../components/cadastro/AvisoPrivacidadeMenor.vue'
import MenuSuperior from '../components/layout/MenuSuperior.vue'
import Rodape from '../components/layout/Rodape.vue'
import Alerta from '../components/ui/Alerta.vue'
import Botao from '../components/ui/Botao.vue'
import CampoFormulario from '../components/ui/CampoFormulario.vue'
import Icone from '../components/ui/Icone.vue'
import { ErroApi } from '../services/api.js'
import { criarContaMenor } from '../services/cadastroMenorService.js'

const campos = reactive({ responsavelNome: '', responsavelEmail: '', nome: '', nomeUsuario: '', senha: '', autorizo: false })
const erros = reactive({ responsavelNome: '', responsavelEmail: '', nome: '', nomeUsuario: '', senha: '', autorizo: '' })
const avisoDoServidor = ref('')
const enviando = ref(false)
const enviado = ref(null) // resposta do servidor: { nome_usuario, responsavel_email, link_demonstracao? }

// Nomes dos campos no Rails -> campo da tela e rótulo da mensagem
const CAMPOS_DA_API = {
  responsavel_nome: ['responsavelNome', 'Seu nome'],
  responsavel_email: ['responsavelEmail', 'Seu e-mail'],
  nome: ['nome', 'O nome da criança'],
  nome_usuario: ['nomeUsuario', 'O nome de usuário'],
  password: ['senha', 'A senha'],
  autorizo: ['autorizo', 'A declaração'],
}

const emailValido = (texto) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(texto.trim())
const nomeUsuarioValido = (texto) => /^[a-z0-9._-]{3,30}$/.test(texto.trim().toLowerCase())

function limparErros() {
  Object.keys(erros).forEach((chave) => (erros[chave] = ''))
  avisoDoServidor.value = ''
}

function validar() {
  if (campos.responsavelNome.trim().length < 2) erros.responsavelNome = 'Escreva o seu nome.'
  if (!emailValido(campos.responsavelEmail)) erros.responsavelEmail = 'Digite um e-mail válido. É nele que você confirma a conta.'
  if (campos.nome.trim().length < 2) erros.nome = 'Escreva como a criança quer ser chamada.'
  if (!nomeUsuarioValido(campos.nomeUsuario)) {
    erros.nomeUsuario = 'Use de 3 a 30 letras sem acento, números, ponto, hífen ou sublinhado. Ex.: joao.silva'
  }
  if (campos.senha.length < 8) erros.senha = 'Use pelo menos 8 caracteres.'
  if (!campos.autorizo) erros.autorizo = 'Marque a declaração: só o responsável pode criar esta conta.'
  return !Object.values(erros).some(Boolean)
}

function mostrarErroDoServidor(erro) {
  if (!(erro instanceof ErroApi)) {
    avisoDoServidor.value = 'Não conseguimos conectar ao servidor. Tente de novo.'
    return
  }
  let achou = false
  for (const [campoApi, mensagens] of Object.entries(erro.erros ?? {})) {
    const destino = CAMPOS_DA_API[campoApi]
    if (!destino) continue
    erros[destino[0]] = `${destino[1]} ${mensagens[0]}.`
    achou = true
  }
  if (!achou) avisoDoServidor.value = erro.message
}

async function enviar() {
  limparErros()
  if (validar()) {
    enviando.value = true
    try {
      enviado.value = await criarContaMenor({ ...campos, nomeUsuario: campos.nomeUsuario.trim().toLowerCase() })
      campos.senha = ''
      window.scrollTo({ top: 0 })
    } catch (erro) {
      mostrarErroDoServidor(erro)
    } finally {
      enviando.value = false
    }
  }
  await nextTick()
  document.querySelector('[aria-invalid="true"]')?.focus()
}
</script>

<template>
  <div>
    <MenuSuperior />

    <main class="menor">
      <Alerta class="menor-proposta">
        Versão proposta: este cadastro ainda precisa ser aprovado pela ONG parceira antes de ser usado com crianças de verdade.
      </Alerta>

      <!-- Depois de enviar: confirme no e-mail -->
      <section v-if="enviado" class="cartao" aria-labelledby="titulo-enviado">
        <h1 id="titulo-enviado" class="cartao-titulo-grande">Agora confirme no seu e-mail</h1>
        <p class="cartao-texto">
          Enviamos um link para <strong>{{ enviado.responsavel_email }}</strong>. Abra o e-mail e clique em
          "Autorizar" para a conta poder ser usada. O link vale por 7 dias; sem confirmação, o cadastro é apagado.
        </p>
        <p class="cartao-texto">
          Depois de autorizar, a criança entra com o nome de usuário <strong>{{ enviado.nome_usuario }}</strong> e a
          senha que você criou.
        </p>

        <div v-if="enviado.link_demonstracao" class="demonstracao">
          <p class="cartao-texto">
            <strong>Modo demonstração:</strong> em desenvolvimento o e-mail não é enviado de verdade. Use o botão para
            abrir o link que o responsável receberia.
          </p>
          <Botao tipo="contorno" :href="enviado.link_demonstracao">Abrir o link do e-mail</Botao>
        </div>

        <Botao to="/entrar">
          <template #icone><Icone nome="seta-direita" /></template>
          Ir para entrar
        </Botao>
      </section>

      <!-- Formulário do responsável -->
      <form v-else class="cartao" novalidate @submit.prevent="enviar">
        <div>
          <h1 class="cartao-titulo-grande">Conta para criança ou adolescente</h1>
          <p class="cartao-texto">
            Quem preenche é <strong>o pai, a mãe ou o responsável legal</strong>. A criança entra com um nome de
            usuário, sem precisar de e-mail. Você confirma tudo pelo seu e-mail.
          </p>
        </div>

        <Alerta v-if="avisoDoServidor" tipo="erro">{{ avisoDoServidor }}</Alerta>

        <fieldset class="grupo">
          <legend class="grupo-titulo">Seus dados (responsável)</legend>
          <CampoFormulario
            v-model="campos.responsavelNome"
            label="Seu nome"
            name="responsavel-nome"
            autocomplete="name"
            :erro="erros.responsavelNome"
            @input="erros.responsavelNome = ''"
          />
          <CampoFormulario
            v-model="campos.responsavelEmail"
            label="Seu e-mail"
            type="email"
            name="responsavel-email"
            autocomplete="email"
            ajuda="Você recebe aqui o link para confirmar e, se precisar, para trocar a senha da criança."
            :erro="erros.responsavelEmail"
            @input="erros.responsavelEmail = ''"
          />
        </fieldset>

        <fieldset class="grupo">
          <legend class="grupo-titulo">Conta da criança</legend>
          <CampoFormulario
            v-model="campos.nome"
            label="Como a criança quer ser chamada?"
            name="nome"
            ajuda="Pode ser só o primeiro nome ou um apelido."
            :erro="erros.nome"
            @input="erros.nome = ''"
          />
          <CampoFormulario
            v-model="campos.nomeUsuario"
            label="Nome de usuário (para entrar)"
            name="nome-usuario"
            autocomplete="off"
            autocapitalize="none"
            spellcheck="false"
            ajuda="De 3 a 30 letras sem acento, números, ponto, hífen ou sublinhado. Ex.: joao.silva"
            :erro="erros.nomeUsuario"
            @input="erros.nomeUsuario = ''"
          />
          <CampoFormulario
            v-model="campos.senha"
            label="Crie uma senha"
            type="password"
            name="senha"
            autocomplete="new-password"
            ajuda="Mínimo de 8 caracteres. Combine com a criança uma senha fácil de lembrar."
            :erro="erros.senha"
            @input="erros.senha = ''"
          />
        </fieldset>

        <AvisoPrivacidadeMenor />

        <div class="declaracao" :class="{ 'declaracao--erro': erros.autorizo }">
          <label class="declaracao-rotulo">
            <input
              v-model="campos.autorizo"
              type="checkbox"
              name="autorizo"
              :aria-invalid="erros.autorizo ? 'true' : undefined"
              :aria-describedby="erros.autorizo ? 'erro-autorizo' : undefined"
              @change="erros.autorizo = ''"
            >
            <span>
              Sou pai, mãe ou responsável legal por esta criança ou adolescente, li o que é guardado acima e autorizo o
              uso do Cantinho da Leitura.
            </span>
          </label>
          <p v-if="erros.autorizo" id="erro-autorizo" class="declaracao-erro">{{ erros.autorizo }}</p>
        </div>

        <Botao tipo="destaque" type="submit" :disabled="enviando">
          <template #icone><Icone nome="estrela" /></template>
          {{ enviando ? 'Criando...' : 'Criar a conta e enviar o e-mail' }}
        </Botao>

        <p class="cartao-texto">
          Para você mesmo (18 anos ou mais)? <RouterLink to="/criar-conta">Crie a sua conta aqui</RouterLink>.
        </p>
      </form>
    </main>

    <Rodape />
  </div>
</template>

<style scoped>
.menor {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-24);
  max-width: 640px;
  margin: 0 auto;
  padding: var(--espaco-48) var(--espaco-16) var(--espaco-64);
}

.cartao {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-24);
  padding: var(--espaco-32);
  border-radius: var(--raio-20);
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-cartao);
}

.cartao > :deep(.botao) {
  align-self: flex-start;
}

.cartao-titulo-grande {
  margin-bottom: var(--espaco-8);
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.cartao-texto {
  color: var(--texto-corpo);
  font: var(--fonte-interface);
}

.cartao-texto a {
  color: var(--texto-principal);
  font: var(--fonte-botao);
}

.grupo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-12);
  min-width: 0;
  margin: 0;
  padding: 0;
  border: 0;
}

.grupo-titulo {
  margin-bottom: var(--espaco-8);
  padding: 0;
  color: var(--texto-principal);
  font: var(--fonte-subtitulo);
}

.declaracao {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
  padding: var(--espaco-16);
  border-radius: var(--raio-12);
  box-shadow: inset 0 0 0 1.5px var(--borda-padrao);
}

.declaracao--erro {
  box-shadow: inset 0 0 0 1.5px var(--apoio-coral);
}

.declaracao-rotulo {
  display: flex;
  align-items: flex-start;
  gap: var(--espaco-12);
  color: var(--texto-principal);
  font: var(--fonte-interface);
  cursor: pointer;
}

.declaracao-rotulo input {
  flex-shrink: 0;
  width: 22px;
  height: 22px;
  margin-top: 2px;
  accent-color: var(--destaque-ceu);
  cursor: pointer;
}

.declaracao-rotulo input:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 2px;
}

.declaracao-erro {
  color: var(--texto-principal);
  font: var(--fonte-legenda);
}

.demonstracao {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-12);
  padding: var(--espaco-16);
  border-radius: var(--raio-12);
  background: var(--fundo-nuvem);
}

@media (max-width: 520px) {
  .menor {
    padding-top: var(--espaco-24);
  }

  .cartao {
    padding: var(--espaco-24) var(--espaco-16);
  }
}
</style>
