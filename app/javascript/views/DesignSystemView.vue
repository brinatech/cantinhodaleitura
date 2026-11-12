<!--
  Vitrine do design system — só existe em desenvolvimento (ver router/index.js).
  Serve para conferir os tokens e cada componente contra o Figma.
  Os valores das cores vêm do próprio tokens.css (lidos no navegador), então
  esta página nunca fica diferente dele.
-->
<script setup>
import { onMounted, ref } from 'vue'
import Botao from '../components/ui/Botao.vue'

const grupos = [
  { titulo: 'Texto', nomes: ['texto-principal', 'texto-corpo', 'texto-secundario', 'texto-inverso', 'texto-erro'] },
  { titulo: 'Fundos', nomes: ['fundo-pagina', 'fundo-superficie', 'fundo-suave', 'fundo-nuvem'] },
  { titulo: 'Bordas', nomes: ['borda-padrao', 'borda-forte', 'borda-foco', 'borda-erro'] },
  { titulo: 'Destaques', nomes: ['destaque-ceu', 'destaque-escuro', 'destaque-laranja'] },
  { titulo: 'Apoio', nomes: ['apoio-coral', 'apoio-coral-suave', 'apoio-laranja', 'apoio-laranja-suave', 'apoio-rosa', 'apoio-rosa-suave'] },
  {
    titulo: 'Categorias',
    nomes: [
      'categoria-aventura', 'categoria-aventura-suave', 'categoria-fantasia', 'categoria-fantasia-suave',
      'categoria-natureza', 'categoria-natureza-suave', 'categoria-classicos', 'categoria-classicos-suave',
    ],
  },
]

const fontes = [
  'display', 'titulo', 'titulo-cartao', 'subtitulo', 'leitura', 'corpo', 'interface', 'botao', 'legenda', 'rotulo', 'selo',
]
const letras = { rotulo: 'var(--letras-rotulo)', selo: 'var(--letras-selo)' }
const caixaAlta = ['rotulo', 'selo']

const espacos = [4, 8, 12, 16, 24, 32, 48, 64]
const raios = ['8', '12', '20', '40', 'total']
const sombras = ['cartao', 'flutuante']

const tipos = ['principal', 'escuro', 'contorno', 'destaque']
const estados = [
  { nome: 'Padrão' },
  { nome: 'Hover', classe: 'estado-hover' },
  { nome: 'Foco', classe: 'estado-foco' },
  { nome: 'Desabilitado', desabilitado: true },
]

// Lê o valor real de cada variável do tokens.css para mostrar o hex ao lado da cor
const valores = ref({})
onMounted(() => {
  const css = getComputedStyle(document.documentElement)
  for (const grupo of grupos) {
    for (const nome of grupo.nomes) valores.value[nome] = css.getPropertyValue(`--${nome}`).trim()
  }
})
</script>

<template>
  <main class="vitrine">
    <header class="vitrine-topo">
      <p class="vitrine-rotulo">Design system · só em desenvolvimento</p>
      <h1>Cantinho da Leitura</h1>
      <p class="vitrine-intro">
        Tokens e componentes como estão no Figma. O que aparece aqui vem do
        <code>styles/tokens.css</code> e de <code>components/ui/</code>.
      </p>
    </header>

    <section aria-labelledby="ds-cores">
      <h2 id="ds-cores">Cores</h2>
      <div v-for="grupo in grupos" :key="grupo.titulo" class="cores-grupo">
        <h3>{{ grupo.titulo }}</h3>
        <ul class="cores-lista">
          <li v-for="nome in grupo.nomes" :key="nome" class="cor">
            <span class="cor-amostra" :style="{ background: `var(--${nome})` }"></span>
            <span class="cor-nome">--{{ nome }}</span>
            <span class="cor-valor">{{ valores[nome] }}</span>
          </li>
        </ul>
      </div>
    </section>

    <section aria-labelledby="ds-tipografia">
      <h2 id="ds-tipografia">Tipografia</h2>
      <ul class="fontes-lista">
        <li v-for="nome in fontes" :key="nome" class="fonte">
          <code>--fonte-{{ nome }}</code>
          <span
            class="fonte-amostra"
            :style="{
              font: `var(--fonte-${nome})`,
              letterSpacing: letras[nome],
              textTransform: caixaAlta.includes(nome) ? 'uppercase' : 'none',
            }"
          >{{ nome === 'leitura' ? 'Era uma vez um cantinho cheio de histórias.' : 'Um mundo de histórias' }}</span>
        </li>
      </ul>
    </section>

    <section aria-labelledby="ds-medidas">
      <h2 id="ds-medidas">Espaçamento, raio e sombra</h2>
      <h3>Espaçamento</h3>
      <ul class="espacos-lista">
        <li v-for="n in espacos" :key="n">
          <code>--espaco-{{ n }}</code>
          <span class="espaco-barra" :style="{ width: `var(--espaco-${n})` }"></span>
          <span class="cor-valor">{{ n }}px</span>
        </li>
      </ul>
      <h3>Raio</h3>
      <ul class="caixas-lista">
        <li v-for="r in raios" :key="r">
          <span class="caixa" :style="{ borderRadius: `var(--raio-${r})` }"></span>
          <code>--raio-{{ r }}</code>
        </li>
      </ul>
      <h3>Sombra</h3>
      <ul class="caixas-lista">
        <li v-for="s in sombras" :key="s">
          <span class="caixa caixa-sombra" :style="{ boxShadow: `var(--sombra-${s})` }"></span>
          <code>--sombra-{{ s }}</code>
        </li>
      </ul>
    </section>

    <section aria-labelledby="ds-botao">
      <h2 id="ds-botao">Botão</h2>
      <p class="vitrine-nota">
        Destaque (laranja) só para ações divertidas, no máximo um por tela. Use o estado Foco com
        navegação por teclado: aperte Tab nos botões abaixo.
      </p>
      <div class="botoes-grade" role="group" aria-label="Todos os tipos e estados do botão">
        <template v-for="tipo in tipos" :key="tipo">
          <span class="botoes-tipo">{{ tipo }}</span>
          <div v-for="estado in estados" :key="estado.nome" class="botao-celula">
            <Botao :tipo="tipo" :class="estado.classe" :disabled="estado.desabilitado">Explorar o acervo</Botao>
            <span class="botao-estado">{{ estado.nome }}</span>
          </div>
        </template>
      </div>
    </section>
  </main>
</template>

<style scoped>
.vitrine {
  max-width: 1200px;
  margin: 0 auto;
  padding: var(--espaco-48) var(--espaco-32) var(--espaco-64);
  background: var(--fundo-pagina);
  color: var(--texto-corpo);
  font: var(--fonte-interface);
}

.vitrine section {
  margin-top: var(--espaco-64);
}

h1 {
  font: var(--fonte-display);
  color: var(--texto-principal);
}

h2 {
  padding-bottom: var(--espaco-8);
  border-bottom: 1px solid var(--borda-padrao);
  font: var(--fonte-titulo);
  color: var(--texto-principal);
}

h3 {
  margin: var(--espaco-24) 0 var(--espaco-12);
  font: var(--fonte-subtitulo);
  color: var(--texto-principal);
}

code {
  font-size: 0.875rem;
  color: var(--texto-secundario);
}

ul {
  list-style: none;
}

.vitrine-rotulo {
  font: var(--fonte-rotulo);
  letter-spacing: var(--letras-rotulo);
  text-transform: uppercase;
  color: var(--texto-secundario);
}

.vitrine-intro,
.vitrine-nota {
  margin-top: var(--espaco-8);
  color: var(--texto-secundario);
}

/* Cores */
.cores-lista {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(190px, 1fr));
  gap: var(--espaco-16);
}

.cor {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-4);
}

.cor-amostra {
  height: 56px;
  border: 1px solid var(--borda-padrao);
  border-radius: var(--raio-8);
}

.cor-nome {
  font: var(--fonte-legenda);
  color: var(--texto-principal);
}

.cor-valor {
  font: var(--fonte-legenda);
  color: var(--texto-secundario);
}

/* Tipografia */
.fonte {
  display: grid;
  grid-template-columns: 190px 1fr;
  align-items: baseline;
  gap: var(--espaco-16);
  padding: var(--espaco-12) 0;
  border-bottom: 1px solid var(--borda-padrao);
}

.fonte-amostra {
  color: var(--texto-principal);
}

/* Medidas */
.espacos-lista li {
  display: grid;
  grid-template-columns: 190px 64px 60px;
  align-items: center;
  gap: var(--espaco-16);
  padding: var(--espaco-4) 0;
}

.espaco-barra {
  height: 16px;
  background: var(--destaque-ceu);
  border-radius: var(--raio-total);
}

.caixas-lista {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-24);
}

.caixas-lista li {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
}

.caixa {
  width: 96px;
  height: 96px;
  background: var(--destaque-ceu);
}

.caixa-sombra {
  background: var(--fundo-superficie);
  border: 0;
  border-radius: var(--raio-20);
}

/* Botões */
.botoes-grade {
  display: grid;
  grid-template-columns: 96px repeat(4, max-content);
  align-items: center;
  gap: var(--espaco-24);
  margin-top: var(--espaco-24);
  overflow-x: auto;
  padding-bottom: var(--espaco-8);
}

.botoes-tipo {
  font: var(--fonte-rotulo);
  letter-spacing: var(--letras-rotulo);
  text-transform: uppercase;
  color: var(--texto-secundario);
}

.botao-celula {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-4);
}

.botao-estado {
  font: var(--fonte-legenda);
  color: var(--texto-secundario);
}
</style>
