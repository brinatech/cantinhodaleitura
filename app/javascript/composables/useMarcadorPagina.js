// Marcador de página no leitor de PDF (HU-15 Task 3). Só para quem está logado.
// - Ao abrir: busca a página salva e oferece "Continuar da página X" (não pula sozinho).
// - Ao trocar de página: salva sozinho, esperando a pessoa parar um pouco (não manda um pedido por clique).
// - Só salva páginas que a pessoa abriu: abrir o livro na página 1 não apaga o marcador antigo.
// - Erro ao salvar não atrapalha a leitura (tenta de novo na próxima troca de página).
import { computed, onBeforeUnmount, onMounted, ref, toValue, watch } from 'vue'
import { buscarMarcador, salvarMarcador } from '../services/marcadoresService.js'
import { useAuthStore } from '../stores/auth.js'

const ESPERA_PARA_SALVAR = 1500 // ms parado na página antes de salvar

export function useMarcadorPagina(livroId) {
  const auth = useAuthStore()

  const paginaSalva = ref(null) // a página do marcador quando o livro abriu
  const totalPaginas = ref(0)
  const dispensado = ref(false) // a pessoa respondeu ao aviso ou já trocou de página

  let pendente = null // página esperando para ser salva
  let ultimaSalva = null
  let temporizador = null
  let desligado = false // a sessão expirou (401): para de tentar

  // Só oferece quando faz sentido: tem página salva, ela existe neste PDF e não é a primeira
  const oferecerContinuar = computed(
    () =>
      !dispensado.value &&
      paginaSalva.value > 1 &&
      totalPaginas.value > 0 &&
      paginaSalva.value <= totalPaginas.value,
  )

  async function carregar() {
    salvarAgora() // se trocou de livro com uma página pendente, salva no livro anterior antes
    paginaSalva.value = null
    totalPaginas.value = 0
    dispensado.value = false
    ultimaSalva = null
    desligado = false
    const id = toValue(livroId)
    if (!auth.usuario || !id) return

    try {
      const marcador = await buscarMarcador(id)
      if (toValue(livroId) !== id) return // trocou de livro enquanto esperava
      paginaSalva.value = marcador?.pagina_atual ?? null
      ultimaSalva = paginaSalva.value
    } catch {
      // sem marcador desta vez: o livro abre do início
    }
  }

  // O LeitorPdf avisa quantas páginas o livro tem quando termina de abrir
  const aoAbrirPdf = (total) => {
    totalPaginas.value = total
  }

  // O LeitorPdf avisa quando a pessoa troca de página
  function aoMudarPagina(pagina) {
    dispensado.value = true
    if (!auth.usuario || desligado) return
    pendente = { livroId: toValue(livroId), pagina }
    clearTimeout(temporizador)
    temporizador = setTimeout(salvarAgora, ESPERA_PARA_SALVAR)
  }

  async function salvarAgora() {
    clearTimeout(temporizador)
    temporizador = null
    const pedido = pendente
    pendente = null
    if (!pedido || pedido.pagina === ultimaSalva) return

    try {
      await salvarMarcador(pedido.livroId, pedido.pagina)
      if (pedido.livroId === toValue(livroId)) ultimaSalva = pedido.pagina
    } catch (falha) {
      if (falha.status === 401) desligado = true
    }
  }

  // Saiu da aba ou minimizou: salva logo, sem esperar
  const aoEsconder = () => {
    if (document.visibilityState === 'hidden') salvarAgora()
  }

  watch(() => toValue(livroId), carregar, { immediate: true })
  onMounted(() => document.addEventListener('visibilitychange', aoEsconder))
  onBeforeUnmount(() => {
    document.removeEventListener('visibilitychange', aoEsconder)
    salvarAgora() // saiu da tela de leitura: salva o que faltava
  })

  return {
    paginaSalva,
    oferecerContinuar,
    aoAbrirPdf,
    aoMudarPagina,
    dispensar: () => (dispensado.value = true),
  }
}
