<!--
  Autorizar conta de criança/adolescente (HU-20 Task 3) — VERSÃO PROPOSTA, aguardando a SESFA.
  Aberta pelo link do e-mail do responsável (/autorizar-menor?token=...). Sem login: o token é a prova.
  Mostra o resumo e o aviso de privacidade; "Autorizar" libera a conta, "Recusar" apaga o cadastro.
  O link vale 7 dias e uma resposta só. Sem Figma: moldura pública com o design system.
-->
<script setup>
import { onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import AvisoPrivacidadeMenor from '../components/cadastro/AvisoPrivacidadeMenor.vue'
import MenuSuperior from '../components/layout/MenuSuperior.vue'
import Rodape from '../components/layout/Rodape.vue'
import Alerta from '../components/ui/Alerta.vue'
import Botao from '../components/ui/Botao.vue'
import EstadoVazio from '../components/ui/EstadoVazio.vue'
import Icone from '../components/ui/Icone.vue'
import ModalConfirmacao from '../components/ui/ModalConfirmacao.vue'
import { ErroApi } from '../services/api.js'
import { autorizar, buscarAutorizacao, recusar } from '../services/cadastroMenorService.js'

const rota = useRoute()
const token = typeof rota.query.token === 'string' ? rota.query.token : ''

// carregando | pendente | invalido | autorizado | recusado | erro
const estado = ref('carregando')
const conta = ref(null)
const respondendo = ref(false)
const erroAcao = ref('')
const modalRecusa = ref(null)
const erroRecusa = ref('')

const SEM_SERVIDOR = 'Não conseguimos conectar ao servidor. Tente de novo.'
const dataCurta = (valor) => new Date(valor).toLocaleDateString('pt-BR')

async function carregar() {
  estado.value = 'carregando'
  if (!token) return (estado.value = 'invalido')
  try {
    conta.value = await buscarAutorizacao(token)
    estado.value = 'pendente'
  } catch (erro) {
    estado.value = erro instanceof ErroApi && erro.status === 404 ? 'invalido' : 'erro'
  }
}

onMounted(carregar)

async function confirmarAutorizacao() {
  respondendo.value = true
  erroAcao.value = ''
  try {
    conta.value = { ...conta.value, ...(await autorizar(token)) }
    estado.value = 'autorizado'
  } catch (erro) {
    if (erro instanceof ErroApi && erro.status === 404) estado.value = 'invalido'
    else erroAcao.value = erro instanceof ErroApi ? erro.message : SEM_SERVIDOR
  } finally {
    respondendo.value = false
  }
}

function pedirRecusa() {
  erroRecusa.value = ''
  modalRecusa.value.abrir()
}

async function confirmarRecusa() {
  respondendo.value = true
  erroRecusa.value = ''
  try {
    await recusar(token)
    respondendo.value = false
    modalRecusa.value.fechar()
    estado.value = 'recusado'
  } catch (erro) {
    respondendo.value = false
    if (erro instanceof ErroApi && erro.status === 404) {
      modalRecusa.value.fechar()
      estado.value = 'invalido'
    } else {
      erroRecusa.value = erro instanceof ErroApi ? erro.message : SEM_SERVIDOR
    }
  }
}
</script>

<template>
  <div>
    <MenuSuperior />

    <main class="autorizacao" :aria-busy="estado === 'carregando'">
      <Alerta>
        Versão proposta: este fluxo ainda precisa ser aprovado pela ONG parceira antes de ser usado com crianças de verdade.
      </Alerta>

      <p v-if="estado === 'carregando'" class="texto" role="status">Carregando o pedido de autorização...</p>

      <EstadoVazio
        v-else-if="estado === 'invalido'"
        titulo="Este link não vale mais"
        descricao="Ele pode ter vencido (vale 7 dias) ou já ter sido usado. Se o cadastro venceu, é só fazer de novo."
      >
        <template #acao><Botao to="/criar-conta-crianca">Fazer um novo cadastro</Botao></template>
      </EstadoVazio>

      <template v-else-if="estado === 'erro'">
        <Alerta tipo="erro">{{ SEM_SERVIDOR }}</Alerta>
        <Botao tipo="contorno" @click="carregar">Tentar de novo</Botao>
      </template>

      <section v-else-if="estado === 'pendente'" class="cartao" aria-labelledby="titulo-autorizacao">
        <div>
          <h1 id="titulo-autorizacao" class="titulo">Autorizar a conta de {{ conta.nome }}?</h1>
          <p class="texto">
            Olá, {{ conta.responsavel_nome }}. Em {{ dataCurta(conta.criado_em) }} foi criada no Cantinho da Leitura uma
            conta para <strong>{{ conta.nome }}</strong>, com o nome de usuário <strong>{{ conta.nome_usuario }}</strong>,
            informando você como responsável. Ela só pode ser usada depois da sua autorização.
          </p>
        </div>

        <AvisoPrivacidadeMenor />

        <p class="texto">
          Responda até {{ dataCurta(conta.vence_em) }}. Depois disso, o cadastro é apagado sozinho.
        </p>

        <Alerta v-if="erroAcao" tipo="erro">{{ erroAcao }}</Alerta>

        <div class="acoes">
          <Botao tipo="destaque" :disabled="respondendo" @click="confirmarAutorizacao">
            <template #icone><Icone nome="check" /></template>
            {{ respondendo ? 'Salvando...' : 'Autorizar' }}
          </Botao>
          <Botao tipo="contorno" :disabled="respondendo" @click="pedirRecusa">Não autorizo</Botao>
        </div>
      </section>

      <EstadoVazio
        v-else-if="estado === 'autorizado'"
        titulo="Conta autorizada"
        :descricao="`Pronto! ${conta.nome} já pode entrar com o nome de usuário ${conta.nome_usuario} e a senha que você criou.`"
      >
        <template #acao><Botao to="/entrar">Ir para entrar</Botao></template>
      </EstadoVazio>

      <EstadoVazio
        v-else-if="estado === 'recusado'"
        titulo="Cadastro recusado"
        descricao="A conta não foi autorizada e todos os dados do cadastro foram apagados."
      >
        <template #acao><Botao to="/">Voltar ao início</Botao></template>
      </EstadoVazio>
    </main>

    <ModalConfirmacao
      ref="modalRecusa"
      titulo="Recusar este cadastro?"
      texto-confirmar="Recusar e apagar"
      texto-carregando="Apagando..."
      :carregando="respondendo"
      :erro="erroRecusa"
      @confirmar="confirmarRecusa"
    >
      <p v-if="conta">A conta de <strong>{{ conta.nome }}</strong> não será criada e os dados do cadastro serão apagados.</p>
    </ModalConfirmacao>

    <Rodape />
  </div>
</template>

<style scoped>
.autorizacao {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-24);
  max-width: 640px;
  margin: 0 auto;
  padding: var(--espaco-48) var(--espaco-16) var(--espaco-64);
}

.autorizacao > :deep(.vazio) {
  align-self: center;
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

.titulo {
  margin-bottom: var(--espaco-8);
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.texto {
  color: var(--texto-corpo);
  font: var(--fonte-interface);
}

.acoes {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-12);
}

@media (max-width: 520px) {
  .autorizacao {
    padding-top: var(--espaco-24);
  }

  .cartao {
    padding: var(--espaco-24) var(--espaco-16);
  }
}
</style>
