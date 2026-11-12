<!--
  Vitrine do design system — só existe em desenvolvimento (ver router/index.js).
  Serve para conferir os tokens e cada componente contra o Figma.
  Os valores das cores vêm do próprio tokens.css (lidos no navegador), então
  esta página nunca fica diferente dele.
-->
<script setup>
import { onMounted, ref } from 'vue'
import Botao from '../components/ui/Botao.vue'
import CabecalhoSecao from '../components/ui/CabecalhoSecao.vue'
import CardLivro from '../components/ui/CardLivro.vue'
import CardLivroCarregando from '../components/ui/CardLivroCarregando.vue'
import ChipFiltro from '../components/ui/ChipFiltro.vue'
import Icone from '../components/ui/Icone.vue'
import Selo from '../components/ui/Selo.vue'
import TagFormato from '../components/ui/TagFormato.vue'
import { icones } from '../components/ui/icones.js'
import lamparina from '../images/imgs-baixo-banner/lamparina.png'
import capaJardim from '../images/imgs-livros-destaque/o jardim das pequenas coisas.png'

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

const nomesIcones = Object.keys(icones)
const rotuloIcone = (nome) => nome.charAt(0).toUpperCase() + nome.slice(1).replace('-', ' ')

const tons = ['ceu', 'suave', 'coral', 'laranja', 'rosa']

const coresChip = ['neutro', 'aventura', 'fantasia', 'natureza', 'classicos']
const estadosChip = [
  { nome: 'Padrão' },
  { nome: 'Selecionado', selecionado: true },
  { nome: 'Foco', classe: 'estado-foco' },
]

const categoriasCard = [
  { nome: 'Neutro', categoria: '' },
  { nome: 'Aventura', categoria: 'Aventura' },
  { nome: 'Fantasia', categoria: 'Fantasia' },
  { nome: 'Natureza', categoria: 'Natureza' },
  { nome: 'Clássicos', categoria: 'Clássicos' },
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

    <section aria-labelledby="ds-icones">
      <h2 id="ds-icones">Ícones</h2>
      <p class="vitrine-nota">
        {{ nomesIcones.length }} ícones, 24px, traço 2px, cantos arredondados. Herdam a cor do texto ao redor.
        Sempre acompanhados de texto ou de um rótulo acessível.
      </p>
      <ul class="icones-grade">
        <li v-for="nome in nomesIcones" :key="nome" class="icone-celula">
          <Icone :nome="nome" />
          <span>{{ rotuloIcone(nome) }}</span>
        </li>
      </ul>
      <h3>Tamanhos usados no design</h3>
      <ul class="icones-tamanhos">
        <li v-for="t in [16, 20, 24, 48]" :key="t">
          <Icone nome="livro" :tamanho="t" />
          <span class="cor-valor">{{ t }}px</span>
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

    <section aria-labelledby="ds-selo">
      <h2 id="ds-selo">Selo</h2>
      <p class="vitrine-nota">Rótulo curto em caixa alta acima de títulos de seção e para categorias.</p>
      <ul class="linha-lista">
        <li v-for="tom in tons" :key="tom" class="botao-celula">
          <Selo :tom="tom">Leitura que acolhe</Selo>
          <span class="botao-estado">{{ tom }}</span>
        </li>
      </ul>
    </section>

    <section aria-labelledby="ds-tag">
      <h2 id="ds-tag">Tag de formato</h2>
      <p class="vitrine-nota">Só mostrar formatos que realmente existem para o material.</p>
      <ul class="linha-lista">
        <li class="botao-celula">
          <TagFormato>Texto e audiobook</TagFormato>
          <span class="botao-estado">ícone padrão (fones)</span>
        </li>
        <li class="botao-celula">
          <TagFormato icone="livro">Texto</TagFormato>
          <span class="botao-estado">outro ícone</span>
        </li>
      </ul>
    </section>

    <section aria-labelledby="ds-chip">
      <h2 id="ds-chip">Chip de filtro</h2>
      <p class="vitrine-nota">
        Neutro para filtros gerais; a cor da categoria para categorias de livro. Selecionado sempre mostra o check.
        Clássicos selecionado usa o coral suave por contraste. Aperte Tab para ver o foco.
      </p>
      <div class="chips-grade" role="group" aria-label="Todas as cores e estados do chip">
        <template v-for="cor in coresChip" :key="cor">
          <span class="botoes-tipo">{{ cor }}</span>
          <div v-for="estado in estadosChip" :key="estado.nome" class="botao-celula">
            <ChipFiltro :cor="cor" :selecionado="estado.selecionado" :class="estado.classe">Com audiobook</ChipFiltro>
            <span class="botao-estado">{{ estado.nome }}</span>
          </div>
        </template>
      </div>
    </section>

    <section aria-labelledby="ds-card">
      <h2 id="ds-card">Card de livro</h2>
      <p class="vitrine-nota">
        A categoria define a cor da capa e o selo. Título com até 2 linhas. Cada categoria aparece no estado padrão e
        no estado Foco. O último usa uma capa real, e o título é um link (Tab para focar).
      </p>
      <div class="cards-grade">
        <template v-for="c in categoriasCard" :key="c.nome">
          <CardLivro
            titulo="O jardim das pequenas coisas"
            autor="Clara Ribeiro"
            :categoria="c.categoria"
            formato="Texto e audiobook"
          />
          <CardLivro
            class="estado-foco"
            titulo="O jardim das pequenas coisas"
            autor="Clara Ribeiro"
            :categoria="c.categoria"
            formato="Texto e audiobook"
          />
        </template>
        <CardLivro
          titulo="O jardim das pequenas coisas"
          autor="Clara Ribeiro"
          categoria="Natureza"
          :capa-url="capaJardim"
          formato="Texto e audiobook"
          to="/design-system"
        />
      </div>
      <h3>Carregando</h3>
      <div class="cards-grade" aria-busy="true">
        <CardLivroCarregando />
      </div>
    </section>

    <section aria-labelledby="ds-cabecalho-secao">
      <h2 id="ds-cabecalho-secao">Cabeçalho de seção</h2>
      <p class="vitrine-nota">Abre cada seção de conteúdo. A ilustração é decorativa (alt vazio).</p>
      <div class="cabecalhos-lista">
        <CabecalhoSecao titulo="Livros em destaque" subtitulo="Uma boa história pode ser seu próximo começo.">
          <template #ilustracao><img :src="lamparina" alt=""></template>
        </CabecalhoSecao>
        <CabecalhoSecao titulo="Novidades no acervo" subtitulo="Livros que acabaram de chegar no cantinho." />
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

/* Ícones */
.icones-grade {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-24);
  margin-top: var(--espaco-24);
}

.icone-celula {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--espaco-8);
  width: 104px;
  padding: var(--espaco-16) var(--espaco-12);
  border-radius: var(--raio-12);
  background: var(--fundo-superficie);
  color: var(--texto-principal);
}

.icone-celula span {
  font: var(--fonte-legenda);
  color: var(--texto-secundario);
  text-align: center;
}

.icones-tamanhos {
  display: flex;
  align-items: flex-end;
  gap: var(--espaco-24);
  color: var(--texto-principal);
}

.icones-tamanhos li {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--espaco-8);
}

/* Selo, tag, chip, cards, cabeçalho */
.linha-lista {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-24);
  margin-top: var(--espaco-24);
}

.chips-grade {
  display: grid;
  grid-template-columns: 96px repeat(3, max-content);
  align-items: center;
  gap: var(--espaco-24);
  margin-top: var(--espaco-24);
  overflow-x: auto;
  padding: var(--espaco-8) 0;
}

.cards-grade {
  display: grid;
  grid-template-columns: repeat(auto-fill, 272px);
  gap: var(--espaco-24);
  margin-top: var(--espaco-24);
}

.cabecalhos-lista {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-32);
  margin-top: var(--espaco-24);
}
</style>
