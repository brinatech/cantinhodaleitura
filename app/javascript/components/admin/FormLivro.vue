<!--
  Formulário de livro (HU-07 Task 4): título, autor, descrição, categoria e arquivo.
  Não chama a API: confere o básico e avisa a página com o evento "enviar".
  Quem chama a API e devolve os erros do Rails (prop "erros") é a LivrosView.
-->
  <script setup>
import { computed, reactive, ref, watch } from 'vue'
import Botao from '../ui/Botao.vue'
import CampoFormulario from '../ui/CampoFormulario.vue'
import Icone from '../ui/Icone.vue'

const props = defineProps({
  categorias: { type: Array, required: true },
  livro: { type: Object, default: null }, // livro em edição; null = cadastrando um novo
  salvando: { type: Boolean, default: false },
  erros: { type: Object, default: () => ({}) }, // erros do Rails: { titulo: 'Título não pode...' }
})

const emit = defineEmits(['enviar', 'cancelar'])

const TAMANHO_MAXIMO = 50 * 1024 * 1024 // 50 MB, o mesmo limite do Rails
// Um campo de arquivo para cada formato. "campo" é o nome dele no formulário.
const FORMATOS = {
  texto: { rotulo: 'Arquivo de texto', ajuda: 'PDF, até 50 MB.', aceita: '.pdf', campo: 'arquivoTexto' },
  audio: { rotulo: 'Arquivo de áudio (audiobook)', ajuda: 'MP3, OGG ou WAV, até 50 MB.', aceita: '.mp3,.ogg,.wav', campo: 'arquivoAudio' },
}

const formulario = reactive({
  titulo: '',
  autor: '',
  descricao: '',
  idCategoria: '',
  arquivoTexto: null,
  arquivoAudio: null,
})
const errosLocais = reactive({ titulo: '', categoria: '', arquivoTexto: '', arquivoAudio: '' })
const chaveArquivo = ref(0) // trocar o número "recria" os campos de arquivo, e eles voltam vazios

// O erro que o navegador achou vem primeiro; senão, mostra o que o Rails devolveu
const erroDe = (campo) => errosLocais[campo] || props.erros[campo] || ''

const categoriasOrdenadas = computed(() =>
  [...props.categorias].sort((a, b) => a.nome.localeCompare(b.nome, 'pt-BR')),
)

function escolherArquivo(evento, campo) {
  formulario[campo] = evento.target.files[0] ?? null
  errosLocais[campo] = ''
}

// Confere um arquivo: devolve a mensagem de erro, ou '' se está tudo certo
function conferirArquivo(arquivo, formato) {
  if (!arquivo) return ''
  const extensao = `.${arquivo.name.split('.').pop().toLowerCase()}`
  if (!formato.aceita.split(',').includes(extensao)) return `Escolha um arquivo ${formato.aceita.replaceAll(',', ', ')}.`
  if (arquivo.size > TAMANHO_MAXIMO) return 'O arquivo pode ter no máximo 50 MB.'
  return ''
}

function validar() {
  Object.assign(errosLocais, { titulo: '', categoria: '', arquivoTexto: '', arquivoAudio: '' })
  if (!formulario.titulo.trim()) errosLocais.titulo = 'Escreva o título do livro.'
  if (!formulario.idCategoria) errosLocais.categoria = 'Escolha uma categoria.'

  errosLocais.arquivoTexto = conferirArquivo(formulario.arquivoTexto, FORMATOS.texto)
  errosLocais.arquivoAudio = conferirArquivo(formulario.arquivoAudio, FORMATOS.audio)
  // Só no cadastro: na edição o livro já tem arquivo, e trocar é opcional
  if (!props.livro && !formulario.arquivoTexto && !formulario.arquivoAudio) {
    errosLocais.arquivoTexto = 'Escolha pelo menos um arquivo: o texto, o áudio ou os dois.'
  }

  // Passou se nenhum erro ficou preenchido
  return !Object.values(errosLocais).some(Boolean)
}

function enviar() {
  if (!validar()) return
  emit('enviar', {
    ...formulario,
    titulo: formulario.titulo.trim(),
    autor: formulario.autor.trim(),
    descricao: formulario.descricao.trim(),
  })
}

// A página chama depois de salvar, para o formulário voltar ao começo
function limpar() {
  Object.assign(formulario, { titulo: '', autor: '', descricao: '', idCategoria: '', arquivoTexto: null, arquivoAudio: null })
  Object.assign(errosLocais, { titulo: '', categoria: '', arquivoTexto: '', arquivoAudio: '' })
  chaveArquivo.value++
}

// O arquivo que o livro em edição já tem, daquele tipo (ou nada)
const arquivoAtual = (tipo) => props.livro?.arquivos.find((arquivo) => arquivo.tipo === tipo)

// Quando a página escolhe um livro para editar, enche o formulário com os dados dele.
// Quando volta a null (salvou ou cancelou), o formulário volta ao começo.
watch(
  () => props.livro,
  (livro) => {
    if (!livro) return limpar()
    Object.assign(formulario, {
      titulo: livro.titulo,
      autor: livro.autor ?? '',
      descricao: livro.descricao ?? '',
      idCategoria: livro.id_categoria,
      arquivoTexto: null,
      arquivoAudio: null,
    })
    Object.assign(errosLocais, { titulo: '', categoria: '', arquivoTexto: '', arquivoAudio: '' })
    chaveArquivo.value++
  },
)

defineExpose({ limpar })
</script>

<template>
  <form class="cartao" novalidate @submit.prevent="enviar">
    <h2 class="cartao-titulo">{{ livro ? `Editar "${livro.titulo}"` : 'Novo livro' }}</h2>

    <CampoFormulario
      v-model="formulario.titulo"
      label="Título"
      name="titulo"
      maxlength="200"
      :erro="erroDe('titulo')"
      @input="errosLocais.titulo = ''"
    />
    <CampoFormulario
      v-model="formulario.autor"
      label="Autor (opcional)"
      name="autor"
      maxlength="150"
      :erro="erroDe('autor')"
    />
    <CampoFormulario
      v-model="formulario.descricao"
      label="Descrição (opcional)"
      name="descricao"
      :erro="erroDe('descricao')"
    />

    <!-- O design system ainda não tem um select: segue o mesmo visual do CampoFormulario -->
    <div class="campo" :class="{ 'campo--erro': erroDe('categoria') }">
      <label class="campo-label" for="livro-categoria">Categoria</label>
      <select
        id="livro-categoria"
        v-model="formulario.idCategoria"
        class="campo-entrada"
        :aria-invalid="erroDe('categoria') ? 'true' : undefined"
        :aria-describedby="erroDe('categoria') ? 'livro-categoria-erro' : undefined"
        @change="errosLocais.categoria = ''"
      >
        <option value="" disabled>Escolha uma categoria</option>
        <option v-for="categoria in categoriasOrdenadas" :key="categoria.id" :value="categoria.id">
          {{ categoria.nome }}
        </option>
      </select>
      <p v-if="erroDe('categoria')" id="livro-categoria-erro" class="campo-erro">
        <Icone nome="info" :tamanho="16" />
        {{ erroDe('categoria') }}
      </p>
    </div>

    <p v-if="!livro" class="campo-ajuda">Envie pelo menos um arquivo: o texto, o áudio ou os dois.</p>

    <!-- Um campo para cada formato (texto e áudio), montados a partir da lista FORMATOS -->
    <div
      v-for="(formato, tipo) in FORMATOS"
      :key="tipo"
      class="campo"
      :class="{ 'campo--erro': erroDe(formato.campo) }"
    >
      <label class="campo-label" :for="`livro-arquivo-${tipo}`">{{ formato.rotulo }}</label>
      <input
        :id="`livro-arquivo-${tipo}`"
        :key="`${tipo}-${chaveArquivo}`"
        type="file"
        class="campo-entrada"
        :accept="formato.aceita"
        :aria-invalid="erroDe(formato.campo) ? 'true' : undefined"
        :aria-describedby="`livro-arquivo-${tipo}-mensagem`"
        @change="escolherArquivo($event, formato.campo)"
      >
      <p v-if="erroDe(formato.campo)" :id="`livro-arquivo-${tipo}-mensagem`" class="campo-erro">
        <Icone nome="info" :tamanho="16" />
        {{ erroDe(formato.campo) }}
      </p>
      <p v-else :id="`livro-arquivo-${tipo}-mensagem`" class="campo-ajuda">
        <template v-if="arquivoAtual(tipo)">
          Atual: {{ arquivoAtual(tipo).nome }}. Escolha outro só se quiser trocar.
        </template>
        <template v-else>{{ formato.ajuda }}</template>
      </p>
    </div>

    <div class="acoes">
      <Botao type="submit" :disabled="salvando">
        {{ salvando ? 'Salvando...' : livro ? 'Salvar alterações' : 'Cadastrar livro' }}
      </Botao>
      <Botao v-if="livro" tipo="contorno" :disabled="salvando" @click="emit('cancelar')">
        Cancelar edição
      </Botao>
    </div>
  </form>
</template>


<style scoped>
.cartao {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-16);
  padding: var(--espaco-32);
  border-radius: var(--raio-20);
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-cartao);
}

.cartao > button {
  align-self: flex-start;
}

.cartao-titulo {
  color: var(--texto-principal);
  font: var(--fonte-subtitulo);
}

/* Mesmo visual do CampoFormulario, para os selects e o campo de arquivo */
.campo {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-8);
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
  box-shadow: inset 0 0 0 1.5px var(--borda-padrao);
  color: var(--texto-corpo);
  font: var(--fonte-interface);
  outline: none;
}

.campo-entrada:focus {
  box-shadow: inset 0 0 0 2px var(--borda-foco);
}

.campo--erro .campo-entrada {
  box-shadow: inset 0 0 0 2px var(--borda-erro);
}

/* Campo de arquivo: o botão "Escolher arquivo" do navegador com o visual do Botao contorno */
.campo-entrada[type='file'] {
  padding: var(--espaco-8);
  cursor: pointer;
}

.campo-entrada[type='file']::file-selector-button {
  margin-right: var(--espaco-12);
  padding: var(--espaco-8) var(--espaco-16);
  border: 0;
  border-radius: var(--raio-8);
  background: var(--fundo-superficie);
  box-shadow: inset 0 0 0 1.5px var(--borda-forte);
  color: var(--texto-principal);
  font: var(--fonte-botao);
  cursor: pointer;
}

.campo-entrada[type='file']:hover::file-selector-button {
  background-image: linear-gradient(
    color-mix(in srgb, var(--texto-principal) 10%, transparent),
    color-mix(in srgb, var(--texto-principal) 10%, transparent)
  );
}

.campo-erro {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--texto-erro);
  font: var(--fonte-legenda);
}

.campo-ajuda {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}

.acoes {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-12);
}

@media (max-width: 520px) {
  .cartao {
    padding: var(--espaco-24) var(--espaco-16);
  }
}
</style>
