<!--
  Alerta (Figma: "Alerta"). Feedback de sistema. A mensagem vai no slot.
  Tipos: info, sucesso, erro. Info e sucesso são avisos calmos (role="status");
  erro é anunciado na hora (role="alert"). Nunca só a cor: sempre tem ícone.
-->
<script setup>
import Icone from './Icone.vue'

defineProps({
  tipo: {
    type: String,
    default: 'info',
    validator: (valor) => ['info', 'sucesso', 'erro'].includes(valor),
  },
})
</script>

<template>
  <div class="alerta" :class="`alerta--${tipo}`" :role="tipo === 'erro' ? 'alert' : 'status'">
    <Icone class="alerta-icone" :nome="tipo === 'sucesso' ? 'check' : 'info'" :tamanho="20" />
    <p class="alerta-mensagem"><slot /></p>
  </div>
</template>

<style scoped>
.alerta {
  --fundo: var(--fundo-suave);
  --borda: var(--destaque-ceu);
  --cor-texto: var(--texto-corpo);
  --cor-icone: var(--texto-principal);

  display: flex;
  align-items: center;
  gap: var(--espaco-12);
  min-height: 56px;
  padding: var(--espaco-16);
  border-radius: var(--raio-12);
  background: var(--fundo);
  /* Borda de 1,5px com faixa de 6px à esquerda, desenhada por dentro como no Figma (altura 56) */
  box-shadow: inset 0 0 0 1.5px var(--borda), inset 6px 0 0 0 var(--borda);
  color: var(--cor-texto);
  font: var(--fonte-interface);
}

.alerta--sucesso {
  --fundo: var(--fundo-nuvem);
}

.alerta--erro {
  --fundo: var(--apoio-coral-suave);
  --borda: var(--apoio-coral);
  --cor-texto: var(--texto-erro);
  --cor-icone: var(--texto-erro);
}

.alerta-icone {
  color: var(--cor-icone);
}

.alerta-mensagem {
  flex: 1;
  min-width: 0;
}
</style>
