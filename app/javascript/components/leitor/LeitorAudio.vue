<!--
  Leitor de áudio (HU-10 Task 4): toca o audiobook com o PlayerAudio do design system.
  O PlayerAudio é só a parte visual; quem toca o som é o <audio> escondido aqui dentro.

  O link do arquivo vale 5 minutos. Num áudio longo, depois de uma pausa grande (ou ao
  pular para outro trecho), o link pode ter vencido: aqui um link novo é pedido sozinho
  e o áudio continua do mesmo ponto, sem a pessoa perceber.
-->
<script setup>
import { computed, onBeforeUnmount, ref } from 'vue'
import Alerta from '../ui/Alerta.vue'
import Botao from '../ui/Botao.vue'
import Icone from '../ui/Icone.vue'
import PlayerAudio from '../ui/PlayerAudio.vue'

const props = defineProps({
  url: { type: String, required: true }, // /api/v1/livros/:id/arquivos/:id
  titulo: { type: String, required: true },
  autor: { type: String, default: '' },
  capaUrl: { type: String, default: null },
  // Compacto: a faixa presa embaixo do leitor de PDF (o livro tem texto e áudio)
  compacto: { type: Boolean, default: false },
})

const VELOCIDADES = ['1x', '1.25x', '1.5x', '2x', '0.75x']
// Um pouco antes dos 5 minutos do link: renova antes de dar erro
const RENOVAR_DEPOIS_DE = 4.5 * 60 * 1000
const MAXIMO_DE_TENTATIVAS = 2

const som = ref(null)
const tocando = ref(false)
const tempoAtual = ref(0)
const duracao = ref(0)
const velocidade = ref('1x')
const carregando = ref(true)
const erro = ref('')

// Cada link novo ganha um número na URL (?v=), para o navegador não reaproveitar o link vencido
const tentativa = ref(0)
const fonte = computed(() => `${props.url}?modo=leitura&v=${tentativa.value}`)
let linkGeradoEm = Date.now()
let falhasSeguidas = 0
let retomada = null // { posicao, tocar }: onde continuar depois de trocar o link

const linkVelho = () => Date.now() - linkGeradoEm > RENOVAR_DEPOIS_DE

function renovarLink(posicao, tocar) {
  retomada = { posicao, tocar }
  carregando.value = true
  linkGeradoEm = Date.now()
  tentativa.value++ // muda a fonte: o <audio> pede o arquivo de novo, pelo nosso controller
}

// ===== Eventos do <audio> =====
function aoCarregarDados() {
  const total = som.value.duration
  duracao.value = Number.isFinite(total) ? total : 0
  som.value.playbackRate = parseFloat(velocidade.value)
  carregando.value = false
  erro.value = ''
  if (retomada) {
    som.value.currentTime = retomada.posicao
    if (retomada.tocar) tocar()
    retomada = null
  }
}

function aoFalhar() {
  const posicao = som.value?.currentTime || tempoAtual.value
  // Provavelmente o link venceu: tenta com um link novo, do mesmo ponto
  if (falhasSeguidas < MAXIMO_DE_TENTATIVAS) {
    falhasSeguidas++
    renovarLink(posicao, tocando.value)
    return
  }
  tocando.value = false
  carregando.value = false
  erro.value = 'Não foi possível tocar o audiobook. Verifique a internet e tente de novo.'
}

const aoTocar = () => {
  tocando.value = true
  falhasSeguidas = 0 // voltou a funcionar: zera as tentativas
}
const aoPausar = () => (tocando.value = false)
const aoAtualizarTempo = () => (tempoAtual.value = som.value.currentTime)

// ===== Botões do PlayerAudio =====
function tocar() {
  som.value.play().catch(() => {
    // O navegador pode bloquear o play sem um clique: a pessoa aperta o play de novo
    tocando.value = false
  })
}

function alternar() {
  if (tocando.value) return som.value.pause()
  if (linkVelho()) return renovarLink(som.value.currentTime, true) // ficou muito tempo pausado
  tocar()
}

function buscar(segundos) {
  // Pular para outro trecho com o link velho dá erro: renova e já vai para o ponto escolhido
  if (linkVelho()) return renovarLink(segundos, tocando.value)
  som.value.currentTime = segundos
  tempoAtual.value = segundos
}

const voltar10 = () => buscar(Math.max(0, tempoAtual.value - 10))
const avancar10 = () => buscar(Math.min(duracao.value, tempoAtual.value + 10))

function trocarVelocidade() {
  const proxima = VELOCIDADES[(VELOCIDADES.indexOf(velocidade.value) + 1) % VELOCIDADES.length]
  velocidade.value = proxima
  if (som.value) som.value.playbackRate = parseFloat(proxima)
}

function tentarDeNovo() {
  erro.value = ''
  falhasSeguidas = 0
  renovarLink(tempoAtual.value, false)
}

onBeforeUnmount(() => som.value?.pause())
</script>

<template>
  <section class="audio" :class="{ 'audio--compacto': compacto }" aria-label="Audiobook">
    <!-- O som de verdade. Fica escondido: os controles são os do PlayerAudio. -->
    <audio
      ref="som"
      :src="fonte"
      preload="metadata"
      @loadedmetadata="aoCarregarDados"
      @timeupdate="aoAtualizarTempo"
      @play="aoTocar"
      @pause="aoPausar"
      @ended="aoPausar"
      @error="aoFalhar"
    ></audio>

    <!-- No compacto, o aviso de erro vem antes da faixa, para não ficar escondido embaixo da tela -->
    <template v-if="erro && compacto">
      <Alerta tipo="erro">{{ erro }}</Alerta>
      <Botao tipo="contorno" class="audio-acao" @click="tentarDeNovo">Tentar de novo</Botao>
    </template>

    <PlayerAudio
      :compacto="compacto"
      :titulo="titulo"
      :capitulo="autor"
      :capa-url="capaUrl"
      :tocando="tocando"
      :tempo-atual="tempoAtual"
      :duracao="duracao"
      :velocidade="velocidade"
      @alternar="alternar"
      @voltar10="voltar10"
      @avancar10="avancar10"
      @velocidade="trocarVelocidade"
      @buscar="buscar"
    />

    <!-- Só na versão completa (livro sem PDF): avisos e "Baixar" embaixo do player -->
    <template v-if="!compacto">
      <p v-if="carregando && !erro" class="audio-nota" role="status">Carregando o audiobook...</p>

      <template v-if="erro">
        <Alerta tipo="erro">{{ erro }}</Alerta>
        <Botao tipo="contorno" class="audio-acao" @click="tentarDeNovo">Tentar de novo</Botao>
      </template>

      <Botao tipo="contorno" class="audio-acao" :href="url">
        <template #icone><Icone nome="seta-baixo" /></template>
        Baixar o áudio
      </Botao>
    </template>
  </section>
</template>

<style scoped>
.audio {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-16);
  max-width: 640px;
}

.audio--compacto {
  gap: var(--espaco-8);
  max-width: none;
}

.audio-acao {
  align-self: flex-start;
}

.audio-nota {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}
</style>
