<!--
  Formulário de livro (HU-07 Task 4): título, autor, descrição, categoria e arquivo.
  Não chama a API: confere o básico e avisa a página com o evento "enviar".
  Quem chama a API e devolve os erros do Rails (prop "erros") é a LivrosView.
-->
  <script setup>
import { computed, onBeforeUnmount, reactive, ref, watch } from 'vue'
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

// Capa: só imagem, até 5 MB (o mesmo limite do Rails).
// Proporção ideal 2:3 (em pé, como capa de livro). No card do acervo a capa preenche um espaço quase
// quadrado (como no Figma): de uma capa 2:3 só sai um pedaço da parte de baixo; o topo aparece inteiro.
const CAPA = { aceita: '.jpg,.jpeg,.png,.webp', tamanhoMaximo: 5 * 1024 * 1024, proporcao: 2 / 3, tolerancia: 0.12 }

const formulario = reactive({
  titulo: '',
  autor: '',
  descricao: '',
  idCategoria: '',
  capa: null,
  arquivoTexto: null,
  arquivoAudio: null,
})
const SEM_ERROS = { titulo: '', categoria: '', capa: '', arquivoTexto: '', arquivoAudio: '' }
const errosLocais = reactive({ ...SEM_ERROS })
const chaveArquivo = ref(0) // trocar o número "recria" os campos de arquivo, e eles voltam vazios

// Pré-visualização: um endereço temporário que o navegador cria para a imagem escolhida.
// Sem imagem nova, mostra a capa que o livro em edição já tem.
const previaCapa = ref('')
const capaMostrada = computed(() => previaCapa.value || props.livro?.capa_url || '')

function trocarPrevia(arquivo) {
  if (previaCapa.value) URL.revokeObjectURL(previaCapa.value) // libera a memória da prévia anterior
  previaCapa.value = arquivo ? URL.createObjectURL(arquivo) : ''
  if (!arquivo) avisoProporcao.value = ''
}

onBeforeUnmount(() => trocarPrevia(null))

// Aviso (não bloqueia) quando a imagem foge da proporção 2:3. Ela funciona, mas o card pode cortar mais dela.
const avisoProporcao = ref('')

function conferirProporcao(endereco) {
  avisoProporcao.value = ''
  if (!endereco) return
  const imagem = new Image()
  imagem.onload = () => {
    const { naturalWidth: largura, naturalHeight: altura } = imagem
    if (!largura || !altura) return
    const diferenca = Math.abs(largura / altura - CAPA.proporcao) / CAPA.proporcao
    if (diferenca <= CAPA.tolerancia) return
    const formato = largura > altura ? 'deitada' : largura === altura ? 'quadrada' : 'mais estreita que uma capa'
    avisoProporcao.value =
      `Esta imagem tem ${largura} × ${altura} px e está ${formato}. ` +
      'Ela vai funcionar, mas no card do acervo podem ficar de fora partes das bordas. ' +
      'O ideal é 800 px de largura × 1200 px de altura, com título e autor na parte de cima.'
  }
  imagem.src = endereco
}

function escolherCapa(evento) {
  const arquivo = evento.target.files[0] ?? null
  formulario.capa = arquivo
  errosLocais.capa = ''
  trocarPrevia(arquivo)
  conferirProporcao(previaCapa.value)
}

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
  Object.assign(errosLocais, SEM_ERROS)
  if (!formulario.titulo.trim()) errosLocais.titulo = 'Escreva o título do livro.'
  if (!formulario.idCategoria) errosLocais.categoria = 'Escolha uma categoria.'

  const capa = formulario.capa
  if (capa) {
    const extensao = `.${capa.name.split('.').pop().toLowerCase()}`
    if (!CAPA.aceita.split(',').includes(extensao)) errosLocais.capa = 'A capa deve ser uma imagem JPG, PNG ou WEBP.'
    else if (capa.size > CAPA.tamanhoMaximo) errosLocais.capa = 'A capa pode ter no máximo 5 MB.'
  }

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
  Object.assign(formulario, { titulo: '', autor: '', descricao: '', idCategoria: '', capa: null, arquivoTexto: null, arquivoAudio: null })
  Object.assign(errosLocais, SEM_ERROS)
  trocarPrevia(null)
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
      capa: null,
      arquivoTexto: null,
      arquivoAudio: null,
    })
    Object.assign(errosLocais, SEM_ERROS)
    trocarPrevia(null)
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
    <!-- Descrição é texto longo: caixa de várias linhas (o CampoFormulario só tem campo de uma linha) -->
    <div class="campo" :class="{ 'campo--erro': erroDe('descricao') }">
      <label class="campo-label" for="livro-descricao">Descrição (opcional)</label>
      <textarea
        id="livro-descricao"
        v-model="formulario.descricao"
        name="descricao"
        rows="5"
        class="campo-entrada campo-texto-longo"
        :aria-invalid="erroDe('descricao') ? 'true' : undefined"
        aria-describedby="livro-descricao-mensagem"
      ></textarea>
      <p v-if="erroDe('descricao')" id="livro-descricao-mensagem" class="campo-erro">
        <Icone nome="info" :tamanho="16" />
        {{ erroDe('descricao') }}
      </p>
      <p v-else id="livro-descricao-mensagem" class="campo-ajuda">Um resumo da história, que aparece na página do livro.</p>
    </div>

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

    <!-- Capa (opcional), com a pré-visualização ao lado -->
    <div class="campo" :class="{ 'campo--erro': erroDe('capa') }">
      <label class="campo-label" for="livro-capa">Capa (opcional)</label>
      <div class="capa">
        <div class="capa-previa">
          <img v-if="capaMostrada" :src="capaMostrada" alt="Pré-visualização da capa">
          <Icone v-else nome="livro" :tamanho="32" />
        </div>
        <div class="capa-campo">
          <input
            id="livro-capa"
            :key="`capa-${chaveArquivo}`"
            type="file"
            class="campo-entrada"
            :accept="CAPA.aceita"
            :aria-invalid="erroDe('capa') ? 'true' : undefined"
            aria-describedby="livro-capa-mensagem"
            @change="escolherCapa"
          >
          <p v-if="erroDe('capa')" id="livro-capa-mensagem" class="campo-erro">
            <Icone nome="info" :tamanho="16" />
            {{ erroDe('capa') }}
          </p>
          <template v-else>
            <p id="livro-capa-mensagem" class="campo-ajuda">
              Tamanho ideal: 800 px de largura × 1200 px de altura. JPG, PNG ou WEBP, até 5 MB.
            </p>
            <p v-if="avisoProporcao" class="campo-aviso" role="status">
              <Icone nome="info" :tamanho="16" />
              {{ avisoProporcao }}
            </p>
          </template>
        </div>
      </div>
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
          Atual: {{ arquivoAtual(tipo).nome }}
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

/* Caixa de texto longo: começa com 5 linhas e a pessoa pode puxar para baixo */
.campo-texto-longo {
  min-height: 120px;
  resize: vertical;
  line-height: 1.5;
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

/* Capa: miniatura vertical (proporção de livro) ao lado do campo */
.capa {
  display: flex;
  align-items: flex-start;
  gap: var(--espaco-16);
  width: 100%;
}

.capa-previa {
  display: flex;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  width: 80px;
  aspect-ratio: 2 / 3; /* a mesma proporção recomendada para a capa */
  overflow: hidden;
  border-radius: var(--raio-8);
  background: var(--fundo-nuvem);
  color: var(--texto-secundario);
}

/* contain, como nos cards do acervo: a prévia mostra as faixas que vão sobrar */
.capa-previa img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.campo-aviso {
  display: flex;
  align-items: flex-start;
  gap: 6px;
  color: var(--texto-corpo);
  font: var(--fonte-legenda);
}

.campo-aviso :deep(svg) {
  flex-shrink: 0;
  margin-top: 2px;
}

.capa-campo {
  display: flex;
  flex: 1;
  flex-direction: column;
  gap: var(--espaco-8);
  min-width: 0;
}

@media (max-width: 520px) {
  .cartao {
    padding: var(--espaco-24) var(--espaco-16);
  }
}
</style>
