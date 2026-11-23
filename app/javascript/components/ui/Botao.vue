<!--
  Botão do Cantinho (Figma: componente "Botão").
  Principal (céu) é a ação padrão · Escuro para destaque sobre fundo claro ·
  Contorno para ações secundárias · Destaque (laranja) só para ações divertidas,
  no máximo um por tela.

  Vira <a> com href, ou RouterLink com to. Sem nenhum dos dois, é <button>.
  Ícone opcional (24px) no slot "icone". Os estados vêm do navegador
  (:hover, :focus-visible, :disabled); as classes .estado-* só existem para
  mostrar o estado parado na página /design-system.
-->
<script setup>
import { computed } from 'vue'
import { RouterLink } from 'vue-router'

const props = defineProps({
  tipo: {
    type: String,
    default: 'principal',
    validator: (valor) => ['principal', 'escuro', 'contorno', 'destaque'].includes(valor),
  },
  to: { type: [String, Object], default: null },
  href: { type: String, default: null },
})

const tag = computed(() => (props.to ? RouterLink : props.href ? 'a' : 'button'))
</script>

<template>
  <component
    :is="tag"
    class="botao"
    :class="`botao--${tipo}`"
    :to="to ?? undefined"
    :href="href ?? undefined"
    :type="tag === 'button' ? 'button' : undefined"
  >
    <span v-if="$slots.icone" class="botao-icone" aria-hidden="true"><slot name="icone" /></span>
    <slot />
  </component>
</template>

<style scoped>
.botao {
  /* Cada tipo só troca estas variáveis; a estrutura é uma só */
  --fundo: var(--destaque-ceu);
  --cor: var(--texto-sobre-cor); /* texto sobre o azul-céu/laranja: escuro também no tema escuro */
  --camada-hover: color-mix(in srgb, var(--texto-sobre-cor) 10%, transparent);
  --anel-largura: 0px;
  --anel-cor: transparent;
  --anel-foco: var(--borda-foco);
  --camada: transparent;

  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--espaco-8);
  padding: var(--espaco-12) var(--espaco-24);
  border: 0;
  border-radius: var(--raio-8);
  background-color: var(--fundo);
  background-image: linear-gradient(var(--camada), var(--camada));
  /* O anel é interno (inset) como o traço do Figma: trocar de padrão para foco não muda o tamanho */
  box-shadow: inset 0 0 0 var(--anel-largura) var(--anel-cor);
  color: var(--cor);
  font: var(--fonte-botao);
  text-decoration: none;
  white-space: nowrap;
  cursor: pointer;
  transition: --camada var(--duracao-rapida) var(--curva); /* o hover escurece suave (ver @property abaixo) */
}

.botao--escuro {
  --fundo: var(--destaque-escuro);
  --cor: var(--texto-inverso);
  --camada-hover: color-mix(in srgb, white 12%, transparent);
  --anel-foco: var(--destaque-ceu);
}

.botao--contorno {
  --fundo: var(--fundo-superficie);
  --cor: var(--texto-principal); /* fundo da página: segue o tema */
  --camada-hover: color-mix(in srgb, var(--texto-principal) 10%, transparent);
  --anel-largura: 1.5px;
  --anel-cor: var(--borda-forte);
}

.botao--destaque {
  --fundo: var(--destaque-laranja);
}

.botao:hover:not(:disabled),
.botao.estado-hover {
  --camada: var(--camada-hover);
}

.botao:focus-visible,
.botao.estado-foco {
  --anel-largura: 3px;
  --anel-cor: var(--anel-foco);
  outline: none; /* o anel acima é o indicador de foco */
}

.botao:disabled,
.botao.estado-desabilitado {
  opacity: 0.45;
  cursor: not-allowed;
}

.botao-icone {
  display: inline-flex;
  width: 24px;
  height: 24px;
}

/* Registra --camada como cor: só assim o navegador consegue animar a troca (sem isso, ela é instantânea) */
@property --camada {
  syntax: '<color>';
  inherits: false;
  initial-value: transparent;
}
</style>
