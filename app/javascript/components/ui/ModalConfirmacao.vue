<!--
  Modal de confirmação (sem Figma: segue o visual do Painel de acessibilidade).
  Substitui o window.confirm do navegador em ações como "Excluir".
  É um <dialog> nativo (showModal): escurece o fundo, prende o foco do teclado,
  Esc fecha e, ao fechar, o foco volta para o botão que abriu.

  Uso: <ModalConfirmacao ref="modal" titulo="Excluir categoria?" @confirmar="...">texto</ModalConfirmacao>
  e modal.value.abrir() / modal.value.fechar(). A página decide quando fechar
  (ex.: só depois que a API respondeu); um erro pode ser mostrado dentro do modal.
-->
<script setup>
import { ref, useId } from 'vue'
import Alerta from './Alerta.vue'
import Botao from './Botao.vue'

const props = defineProps({
  titulo: { type: String, required: true },
  textoConfirmar: { type: String, default: 'Confirmar' },
  textoCarregando: { type: String, default: 'Aguarde...' },
  textoCancelar: { type: String, default: 'Cancelar' },
  carregando: { type: Boolean, default: false },
  erro: { type: String, default: '' },
})

const emit = defineEmits(['confirmar', 'fechado'])

const dialogo = ref(null)
const idTitulo = useId()
const idTexto = useId()

const abrir = () => dialogo.value.showModal()
const fechar = () => dialogo.value.close()

// Enquanto espera a API, não deixa fechar (Esc, fundo ou Cancelar)
function pedirParaFechar() {
  if (!props.carregando) fechar()
}

function aoApertarEsc(evento) {
  if (props.carregando) evento.preventDefault()
}

// Clicar no fundo escurecido (o próprio <dialog>, fora do conteúdo) fecha
const cliqueNoFundo = (evento) => evento.target === dialogo.value && pedirParaFechar()

defineExpose({ abrir, fechar })
</script>

<template>
  <dialog
    ref="dialogo"
    class="modal"
    :aria-labelledby="idTitulo"
    :aria-describedby="idTexto"
    @click="cliqueNoFundo"
    @cancel="aoApertarEsc"
    @close="emit('fechado')"
  >
    <div class="modal-conteudo">
      <h2 :id="idTitulo" class="modal-titulo">{{ titulo }}</h2>
      <div :id="idTexto" class="modal-texto"><slot /></div>

      <Alerta v-if="erro" tipo="erro">{{ erro }}</Alerta>

      <div class="modal-acoes">
        <!-- Cancelar vem primeiro e recebe o foco: é a opção segura -->
        <Botao tipo="contorno" autofocus :disabled="carregando" @click="pedirParaFechar">
          {{ textoCancelar }}
        </Botao>
        <Botao tipo="escuro" :disabled="carregando || !!erro" @click="emit('confirmar')">
          {{ carregando ? textoCarregando : textoConfirmar }}
        </Botao>
      </div>
    </div>
  </dialog>
</template>

<style scoped>
.modal::backdrop {
  background: color-mix(in srgb, var(--texto-corpo) 40%, transparent);
}

.modal {
  /* O reset do application.css zera a margem de tudo, e é a margem automática
     que centraliza o <dialog>. Aqui ela volta. */
  margin: auto;
  width: 440px;
  max-width: calc(100vw - 32px);
  padding: 0;
  border: 1px solid var(--borda-padrao);
  border-radius: 24px;
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-flutuante);
  color: var(--texto-corpo);
}

.modal-conteudo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-16);
  padding: var(--espaco-24);
}

.modal-titulo {
  color: var(--texto-principal);
  font: var(--fonte-subtitulo);
}

.modal-texto {
  color: var(--texto-corpo);
  font: var(--fonte-interface);
}

.modal-acoes {
  display: flex;
  flex-wrap: wrap;
  justify-content: flex-end;
  gap: var(--espaco-12);
  margin-top: var(--espaco-8);
}

@media (max-width: 475px) {
  .modal-acoes > * {
    flex: 1;
  }
}
</style>
