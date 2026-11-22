<!--
  Formulário de lista de leitura (HU-13 Task 4): nome (obrigatório, até 100) e descrição.
  Serve para criar e para editar: "inicial" traz os dados da lista que está sendo editada.
  Só valida o básico aqui; quem manda de verdade é o Rails (os erros 422 aparecem por campo).
-->
<script setup>
import { reactive, ref, watch } from 'vue'
import Botao from '../ui/Botao.vue'
import CampoFormulario from '../ui/CampoFormulario.vue'

const props = defineProps({
  inicial: { type: Object, default: null }, // { nome, descricao } ao editar
  textoSalvar: { type: String, default: 'Criar lista' },
  salvando: { type: Boolean, default: false },
  errosServidor: { type: Object, default: () => ({}) }, // { nome: ['...'] } do 422
})

const emit = defineEmits(['salvar', 'cancelar'])

const campos = reactive({ nome: '', descricao: '' })
const erroNome = ref('')

watch(
  () => props.inicial,
  (lista) => {
    campos.nome = lista?.nome ?? ''
    campos.descricao = lista?.descricao ?? ''
    erroNome.value = ''
  },
  { immediate: true },
)

watch(
  () => props.errosServidor,
  (erros) => {
    erroNome.value = erros?.nome?.[0] ? `O nome ${erros.nome[0]}.` : ''
  },
)

function enviar() {
  const nome = campos.nome.trim()
  if (!nome) {
    erroNome.value = 'Dê um nome para a lista.'
    return
  }
  if (nome.length > 100) {
    erroNome.value = 'O nome pode ter no máximo 100 letras.'
    return
  }
  erroNome.value = ''
  emit('salvar', { nome, descricao: campos.descricao.trim() })
}
</script>

<template>
  <form class="form-lista" novalidate @submit.prevent="enviar">
    <CampoFormulario
      v-model="campos.nome"
      label="Nome da lista"
      placeholder="Ex.: Para ler nas férias"
      maxlength="100"
      :erro="erroNome"
      required
    />
    <CampoFormulario
      v-model="campos.descricao"
      label="Descrição (opcional)"
      placeholder="Ex.: Histórias de aventura para ler com a minha irmã"
    />

    <div class="form-lista-acoes">
      <Botao type="submit" :disabled="salvando">{{ salvando ? 'Salvando...' : textoSalvar }}</Botao>
      <Botao v-if="inicial" tipo="contorno" :disabled="salvando" @click="emit('cancelar')">Cancelar</Botao>
    </div>
  </form>
</template>

<style scoped>
.form-lista {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-16);
}

.form-lista-acoes {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-12);
}
</style>
