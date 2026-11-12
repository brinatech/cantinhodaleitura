<!--
  Player de áudio (Figma: "Player de áudio"). Player do audiobook (RF09/RF11).
  É só a interface: não toca nada sozinho. Quem usa passa o estado ("tocando",
  "tempoAtual", "duracao", em segundos) e reage aos eventos:
    alternar (play/pausa), voltar10, avancar10, velocidade, buscar(segundos).
  Botões grandes (mín. 44px) com aria-label. A barra de progresso é um slider:
  setas movem 5s, Home/End vão ao começo e ao fim; clicar na barra também busca.
-->
<script setup>
import { computed } from 'vue'
import Icone from './Icone.vue'

const props = defineProps({
  titulo: { type: String, required: true },
  capitulo: { type: String, default: '' },
  capaUrl: { type: String, default: null },
  tocando: { type: Boolean, default: false },
  tempoAtual: { type: Number, default: 0 },
  duracao: { type: Number, required: true },
  velocidade: { type: String, default: '1x' },
})

const emit = defineEmits(['alternar', 'voltar10', 'avancar10', 'velocidade', 'buscar'])

const porcento = computed(() => (props.duracao > 0 ? Math.min(100, (props.tempoAtual / props.duracao) * 100) : 0))

function formatar(segundos) {
  const total = Math.max(0, Math.floor(segundos))
  return `${Math.floor(total / 60)}:${String(total % 60).padStart(2, '0')}`
}

function buscar(segundos) {
  emit('buscar', Math.min(props.duracao, Math.max(0, segundos)))
}

function teclado(evento) {
  const destino = {
    ArrowLeft: props.tempoAtual - 5,
    ArrowDown: props.tempoAtual - 5,
    ArrowRight: props.tempoAtual + 5,
    ArrowUp: props.tempoAtual + 5,
    Home: 0,
    End: props.duracao,
  }[evento.key]
  if (destino === undefined) return
  evento.preventDefault()
  buscar(destino)
}

function clicar(evento) {
  const caixa = evento.currentTarget.getBoundingClientRect()
  buscar(((evento.clientX - caixa.left) / caixa.width) * props.duracao)
}
</script>

<template>
  <section class="player" aria-label="Player de áudio">
    <div class="player-livro">
      <div class="player-capa">
        <img v-if="capaUrl" :src="capaUrl" alt="">
      </div>
      <div class="player-textos">
        <p class="player-titulo">{{ titulo }}</p>
        <p v-if="capitulo" class="player-capitulo">{{ capitulo }}</p>
      </div>
    </div>

    <div class="player-progresso">
      <div
        class="barra"
        role="slider"
        tabindex="0"
        aria-label="Posição do áudio"
        aria-valuemin="0"
        :aria-valuemax="duracao"
        :aria-valuenow="Math.floor(tempoAtual)"
        :aria-valuetext="`${formatar(tempoAtual)} de ${formatar(duracao)}`"
        @keydown="teclado"
        @click="clicar"
      >
        <span class="barra-preenchida" :style="{ width: `${porcento}%` }"></span>
        <span class="barra-controle" :style="{ left: `calc(${porcento}% - 10px)` }"></span>
      </div>
      <div class="player-tempos">
        <span>{{ formatar(tempoAtual) }}</span>
        <span>{{ formatar(duracao) }}</span>
      </div>
    </div>

    <div class="player-controles">
      <button type="button" class="redondo" aria-label="Voltar 10 segundos" @click="$emit('voltar10')">
        <Icone nome="voltar-10" />
      </button>
      <button type="button" class="principal" :aria-label="tocando ? 'Pausar' : 'Reproduzir'" @click="$emit('alternar')">
        <Icone :nome="tocando ? 'pausa' : 'play'" :tamanho="32" />
      </button>
      <button type="button" class="redondo" aria-label="Avançar 10 segundos" @click="$emit('avancar10')">
        <Icone nome="avancar-10" />
      </button>
      <button type="button" class="velocidade" :aria-label="`Velocidade ${velocidade}. Trocar velocidade`" @click="$emit('velocidade')">
        {{ velocidade }}
      </button>
    </div>
  </section>
</template>

<style scoped>
.player {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-16);
  width: 100%;
  padding: var(--espaco-24);
  border: 1px solid var(--borda-padrao);
  border-radius: var(--raio-20);
  background: var(--fundo-nuvem);
  box-shadow: var(--sombra-cartao);
}

.player-livro {
  display: flex;
  align-items: center;
  gap: var(--espaco-16);
}

.player-capa {
  width: 72px;
  height: 72px;
  flex-shrink: 0;
  overflow: hidden;
  border-radius: var(--raio-12);
  background: var(--fundo-suave);
}

.player-capa img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.player-textos {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.player-titulo {
  color: var(--texto-principal);
  font: var(--fonte-subtitulo);
}

.player-capitulo {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}

/* ===== Progresso ===== */
.player-progresso {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
}

.barra {
  position: relative;
  height: 8px;
  border-radius: var(--raio-total);
  background: var(--fundo-suave);
  cursor: pointer;
}

.barra:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 8px;
}

.barra-preenchida {
  position: absolute;
  top: 0;
  left: 0;
  height: 100%;
  border-radius: var(--raio-total);
  background: linear-gradient(90deg, var(--apoio-laranja), var(--apoio-coral));
}

.barra-controle {
  position: absolute;
  top: -6px;
  width: 20px;
  height: 20px;
  border: 3px solid white;
  border-radius: 50%;
  background: var(--destaque-escuro);
}

.player-tempos {
  display: flex;
  justify-content: space-between;
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}

/* ===== Controles ===== */
.player-controles {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-wrap: wrap;
  gap: var(--espaco-24);
}

.redondo,
.principal {
  display: inline-flex;
  border-radius: var(--raio-total);
  cursor: pointer;
}

.redondo {
  padding: var(--espaco-12);
  border: 1.5px solid var(--borda-padrao);
  background: var(--fundo-superficie);
  color: var(--texto-principal);
}

.principal {
  padding: var(--espaco-16);
  border: 0;
  background: var(--destaque-escuro);
  color: var(--texto-inverso);
}

.velocidade {
  min-height: 44px; /* alvo de toque mínimo; o Figma tem 40 */
  padding: var(--espaco-8) var(--espaco-16);
  border: 0;
  border-radius: var(--raio-total);
  background: var(--destaque-ceu);
  color: var(--texto-principal);
  font: var(--fonte-botao);
  cursor: pointer;
}

.redondo:focus-visible,
.principal:focus-visible,
.velocidade:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 3px;
}
</style>
