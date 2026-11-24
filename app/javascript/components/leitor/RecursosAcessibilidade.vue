<!--
  Recursos de acessibilidade do livro (HU-17 Task 2), em cima do leitor.
  Mostra só o que existe de verdade:
  - "Ler em voz alta": a página atual do PDF, pela voz do navegador (speechSynthesis).
    Se o navegador não suporta, ou a página não tem texto, a tela avisa (nunca um botão que não funciona).
  - Recursos declarados no cadastro do livro (classificações do tipo "acessibilidade"): só a lista.
    Legendas, Libras e audiodescrição não têm onde ser guardados ainda (docs/frontend/acessibilidade.md, seção 5).
  Começa aberto quando "Ler em voz alta" está ligado no painel de ajustes.
  Props: recursos (classificações), obterTexto (async, devolve o texto da página; ausente se o livro não tem PDF),
  pagina (a voz para quando a página muda).
-->
<script setup>
import { computed, onBeforeUnmount, ref, watch } from 'vue'
import { useAjustesStore } from '../../stores/ajustes.js'
import Alerta from '../ui/Alerta.vue'
import Botao from '../ui/Botao.vue'

const props = defineProps({
  recursos: { type: Array, default: () => [] },
  obterTexto: { type: Function, default: null },
  pagina: { type: Number, default: 1 },
})

const ajustes = useAjustesStore()
const suportaVoz = typeof window !== 'undefined' && 'speechSynthesis' in window && 'SpeechSynthesisUtterance' in window

const estado = ref('parado') // 'parado' | 'lendo' | 'pausado'
const aviso = ref('')
let rodada = 0 // cada leitura nova ganha um número; avisos de uma leitura cancelada são ignorados

const statusVoz = computed(
  () => ({ lendo: `Lendo a página ${props.pagina}.`, pausado: 'Leitura pausada.', parado: '' })[estado.value],
)

// O Chrome corta falas longas: a página vira uma fila de trechos de até ~200 caracteres, quebrando em frases
function trechos(texto) {
  const saida = []
  for (const frase of texto.match(/[^.!?]+[.!?]*/g) ?? []) {
    const limpa = frase.trim()
    if (!limpa) continue
    if (saida.length && saida.at(-1).length + limpa.length < 200) saida[saida.length - 1] += ` ${limpa}`
    else saida.push(limpa)
  }
  return saida
}

async function ler() {
  parar()
  const minha = ++rodada
  let texto = ''
  try {
    texto = ((await props.obterTexto()) ?? '').trim()
  } catch {
    aviso.value = 'Não foi possível ler o texto desta página.'
    return
  }
  if (minha !== rodada) return // a pessoa parou ou trocou de página enquanto o texto carregava
  if (!texto) {
    aviso.value = 'Esta página não tem texto para ler em voz alta (pode ser uma imagem).'
    return
  }

  const fila = trechos(texto)
  estado.value = 'lendo'
  fila.forEach((parte, i) => {
    const fala = new SpeechSynthesisUtterance(parte)
    fala.lang = 'pt-BR'
    if (i === fila.length - 1) fala.onend = () => minha === rodada && (estado.value = 'parado')
    fala.onerror = (evento) => {
      if (minha !== rodada || evento.error === 'canceled' || evento.error === 'interrupted') return
      aviso.value = 'Não foi possível ler em voz alta neste navegador.'
      parar()
    }
    window.speechSynthesis.speak(fala)
  })
}

function alternarPausa() {
  if (estado.value === 'lendo') {
    window.speechSynthesis.pause()
    estado.value = 'pausado'
  } else if (estado.value === 'pausado') {
    window.speechSynthesis.resume()
    estado.value = 'lendo'
  }
}

function parar() {
  rodada++
  if (suportaVoz) window.speechSynthesis.cancel()
  estado.value = 'parado'
}

watch(() => props.pagina, parar) // a voz não continua lendo a página que saiu da tela
onBeforeUnmount(parar)
</script>

<template>
  <details class="recursos" :open="ajustes.voz">
    <summary class="recursos-resumo">Recursos de acessibilidade</summary>

    <div class="recursos-corpo">
      <section v-if="obterTexto" class="recursos-voz" aria-labelledby="voz-titulo">
        <h2 id="voz-titulo" class="recursos-titulo">Ler em voz alta</h2>

        <template v-if="suportaVoz">
          <p class="recursos-ajuda">Lê a página atual com a voz do seu navegador. A leitura para quando você troca de página.</p>
          <div class="recursos-acoes">
            <Botao @click="ler">{{ estado === 'parado' ? `Ler a página ${pagina}` : 'Recomeçar a página' }}</Botao>
            <Botao tipo="contorno" :disabled="estado === 'parado'" @click="alternarPausa">
              {{ estado === 'pausado' ? 'Continuar' : 'Pausar' }}
            </Botao>
            <Botao tipo="contorno" :disabled="estado === 'parado'" @click="parar">Parar</Botao>
          </div>
          <p class="recursos-status" role="status">{{ statusVoz }}</p>
        </template>
        <Alerta v-else>Seu navegador não tem leitura em voz alta. Tente o Chrome, o Edge ou o Safari atualizados.</Alerta>

        <Alerta v-if="aviso" tipo="erro">{{ aviso }}</Alerta>
      </section>

      <section v-if="recursos.length" class="recursos-lista" aria-labelledby="declarados-titulo">
        <h2 id="declarados-titulo" class="recursos-titulo">Informado no cadastro deste livro</h2>
        <ul>
          <li v-for="recurso in recursos" :key="recurso.nome">
            <strong>{{ recurso.nome }}</strong>
            <span v-if="recurso.descricao"> — {{ recurso.descricao }}</span>
          </li>
        </ul>
      </section>
    </div>
  </details>
</template>

<style scoped>
.recursos {
  border-radius: var(--raio-20);
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-cartao);
}

.recursos-resumo {
  min-height: 44px;
  padding: var(--espaco-12) var(--espaco-16);
  border-radius: var(--raio-20);
  color: var(--texto-principal);
  font: var(--fonte-botao);
  cursor: pointer;
}

.recursos-resumo:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 2px;
}

.recursos-corpo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-24);
  padding: 0 var(--espaco-16) var(--espaco-16);
}

.recursos-voz,
.recursos-lista {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-12);
}

.recursos-titulo {
  color: var(--texto-principal);
  font: var(--fonte-subtitulo);
}

.recursos-ajuda,
.recursos-lista li {
  color: var(--texto-corpo);
  font: var(--fonte-interface);
}

.recursos-acoes {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-12);
}

.recursos-status {
  min-height: 1.5em; /* não pula o layout quando o texto aparece */
  color: var(--texto-secundario);
  font: var(--fonte-interface);
}

.recursos-lista ul {
  padding-left: var(--espaco-24);
}
</style>
