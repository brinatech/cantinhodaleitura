<!--
  Painel "Ajustes de leitura" (Figma: "Painel de acessibilidade"). Abre com
  abrir() (o LayoutLogado chama pelo botão Acessibilidade). É um <dialog> nativo
  (showModal): o foco fica preso dentro, Esc fecha e o foco volta ao botão.
  Os valores ficam no store de ajustes e valem no site todo, salvos no navegador.
  "Ler em voz alta" só guarda a preferência: a leitura em voz vem com o leitor.
-->
<script setup>
import { ref } from 'vue'
import { useAjustesStore } from '../../stores/ajustes.js'
import Botao from '../ui/Botao.vue'
import ChipFiltro from '../ui/ChipFiltro.vue'
import Icone from '../ui/Icone.vue'
import IconeBolha from '../ui/IconeBolha.vue'
import Interruptor from '../ui/Interruptor.vue'

const ajustes = useAjustesStore()
const dialogo = ref(null)

const tamanhos = [
  { valor: 'normal', texto: 'A' },
  { valor: 'grande', texto: 'A+' },
  { valor: 'maior', texto: 'A++' },
]
const linhas = [
  { valor: 'normal', texto: 'Normal' },
  { valor: 'amplo', texto: 'Amplo' },
]
// Tema escuro: TESTE, sem Figma (styles/tema-escuro.css)
const temas = [
  { valor: 'claro', texto: 'Claro' },
  { valor: 'escuro', texto: 'Escuro' },
]

const abrir = () => dialogo.value.showModal()
const fechar = () => dialogo.value.close()
// Clicar no fundo escurecido (que é o próprio <dialog>, fora do conteúdo) fecha
const cliqueNoFundo = (evento) => evento.target === dialogo.value && fechar()

defineExpose({ abrir })
</script>

<template>
  <dialog ref="dialogo" class="painel" aria-labelledby="painel-titulo" @click="cliqueNoFundo">
    <div class="painel-conteudo">
      <header class="painel-topo">
        <h2 id="painel-titulo" class="painel-titulo">
          <IconeBolha icone="acessibilidade" :tamanho="40" :tamanho-icone="24" />
          Ajustes de leitura
        </h2>
        <button type="button" class="painel-fechar" aria-label="Fechar ajustes" @click="fechar">
          <Icone nome="fechar" :tamanho="20" />
        </button>
      </header>

      <div class="painel-grupo" role="group" aria-labelledby="painel-tamanho">
        <p id="painel-tamanho" class="painel-rotulo">Tamanho do texto</p>
        <div class="painel-opcoes">
          <ChipFiltro v-for="opcao in tamanhos" :key="opcao.valor" :selecionado="ajustes.tamanho === opcao.valor" @click="ajustes.tamanho = opcao.valor">
            {{ opcao.texto }}
          </ChipFiltro>
        </div>
      </div>

      <div class="painel-grupo" role="group" aria-labelledby="painel-linhas">
        <p id="painel-linhas" class="painel-rotulo">Espaço entre linhas</p>
        <div class="painel-opcoes">
          <ChipFiltro v-for="opcao in linhas" :key="opcao.valor" :selecionado="ajustes.linhas === opcao.valor" @click="ajustes.linhas = opcao.valor">
            {{ opcao.texto }}
          </ChipFiltro>
        </div>
      </div>

      <div class="painel-grupo" role="group" aria-labelledby="painel-tema">
        <p id="painel-tema" class="painel-rotulo">Tema</p>
        <div class="painel-opcoes">
          <ChipFiltro v-for="opcao in temas" :key="opcao.valor" :selecionado="ajustes.tema === opcao.valor" @click="ajustes.tema = opcao.valor">
            {{ opcao.texto }}
          </ChipFiltro>
        </div>
      </div>

      <hr class="painel-divisor">

      <Interruptor v-model="ajustes.voz" rotulo="Ler em voz alta" descricao="Lê o texto da página para você." />
      <Interruptor v-model="ajustes.contraste" rotulo="Alto contraste" descricao="Reforça cores e bordas." />
      <Interruptor v-model="ajustes.calmo" rotulo="Modo calmo" descricao="Menos cores e nenhuma animação." />

      <Botao tipo="contorno" @click="ajustes.restaurar()">
        <template #icone><Icone nome="restaurar" /></template>
        Restaurar padrão
      </Botao>

      <p class="painel-nota">Os ajustes ficam salvos neste navegador.</p>
    </div>
  </dialog>
</template>

<style scoped>
/* Fundo escurecido do Figma ("Escurecer fundo") */
.painel::backdrop {
  background: color-mix(in srgb, var(--texto-corpo) 40%, transparent);
}

.painel {
  position: fixed;
  inset: 93px 135px auto auto; /* posição do Figma: abaixo da barra, perto do botão */
  width: 384px;
  max-width: calc(100vw - 32px);
  max-height: calc(100vh - 109px);
  margin: 0;
  padding: 0;
  overflow-y: auto;
  border: 1px solid var(--borda-padrao);
  border-radius: 24px;
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-flutuante);
  color: var(--texto-corpo);
}

.painel-conteudo {
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding: var(--espaco-24);
}

.painel-topo {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.painel-titulo {
  display: flex;
  align-items: center;
  gap: 10px;
  color: var(--texto-principal);
  font: var(--fonte-subtitulo);
}

.painel-fechar {
  display: inline-flex;
  padding: var(--espaco-8);
  border: 1.5px solid var(--borda-padrao);
  border-radius: var(--raio-total);
  background: transparent;
  color: var(--texto-principal);
  cursor: pointer;
  transition: transform var(--duracao-rapida) var(--curva), background-color var(--duracao-rapida) var(--curva);
}

.painel-fechar:hover {
  transform: scale(var(--crescer));
  background: var(--camada-hover);
}

.painel-fechar:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 2px;
}

.painel-grupo {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.painel-rotulo {
  color: var(--texto-principal);
  font: var(--fonte-botao);
}

.painel-opcoes {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-8);
}

.painel-divisor {
  height: 1px;
  border: 0;
  background: var(--borda-padrao);
}

.painel-nota {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
  text-align: center;
}

/* Celular: o painel vira uma folha ancorada embaixo, na largura toda */
@media (max-width: 640px) {
  .painel {
    inset: auto 0 0;
    width: 100%;
    max-width: none;
    max-height: 90vh;
    border-radius: 24px 24px 0 0;
  }
}
</style>
