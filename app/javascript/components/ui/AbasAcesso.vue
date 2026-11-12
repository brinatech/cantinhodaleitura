<!--
  Abas de acesso (Figma: "Abas de acesso"). Alterna entre Entrar e Criar conta
  na tela de acesso. v-model = "entrar" ou "criar-conta". É um tablist com
  aria-selected; setas, Home e End trocam de aba. "painel" é o id do painel
  que a aba controla (aria-controls), se houver.
-->
<script setup>
defineProps({
  painel: { type: String, default: null },
})

const aba = defineModel({ type: String, default: 'entrar' })

const abas = [
  { valor: 'entrar', texto: 'Entrar' },
  { valor: 'criar-conta', texto: 'Criar conta' },
]
const botoes = []

function teclado(evento) {
  const atual = abas.findIndex((a) => a.valor === aba.value)
  const destino = {
    ArrowRight: (atual + 1) % abas.length,
    ArrowLeft: (atual - 1 + abas.length) % abas.length,
    Home: 0,
    End: abas.length - 1,
  }[evento.key]
  if (destino === undefined) return
  evento.preventDefault()
  aba.value = abas[destino].valor
  botoes[destino].focus()
}
</script>

<template>
  <div class="abas" role="tablist" aria-label="Acesso" @keydown="teclado">
    <button
      v-for="(item, i) in abas"
      :key="item.valor"
      :ref="(el) => (botoes[i] = el)"
      type="button"
      role="tab"
      class="aba"
      :class="{ selecionada: aba === item.valor }"
      :aria-selected="aba === item.valor"
      :aria-controls="painel ?? undefined"
      :tabindex="aba === item.valor ? 0 : -1"
      @click="aba = item.valor"
    >
      {{ item.texto }}
    </button>
  </div>
</template>

<style scoped>
.abas {
  display: flex;
  gap: var(--espaco-4);
  width: 100%;
  padding: var(--espaco-4);
  border-radius: var(--raio-total);
  background: var(--fundo-suave);
}

.aba {
  flex: 1;
  min-width: 0;
  padding: 10px 0;
  border: 0;
  border-radius: var(--raio-total);
  background: transparent;
  color: var(--texto-secundario);
  font: var(--fonte-botao);
  cursor: pointer;
}

.aba.selecionada {
  background: var(--fundo-superficie);
  box-shadow: 0 2px 6px #184e6a26;
  color: var(--texto-principal);
}

.aba:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 2px;
}
</style>
