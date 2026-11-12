<!--
  Campo de formulário (Figma: "Campo de formulário"). Campo de cadastro/login.
  Label sempre visível. Com "erro", mostra ícone + texto (nunca só a cor) e liga
  a mensagem ao campo por aria-describedby. Sem erro, mostra o texto de "ajuda".
  Atributos extras (name, autocomplete, required, inputmode...) vão para o <input>.
-->
<script setup>
import { computed, useAttrs, useId } from 'vue'
import Icone from './Icone.vue'

defineOptions({ inheritAttrs: false })

const props = defineProps({
  label: { type: String, required: true },
  type: { type: String, default: 'text' },
  placeholder: { type: String, default: '' },
  ajuda: { type: String, default: '' },
  erro: { type: String, default: '' },
  id: { type: String, default: null },
})

const valor = defineModel({ type: String, default: '' })

const attrs = useAttrs()
const idAuto = useId()
const idCampo = computed(() => props.id ?? idAuto)
const idAjuda = computed(() => `${idCampo.value}-ajuda`)
const idErro = computed(() => `${idCampo.value}-erro`)
const descritoPor = computed(() => (props.erro ? idErro.value : props.ajuda ? idAjuda.value : undefined))

// class e style ficam na raiz; o resto (name, autocomplete...) vai para o input
const atributosDoInput = computed(() => {
  const { class: _classe, style: _estilo, ...resto } = attrs
  return resto
})
</script>

<template>
  <div class="campo" :class="[attrs.class, { 'campo--erro': erro }]" :style="attrs.style">
    <label class="campo-label" :for="idCampo">{{ label }}</label>

    <input
      v-bind="atributosDoInput"
      :id="idCampo"
      v-model="valor"
      class="campo-entrada"
      :type="type"
      :placeholder="placeholder"
      :aria-invalid="erro ? 'true' : undefined"
      :aria-describedby="descritoPor"
    >

    <p v-if="erro" :id="idErro" class="campo-erro">
      <Icone nome="info" :tamanho="16" />
      {{ erro }}
    </p>
    <p v-else-if="ajuda" :id="idAjuda" class="campo-ajuda">{{ ajuda }}</p>
  </div>
</template>

<style scoped>
.campo {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-8);
  width: 100%;
}

.campo-label {
  color: var(--texto-principal);
  font: var(--fonte-botao);
}

.campo-entrada {
  width: 100%;
  padding: var(--espaco-12) var(--espaco-16);
  border: 0;
  border-radius: var(--raio-8);
  background: var(--fundo-superficie);
  /* Anel interno como o traço do Figma: o foco e o erro não mudam o tamanho */
  box-shadow: inset 0 0 0 1.5px var(--borda-padrao);
  color: var(--texto-corpo);
  font: var(--fonte-interface);
  outline: none; /* o anel é o indicador de foco */
}

.campo-entrada::placeholder {
  color: var(--texto-secundario);
  opacity: 1;
}

.campo-entrada:focus,
.campo.estado-foco .campo-entrada {
  box-shadow: inset 0 0 0 2px var(--borda-foco);
}

.campo--erro .campo-entrada {
  box-shadow: inset 0 0 0 2px var(--borda-erro);
}

.campo-ajuda {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}

.campo-erro {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--texto-erro);
  font: var(--fonte-legenda);
}
</style>
