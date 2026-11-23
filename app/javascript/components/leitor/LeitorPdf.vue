<!--
  Leitor de PDF (HU-10 Task 4), desenhado no visual do site com o PDF.js (Mozilla):
  as páginas viram imagens num <canvas> e os controles são os do design system.
  Mostra uma página por vez (como um livro), com página anterior/próxima, zoom e
  "ajustar à largura". Uma camada de texto invisível por cima da página deixa
  selecionar o texto e o leitor de tela ler.

  O endereço é o da API com ?modo=leitura. O link do arquivo vale 5 minutos, por isso
  o PDF é baixado inteiro de uma vez (sem pedaços), com a barra de progresso.
  Marcador de página (HU-15): avisa "aberto" (total de páginas) e "mudou-pagina" (só quando a
  pessoa troca de página, não ao abrir), e quem usa pode chamar irPara(n) pelo ref.
-->
<script setup>
import { computed, onBeforeUnmount, onMounted, ref, shallowRef, watch } from 'vue'
import { GlobalWorkerOptions, getDocument, TextLayer } from 'pdfjs-dist'
import enderecoDoWorker from 'pdfjs-dist/build/pdf.worker.min.mjs?url'
import Alerta from '../ui/Alerta.vue'
import BarraProgresso from '../ui/BarraProgresso.vue'
import Botao from '../ui/Botao.vue'
import Icone from '../ui/Icone.vue'

// O PDF.js faz o trabalho pesado num "worker" (um ajudante em segundo plano), para a tela não travar
GlobalWorkerOptions.workerSrc = enderecoDoWorker

const props = defineProps({
  url: { type: String, required: true }, // /api/v1/livros/:id/arquivos/:id
  titulo: { type: String, required: true },
})

const emit = defineEmits(['aberto', 'mudou-pagina'])

const ZOOM_MINIMO = 0.5
const ZOOM_MAXIMO = 3
const PASSO_ZOOM = 0.25

const urlLeitura = computed(() => `${props.url}?modo=leitura`)

// shallowRef: o objeto do PDF.js é grande e não precisa ser "vigiado" pelo Vue por dentro
const documento = shallowRef(null)
const totalPaginas = ref(0)
const pagina = ref(1)
const zoom = ref(1) // 1 = a página ocupa a largura da área (ajustar à largura)
const progressoDownload = ref(0)
const carregando = ref(true)
const erro = ref('')

// Tela cheia: o leitor ocupa o monitor inteiro (Esc sai). Alguns celulares (iPhone) não têm essa função.
const leitor = ref(null)
const telaCheiaDisponivel = typeof document !== 'undefined' && document.fullscreenEnabled
const emTelaCheia = ref(false)

function alternarTelaCheia() {
  if (document.fullscreenElement) document.exitFullscreen()
  else leitor.value?.requestFullscreen().catch(() => {})
}

const acompanharTelaCheia = () => (emTelaCheia.value = document.fullscreenElement === leitor.value)

const area = ref(null) // onde a página fica (para medir a largura disponível)
const tela = ref(null) // o <canvas> onde a página é desenhada
const camadaTexto = ref(null)
const folha = ref(null) // a "folha": canvas + camada de texto, uma por cima da outra

let tarefaCarregar = null
let tarefaDesenho = null
let camadaAtual = null
let observador = null
let vezDoDesenho = 0 // cada desenho novo ganha um número; um desenho antigo que termina atrasado é ignorado

// Transição ao trocar de página: a folha nova desliza um pouco e aparece, na direção da leitura.
// 'frente' (próxima), 'tras' (anterior), 'abrir' (primeira página) ou null (zoom e redimensionar: sem transição).
let proximaTransicao = 'abrir'
const DURACAO_TRANSICAO = 220 // ms
const DESLOCAMENTO = 24 // px

// Quem pediu "reduzir movimento" no sistema (Windows, celular, Mac) não vê animação
const semMovimento = () => window.matchMedia('(prefers-reduced-motion: reduce)').matches

function animarFolha(tipo) {
  if (!folha.value) return
  folha.value.style.opacity = '' // estava escondida enquanto a página era desenhada
  if (!tipo || semMovimento()) return
  const deslocamento = { frente: DESLOCAMENTO, tras: -DESLOCAMENTO, abrir: 0 }[tipo]
  folha.value.animate(
    [
      { opacity: 0, transform: `translateX(${deslocamento}px)` },
      { opacity: 1, transform: 'translateX(0)' },
    ],
    { duration: DURACAO_TRANSICAO, easing: 'ease-out' },
  )
}

const progressoLeitura = computed(() => (totalPaginas.value ? (pagina.value / totalPaginas.value) * 100 : 0))
const textoZoom = computed(() => `${Math.round(zoom.value * 100)}%`)

async function carregar() {
  erro.value = ''
  carregando.value = true
  progressoDownload.value = 0
  pagina.value = 1
  zoom.value = 1
  proximaTransicao = 'abrir'
  tarefaCarregar?.destroy()
  documento.value?.destroy()
  documento.value = null

  // Baixa o PDF inteiro de uma vez: o link vale só 5 minutos e não dá para buscar pedaços depois
  tarefaCarregar = getDocument({ url: urlLeitura.value, disableRange: true, disableStream: true, disableAutoFetch: true })
  tarefaCarregar.onProgress = ({ loaded, total }) => {
    if (total) progressoDownload.value = Math.round((loaded / total) * 100)
  }

  try {
    const pdf = await tarefaCarregar.promise
    documento.value = pdf
    totalPaginas.value = pdf.numPages
    emit('aberto', pdf.numPages)
  } catch (falha) {
    if (falha?.name === 'AbortException') return // a pessoa saiu da tela antes de terminar
    erro.value = 'Não foi possível abrir este livro. Tente de novo ou baixe o PDF.'
  } finally {
    carregando.value = false
  }
}

async function desenhar() {
  const pdf = documento.value
  if (!pdf || !tela.value || !area.value) return
  const vez = ++vezDoDesenho
  tarefaDesenho?.cancel()
  camadaAtual?.cancel()

  const paginaPdf = await pdf.getPage(pagina.value)
  if (vez !== vezDoDesenho) return

  // "Ajustar à largura": a escala em que a página cabe na área. O zoom multiplica essa escala.
  const larguraOriginal = paginaPdf.getViewport({ scale: 1 }).width
  // Largura útil = largura da área menos as faixas laterais (onde ficam as setas)
  const estilo = getComputedStyle(area.value)
  const faixas = parseFloat(estilo.paddingLeft) + parseFloat(estilo.paddingRight)
  const larguraDisponivel = Math.max(200, area.value.clientWidth - faixas)
  const escala = (larguraDisponivel / larguraOriginal) * zoom.value
  const viewport = paginaPdf.getViewport({ scale: escala })

  // Vai ter transição: esconde a folha enquanto desenha, para não piscar em branco antes da animação
  if (proximaTransicao && !semMovimento()) folha.value.style.opacity = '0'

  // Telas de alta definição (celular, notebook com zoom do Windows): desenha com mais pixels, para não ficar borrado
  const densidade = window.devicePixelRatio || 1
  const canvas = tela.value
  canvas.width = Math.floor(viewport.width * densidade)
  canvas.height = Math.floor(viewport.height * densidade)
  canvas.style.width = `${Math.floor(viewport.width)}px`
  canvas.style.height = `${Math.floor(viewport.height)}px`

  tarefaDesenho = paginaPdf.render({
    canvasContext: canvas.getContext('2d'),
    viewport,
    transform: densidade === 1 ? null : [densidade, 0, 0, densidade, 0, 0],
  })
  try {
    await tarefaDesenho.promise
  } catch (falha) {
    if (falha?.name === 'RenderingCancelledException') return // trocou de página no meio: tudo certo
    throw falha
  }
  if (vez !== vezDoDesenho) return

  // A página nova já está desenhada: agora sim, a transição (só quando trocou de página ou abriu o livro)
  animarFolha(proximaTransicao)
  proximaTransicao = null

  // Camada de texto invisível por cima do desenho: selecionar texto e leitor de tela
  folha.value.style.setProperty('--scale-factor', String(escala))
  camadaTexto.value.replaceChildren()
  camadaAtual = new TextLayer({ textContentSource: paginaPdf.streamTextContent(), container: camadaTexto.value, viewport })
  await camadaAtual.render().catch(() => {}) // se falhar, a página continua legível
}

function irPara(numero) {
  const destino = Math.min(totalPaginas.value, Math.max(1, numero))
  if (destino === pagina.value) return
  proximaTransicao = destino > pagina.value ? 'frente' : 'tras'
  pagina.value = destino
  area.value?.scrollTo({ top: 0, left: 0 }) // a folha nova começa do alto, como virar a página de um livro
  mostrarComecoDaFolha()
  emit('mudou-pagina', destino)
}

// Altura do que fica preso no topo da tela (ex.: a barra de busca da área logada).
// Olha o elemento bem no alto da tela e sobe até achar um "sticky"/"fixed"; sem nenhum, é 0.
function alturaDoTopoPreso() {
  let el = document.elementFromPoint(window.innerWidth / 2, 1)
  while (el && el !== document.body) {
    const posicao = getComputedStyle(el).position
    if (posicao === 'sticky' || posicao === 'fixed') return Math.max(0, el.getBoundingClientRect().bottom)
    el = el.parentElement
  }
  return 0
}

// Se o começo da folha ficou escondido (acima da tela ou atrás da barra do topo), rola até ele.
// Se já está à vista, nada se mexe. Em tela cheia, quem rola é o próprio leitor.
function mostrarComecoDaFolha() {
  if (!area.value) return
  const folga = alturaDoTopoPreso() + 16
  const distancia = area.value.getBoundingClientRect().top - folga
  if (distancia >= 0) return
  const semMovimento =
    window.matchMedia('(prefers-reduced-motion: reduce)').matches || document.documentElement.hasAttribute('data-calmo')
  const rolavel = document.fullscreenElement ?? window
  rolavel.scrollBy({ top: distancia, behavior: semMovimento ? 'auto' : 'smooth' })
}

// O marcador (HU-15) usa para "Continuar da página X"
defineExpose({ irPara })

// Celular: deslizar o dedo para o lado troca de página (só sem zoom, porque com zoom o dedo arrasta a página)
let toqueInicial = null
const DISTANCIA_MINIMA_DO_GESTO = 60 // px

function inicioDoToque(evento) {
  const toque = evento.touches[0]
  toqueInicial = evento.touches.length === 1 ? { x: toque.clientX, y: toque.clientY } : null
}

function fimDoToque(evento) {
  if (!toqueInicial || zoom.value > 1) return
  const toque = evento.changedTouches[0]
  const andouX = toque.clientX - toqueInicial.x
  const andouY = toque.clientY - toqueInicial.y
  toqueInicial = null
  // Precisa ser um deslize bem para o lado (não uma rolagem para baixo)
  if (Math.abs(andouX) < DISTANCIA_MINIMA_DO_GESTO || Math.abs(andouX) < Math.abs(andouY) * 1.5) return
  irPara(andouX < 0 ? pagina.value + 1 : pagina.value - 1)
}

function mudarZoom(novo) {
  zoom.value = Math.min(ZOOM_MAXIMO, Math.max(ZOOM_MINIMO, novo))
}

// Setas do teclado trocam de página quando o foco está no leitor
function teclado(evento) {
  if (evento.target.closest('input, button, a')) return
  if (evento.key === 'ArrowRight' || evento.key === 'PageDown') irPara(pagina.value + 1)
  else if (evento.key === 'ArrowLeft' || evento.key === 'PageUp') irPara(pagina.value - 1)
  else return
  evento.preventDefault()
}

watch(urlLeitura, carregar, { immediate: true })
// Redesenha quando o livro chega, quando troca de página e quando muda o zoom
watch([documento, pagina, zoom], desenhar, { flush: 'post' })

onMounted(() => {
  // Se a largura da área mudar (girar o celular, abrir o menu), a página se ajusta de novo
  let pedido = 0
  observador = new ResizeObserver(() => {
    cancelAnimationFrame(pedido)
    pedido = requestAnimationFrame(desenhar)
  })
  if (area.value) observador.observe(area.value)
  document.addEventListener('fullscreenchange', acompanharTelaCheia)
})

onBeforeUnmount(() => {
  document.removeEventListener('fullscreenchange', acompanharTelaCheia)
  if (document.fullscreenElement === leitor.value) document.exitFullscreen()
  observador?.disconnect()
  tarefaDesenho?.cancel()
  camadaAtual?.cancel()
  tarefaCarregar?.destroy()
  documento.value?.destroy()
})
</script>

<template>
  <section class="pdf" aria-label="Leitura do livro" @keydown="teclado">
    <div v-if="carregando" class="pdf-carregando" role="status">
      <BarraProgresso :progresso="progressoDownload" rotulo="Abrindo o livro..." :valor="`${progressoDownload}%`" />
    </div>

    <template v-else-if="erro">
      <Alerta tipo="erro">{{ erro }}</Alerta>
      <div class="pdf-acoes">
        <Botao tipo="contorno" @click="carregar">Tentar de novo</Botao>
        <Botao tipo="contorno" :href="url">Baixar o PDF</Botao>
      </div>
    </template>

    <!-- v-show (e não v-if): o canvas precisa existir para o PDF.js desenhar nele -->
    <div v-show="documento && !carregando && !erro" ref="leitor" class="pdf-leitor">
      <div class="pdf-barra" role="toolbar" aria-label="Controles do livro">
        <!-- Trocar de página: pelas setas nas laterais da folha (abaixo) -->
        <span class="pdf-pagina" aria-live="polite">Página {{ pagina }} de {{ totalPaginas }}</span>

        <div class="pdf-grupo">
          <Botao tipo="contorno" class="pdf-botao" :disabled="zoom <= ZOOM_MINIMO" aria-label="Diminuir o zoom" @click="mudarZoom(zoom - PASSO_ZOOM)">
            <span aria-hidden="true">−</span>
          </Botao>
          <span class="pdf-zoom" aria-live="polite">{{ textoZoom }}</span>
          <Botao tipo="contorno" class="pdf-botao" :disabled="zoom >= ZOOM_MAXIMO" aria-label="Aumentar o zoom" @click="mudarZoom(zoom + PASSO_ZOOM)">
            <span aria-hidden="true">+</span>
          </Botao>
          <!-- No celular só "Ajustar" aparece; o nome completo fica no aria-label (começa com o texto visível) -->
          <Botao tipo="contorno" class="pdf-acao" aria-label="Ajustar à largura" :disabled="zoom === 1" @click="mudarZoom(1)">
            <span>Ajustar<span class="pdf-texto-longo"> à largura</span></span>
          </Botao>
        </div>

        <div class="pdf-grupo">
          <Botao v-if="telaCheiaDisponivel" tipo="contorno" class="pdf-acao" :aria-pressed="emTelaCheia" @click="alternarTelaCheia">
            {{ emTelaCheia ? 'Sair da tela cheia' : 'Tela cheia' }}
          </Botao>
          <Botao tipo="contorno" class="pdf-acao" :href="url">
            <template #icone><Icone nome="seta-baixo" /></template>
            Baixar
          </Botao>
        </div>

        <!-- Só no celular: quebra a linha antes de "Ajustar" (ver o CSS do fim) -->
        <span class="pdf-quebra" aria-hidden="true"></span>
      </div>

      <BarraProgresso :progresso="progressoLeitura" rotulo="Seu progresso neste livro" :valor="`${Math.round(progressoLeitura)}%`" />

      <!-- O "palco": a área da página com as setas por cima, nas laterais (ficam paradas mesmo rolando a página) -->
      <div class="pdf-palco">
        <div
          ref="area"
          class="pdf-area"
          tabindex="0"
          :aria-label="`Página ${pagina} de ${titulo}`"
          @touchstart.passive="inicioDoToque"
          @touchend="fimDoToque"
        >
          <div ref="folha" class="pdf-folha">
            <canvas ref="tela" class="pdf-tela" aria-hidden="true"></canvas>
            <div ref="camadaTexto" class="textLayer"></div>
          </div>
        </div>

        <button
          v-if="pagina > 1"
          type="button"
          class="pdf-seta pdf-seta--anterior"
          aria-label="Página anterior"
          @click="irPara(pagina - 1)"
        >
          <Icone nome="seta-esquerda" :tamanho="28" />
        </button>
        <button
          v-if="pagina < totalPaginas"
          type="button"
          class="pdf-seta pdf-seta--proxima"
          aria-label="Próxima página"
          @click="irPara(pagina + 1)"
        >
          <Icone nome="seta-direita" :tamanho="28" />
        </button>
      </div>

      <!-- Espaço preso embaixo da tela (ex.: o player do audiobook). Fica dentro do leitor
           para continuar aparecendo na tela cheia. -->
      <div v-if="$slots.rodape" class="pdf-rodape-fixo">
        <slot name="rodape" />
      </div>
    </div>
  </section>
</template>

<style scoped>
.pdf {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-16);
}

.pdf-carregando {
  max-width: 420px;
  padding: var(--espaco-24);
  border-radius: var(--raio-20);
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-cartao);
}

.pdf-leitor {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-16);
}

/* Barra de controles: no visual do site, num cartão branco */
.pdf-barra {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: var(--espaco-12);
  padding: var(--espaco-12) var(--espaco-16);
  border-radius: var(--raio-20);
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-cartao);
}

.pdf-grupo {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: var(--espaco-8);
}

/* Botões só com ícone: quadrados, com área de toque de 44px */
.pdf-botao {
  min-width: 44px;
  min-height: 44px;
  padding: var(--espaco-8);
}

.pdf-pagina,
.pdf-zoom {
  min-width: 4ch;
  color: var(--texto-principal);
  font: var(--fonte-botao);
  text-align: center;
}

.pdf-pagina {
  min-width: 14ch;
}

.pdf-quebra {
  display: none;
}

/* Rodapé preso: acompanha a rolagem e fica sempre visível embaixo da tela */
.pdf-rodape-fixo {
  position: sticky;
  bottom: var(--espaco-12);
  z-index: 5;
}

/* O palco segura a área da página e as setas, que ficam por cima */
.pdf-palco {
  position: relative;
  display: flex;
  flex-direction: column;
}

/* Setas laterais: redondas, meio transparentes; ficam fortes ao passar o mouse ou com o foco */
.pdf-seta {
  position: absolute;
  top: 50%;
  z-index: 2;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 52px;
  height: 52px;
  padding: 0;
  border: 1.5px solid var(--borda-padrao);
  border-radius: 50%;
  background: color-mix(in srgb, var(--fundo-superficie) 85%, transparent);
  box-shadow: var(--sombra-cartao);
  color: var(--texto-principal);
  cursor: pointer;
  opacity: 0.75;
  transform: translateY(-50%);
  transition: opacity 0.15s ease, background-color 0.15s ease;
}

.pdf-seta--anterior {
  left: var(--espaco-12);
}

.pdf-seta--proxima {
  right: var(--espaco-12);
}

.pdf-seta:hover,
.pdf-seta:focus-visible {
  background: var(--fundo-superficie);
  opacity: 1;
}

.pdf-seta:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 2px;
}

@media (prefers-reduced-motion: reduce) {
  .pdf-seta {
    transition: none;
  }
}

/* A "mesa" onde a folha fica: rola sozinha quando o zoom passa da largura */
.pdf-area {
  display: flex;
  justify-content: center;
  max-height: calc(100vh - 220px);
  min-height: 420px;
  /* Faixas laterais de 76px: espaço para as setas não ficarem em cima do texto */
  padding: var(--espaco-16) 76px;
  overflow: auto;
  border-radius: var(--raio-20);
  background: var(--fundo-nuvem);
  outline: none;
}

.pdf-area:focus-visible {
  box-shadow: inset 0 0 0 3px var(--borda-foco);
}

/* A folha do livro: o desenho e a camada de texto, um por cima do outro */
.pdf-folha {
  position: relative;
  flex-shrink: 0;
  align-self: flex-start;
  border-radius: var(--raio-8);
  overflow: hidden;
  background: #fff;
  box-shadow: var(--sombra-cartao);
}

.pdf-tela {
  display: block;
}

.pdf-acoes {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-12);
}

/* Tela cheia: o leitor ocupa o monitor e a "mesa" da página estica até embaixo */
.pdf-leitor:fullscreen {
  padding: var(--espaco-16);
  overflow: auto;
  background: var(--fundo-pagina);
}

.pdf-leitor:fullscreen .pdf-palco {
  flex: 1;
}

.pdf-leitor:fullscreen .pdf-area {
  flex: 1;
  max-height: none;
}

/* Camada de texto do PDF.js (regras essenciais do pdf_viewer.css): o texto fica
   invisível, só para selecionar e para o leitor de tela */
.pdf-folha :deep(.textLayer) {
  position: absolute;
  inset: 0;
  overflow: clip;
  line-height: 1;
  text-size-adjust: none;
  forced-color-adjust: none;
  transform-origin: 0 0;
  z-index: 0;
}

.pdf-folha :deep(.textLayer :is(span, br)) {
  position: absolute;
  color: transparent;
  white-space: pre;
  cursor: text;
  transform-origin: 0% 0%;
}

.pdf-folha :deep(.textLayer span.markedContent) {
  top: 0;
  height: 0;
}

.pdf-folha :deep(.textLayer ::selection) {
  background: color-mix(in srgb, var(--destaque-ceu) 45%, transparent);
}

.pdf-folha :deep(.textLayer br::selection) {
  background: transparent;
}

.pdf-folha :deep(.textLayer .endOfContent) {
  display: block;
  position: absolute;
  inset: 100% 0 0;
  user-select: none;
}

@media (max-width: 768px) {
  .pdf-area {
    max-height: 75vh;
    min-height: 320px;
    padding: var(--espaco-8);
  }

  .pdf-barra {
    justify-content: center;
  }

  /* Celular: setas menores, por cima da página (também dá para deslizar o dedo) */
  .pdf-seta {
    width: 40px;
    height: 40px;
    opacity: 0.6;
  }

  .pdf-seta--anterior {
    left: var(--espaco-4);
  }

  .pdf-seta--proxima {
    right: var(--espaco-4);
  }
}

/* ===== Celular: a barra em 2 linhas =====
   1ª: "Página 1 de 8" à esquerda e o zoom (− 100% +) à direita
   2ª: Ajustar · Tela cheia · Baixar, dividindo a largura
   Os grupos "somem" (display: contents) para cada botão ir para o seu lugar com "order";
   o .pdf-quebra ocupa uma linha inteira de altura zero e empurra os botões para baixo */
@media (max-width: 640px) {
  .pdf-barra {
    gap: var(--espaco-8);
    padding: var(--espaco-12);
  }

  .pdf-grupo {
    display: contents;
  }

  .pdf-pagina {
    flex: 1;
    order: 1;
    min-width: 0;
    text-align: left;
  }

  .pdf-botao,
  .pdf-zoom {
    order: 2;
  }

  .pdf-quebra {
    display: block;
    flex-basis: 100%;
    order: 3;
  }

  .pdf-acao {
    flex: 1 1 auto;
    order: 4;
    min-height: 44px;
    padding: var(--espaco-8) var(--espaco-12);
    white-space: nowrap;
  }

  .pdf-texto-longo {
    display: none;
  }
}
</style>
