<!--
  Selo de conquista (Figma: "Selo de conquista"). Conquistas de leitura
  (Minhas leituras e Leitura concluída). "bloqueado" mostra o que falta, sem punir.
  ATENÇÃO: é uma proposta do design, ainda não aprovada pela equipe (não está
  nos requisitos). Não ligue a nenhuma regra antes disso.
-->
<script setup>
import Icone from './Icone.vue'

defineProps({
  cor: {
    type: String,
    default: 'laranja',
    validator: (valor) => ['laranja', 'rosa', 'coral', 'bloqueado'].includes(valor),
  },
  nome: { type: String, required: true },
  descricao: { type: String, default: '' },
})
</script>

<template>
  <div class="conquista" :class="`conquista--${cor}`">
    <span class="conquista-medalha">
      <Icone class="conquista-estrela" nome="estrela" :tamanho="40" />
    </span>
    <span class="conquista-nome">{{ nome }}</span>
    <span v-if="descricao" class="conquista-descricao">{{ descricao }}</span>
  </div>
</template>

<style scoped>
.conquista {
  --fundo: var(--apoio-laranja);
  --borda: var(--fundo-superficie);

  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--espaco-8);
  width: 100%;
  max-width: 160px;
  text-align: center;
}

.conquista--rosa {
  --fundo: var(--apoio-rosa);
}

.conquista--coral {
  --fundo: var(--apoio-coral);
}

.conquista--bloqueado {
  --fundo: var(--fundo-suave);
  --borda: var(--borda-padrao);
}

.conquista-medalha {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 88px;
  height: 88px;
  border: 4px solid var(--borda);
  border-radius: var(--raio-total);
  background: var(--fundo);
  color: var(--texto-principal);
}

/* Conquistada: estrela cheia. Bloqueada: só o contorno */
.conquista:not(.conquista--bloqueado) .conquista-estrela :deep(path) {
  fill: currentColor;
}

.conquista-nome {
  color: var(--texto-principal);
  font: var(--fonte-botao);
}

.conquista-descricao {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}
</style>
