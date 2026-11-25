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
import AbasAcesso from '../components/ui/AbasAcesso.vue'
import Alerta from '../components/ui/Alerta.vue'
import BarraLeitor from '../components/ui/BarraLeitor.vue'
import BarraProgresso from '../components/ui/BarraProgresso.vue'
import BlocoCategoria from '../components/ui/BlocoCategoria.vue'
import CampoBusca from '../components/ui/CampoBusca.vue'
import CampoFormulario from '../components/ui/CampoFormulario.vue'
import CardContinuarLendo from '../components/ui/CardContinuarLendo.vue'
import DestaquePalavra from '../components/ui/DestaquePalavra.vue'
import DivisorOnda from '../components/ui/DivisorOnda.vue'
import EstadoVazio from '../components/ui/EstadoVazio.vue'
import IconeBolha from '../components/ui/IconeBolha.vue'
import IndicadorBanner from '../components/ui/IndicadorBanner.vue'
import Interruptor from '../components/ui/Interruptor.vue'
import ItemMenuLateral from '../components/ui/ItemMenuLateral.vue'
import PlayerAudio from '../components/ui/PlayerAudio.vue'
import SeloConquista from '../components/ui/SeloConquista.vue'
import MenuSuperior from '../components/layout/MenuSuperior.vue'
import Rodape from '../components/layout/Rodape.vue'
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
      'categoria-infantil', 'categoria-infantil-suave', 'categoria-poesia', 'categoria-poesia-suave',
      'categoria-ciencias', 'categoria-ciencias-suave',
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

const coresChip = ['neutro', 'aventura', 'fantasia', 'natureza', 'classicos', 'infantil', 'poesia', 'ciencias']
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

// Estados de demonstração dos componentes novos (para testar clicando e digitando)
const busca = ref('')
const aba = ref('entrar')
const leituraLigada = ref(true)
const contrasteLigado = ref(false)
const bannerAtivo = ref(1)

const bolhas = ['ceu', 'laranja', 'rosa', 'coral', 'suave']
const blocos = [
  { categoria: 'Aventura', quantidade: '12 livros' },
  { categoria: 'Fantasia', quantidade: '9 livros' },
  { categoria: 'Natureza', quantidade: '7 livros' },
  { categoria: 'Clássicos', quantidade: '15 livros' },
]
const ondas = ['nuvem', 'laranja-suave', 'rosa-suave', 'pagina', 'superficie']

const velocidades = ['1x', '1.25x', '1.5x', '0.75x']
const players = ref([
  { tocando: false, tempo: 72, velocidade: '1x' }, // Pausado (1:12)
  { tocando: true, tempo: 155, velocidade: '1x' }, // Reproduzindo (2:35)
])
const trocarVelocidade = (player) => {
  player.velocidade = velocidades[(velocidades.indexOf(player.velocidade) + 1) % velocidades.length]
}

const linksDemo = [
  { texto: 'Início', to: '/design-system' },
  { texto: 'Sobre', to: '/design-system' },
  { texto: 'Acervo', to: '/design-system' },
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

    <!-- ===== Formulários e navegação ===== -->
    <section aria-labelledby="ds-campo-busca">
      <h2 id="ds-campo-busca">Campo de busca</h2>
      <p class="vitrine-nota">Busca do acervo. Sempre com nome acessível. Digite para testar e aperte Tab para ver o foco.</p>
      <div class="coluna">
        <div class="botao-celula">
          <CampoBusca v-model="busca" />
          <span class="botao-estado">Padrão (digitando: “{{ busca }}”)</span>
        </div>
        <div class="botao-celula">
          <CampoBusca class="estado-foco" />
          <span class="botao-estado">Foco</span>
        </div>
      </div>
    </section>

    <section aria-labelledby="ds-campo-formulario">
      <h2 id="ds-campo-formulario">Campo de formulário</h2>
      <p class="vitrine-nota">Erro sempre com ícone e texto, ligado ao campo por aria-describedby.</p>
      <div class="coluna">
        <div class="botao-celula">
          <CampoFormulario label="E-mail" type="email" placeholder="seu@email.com" ajuda="Usaremos só para entrar na sua conta." />
          <span class="botao-estado">Padrão</span>
        </div>
        <div class="botao-celula">
          <CampoFormulario class="estado-foco" label="E-mail" type="email" placeholder="seu@email.com" ajuda="Usaremos só para entrar na sua conta." />
          <span class="botao-estado">Foco</span>
        </div>
        <div class="botao-celula">
          <CampoFormulario label="E-mail" type="email" placeholder="seu@email.com" erro="Digite um e-mail válido, como nome@email.com." />
          <span class="botao-estado">Erro</span>
        </div>
      </div>
    </section>

    <section aria-labelledby="ds-menu-lateral">
      <h2 id="ds-menu-lateral">Item de menu lateral</h2>
      <p class="vitrine-nota">Navegação do “Meu espaço”. Cada item tem o seu ícone.</p>
      <div class="coluna coluna--240">
        <div class="botao-celula"><ItemMenuLateral icone="livro">Minhas leituras</ItemMenuLateral><span class="botao-estado">Padrão</span></div>
        <div class="botao-celula"><ItemMenuLateral icone="livro" ativo>Minhas leituras</ItemMenuLateral><span class="botao-estado">Ativo</span></div>
        <div class="botao-celula"><ItemMenuLateral icone="livro" class="estado-foco">Minhas leituras</ItemMenuLateral><span class="botao-estado">Foco</span></div>
      </div>
    </section>

    <section aria-labelledby="ds-alerta">
      <h2 id="ds-alerta">Alerta</h2>
      <p class="vitrine-nota">Info e sucesso usam role="status"; erro usa role="alert".</p>
      <div class="coluna coluna--520">
        <Alerta tipo="info">Seu progresso é salvo automaticamente.</Alerta>
        <Alerta tipo="sucesso">Livro adicionado aos favoritos.</Alerta>
        <Alerta tipo="erro">Não foi possível entrar. Confira seu e-mail e senha.</Alerta>
      </div>
    </section>

    <section aria-labelledby="ds-abas">
      <h2 id="ds-abas">Abas de acesso</h2>
      <p class="vitrine-nota">Alterna entre Entrar e Criar conta. Clique ou use as setas. Aba atual: <strong>{{ aba }}</strong>.</p>
      <div class="coluna coluna--400"><AbasAcesso v-model="aba" /></div>
    </section>

    <section aria-labelledby="ds-interruptor">
      <h2 id="ds-interruptor">Interruptor</h2>
      <p class="vitrine-nota">Ligado mostra a marca de check além da cor. Clique para alternar.</p>
      <div class="coluna coluna--312">
        <Interruptor v-model="leituraLigada" rotulo="Ler em voz alta" descricao="Lê o texto da página para você." />
        <Interruptor v-model="contrasteLigado" rotulo="Alto contraste" descricao="Deixa as cores mais fortes." />
      </div>
    </section>

    <section aria-labelledby="ds-indicador">
      <h2 id="ds-indicador">Indicador do banner</h2>
      <p class="vitrine-nota">Pontos do banner da home, feitos para ficar sobre a imagem. O último é clicável (slide {{ bannerAtivo + 1 }}).</p>
      <div class="fundo-escuro">
        <IndicadorBanner :ativo="0" />
        <IndicadorBanner :ativo="1" />
        <IndicadorBanner :ativo="2" />
        <IndicadorBanner :ativo="bannerAtivo" @ir="bannerAtivo = $event" />
      </div>
    </section>

    <section aria-labelledby="ds-vazio">
      <h2 id="ds-vazio">Estado vazio</h2>
      <p class="vitrine-nota">Busca sem resultado, favoritos vazios, histórico vazio e erro de carregamento: troque título e descrição.</p>
      <div class="cabecalhos-lista">
        <EstadoVazio titulo="Nenhum livro encontrado" descricao="Tente outra palavra ou remova algum filtro.">
          <template #acao><Botao tipo="contorno">Limpar filtros</Botao></template>
        </EstadoVazio>
      </div>
    </section>

    <!-- ===== Decorativos ===== -->
    <section aria-labelledby="ds-bolha">
      <h2 id="ds-bolha">Ícone em bolha</h2>
      <p class="vitrine-nota">Ícone dentro de um círculo colorido, estilo adesivo. O ícone é sempre azul escuro.</p>
      <ul class="linha-lista">
        <li v-for="cor in bolhas" :key="cor" class="botao-celula">
          <IconeBolha :cor="cor" />
          <span class="botao-estado">{{ cor }}</span>
        </li>
        <li class="botao-celula"><IconeBolha cor="laranja" icone="fones" :tamanho="36" /><span class="botao-estado">36px</span></li>
        <li class="botao-celula"><IconeBolha cor="rosa" icone="estrela" :tamanho="40" /><span class="botao-estado">40px</span></li>
      </ul>
    </section>

    <section aria-labelledby="ds-bloco">
      <h2 id="ds-bloco">Bloco de categoria</h2>
      <p class="vitrine-nota">Atalho “Explorar por categoria”. Cada categoria tem cor e ícone próprios.</p>
      <div class="cards-grade">
        <BlocoCategoria v-for="b in blocos" :key="b.categoria" :categoria="b.categoria" :quantidade="b.quantidade" to="/design-system" />
      </div>
    </section>

    <section aria-labelledby="ds-destaque">
      <h2 id="ds-destaque">Destaque de palavra</h2>
      <p class="vitrine-nota">Marca-texto atrás de uma palavra do título. No máximo uma vez por seção.</p>
      <div class="cabecalhos-lista">
        <p class="exemplo-titulo">Vamos continuar uma <DestaquePalavra>história</DestaquePalavra>?</p>
        <p class="exemplo-titulo">Entrar no seu <DestaquePalavra cor="laranja">cantinho</DestaquePalavra></p>
        <p class="exemplo-titulo">Encontre sua próxima <DestaquePalavra cor="ceu">leitura</DestaquePalavra></p>
      </div>
    </section>

    <section aria-labelledby="ds-onda">
      <h2 id="ds-onda">Divisor de onda</h2>
      <p class="vitrine-nota">Transição entre seções, com a cor da PRÓXIMA seção. Decorativo. Aqui sobre fundo escuro para dar para ver a cor.</p>
      <div class="cabecalhos-lista">
        <div v-for="cor in ondas" :key="cor" class="onda-demo">
          <DivisorOnda :cor="cor" />
          <span class="botao-estado">{{ cor }}</span>
        </div>
      </div>
    </section>

    <section aria-labelledby="ds-conquista">
      <h2 id="ds-conquista">Selo de conquista</h2>
      <p class="vitrine-nota">Proposta do design, ainda não aprovada pela equipe (não está nos requisitos). Bloqueado mostra o que falta, sem punir.</p>
      <ul class="linha-lista">
        <li><SeloConquista cor="laranja" nome="Explorador" descricao="3 livros lidos" /></li>
        <li><SeloConquista cor="rosa" nome="Ouvinte" descricao="2h de audiobook" /></li>
        <li><SeloConquista cor="coral" nome="Aventureiro" descricao="5 livros lidos" /></li>
        <li><SeloConquista cor="bloqueado" nome="Maratonista" descricao="Leia 10 livros" /></li>
      </ul>
    </section>

    <!-- ===== Leitura ===== -->
    <section aria-labelledby="ds-progresso">
      <h2 id="ds-progresso">Barra de progresso</h2>
      <p class="vitrine-nota">Gradiente laranja → coral, de 0 a 100. Tem role="progressbar" com aria-valuenow.</p>
      <div class="progresso-grade">
        <BarraProgresso v-for="n in 10" :key="n" rotulo="Seu progresso" :valor="`${n * 10}%`" :progresso="n * 10" />
      </div>
    </section>

    <section aria-labelledby="ds-continuar">
      <h2 id="ds-continuar">Card continuar lendo</h2>
      <p class="vitrine-nota">Texto usa o botão Principal; Audiobook usa o Destaque. A cor da capa vem da categoria.</p>
      <div class="coluna coluna--860">
        <CardContinuarLendo
          titulo="Caminhos de casa"
          detalhe="Pedro Almeida · Capítulo 3 · O atalho do rio"
          categoria="Aventura"
          :progresso="45"
          rotulo-progresso="Página 12 de 28"
        />
        <CardContinuarLendo
          formato="audiobook"
          titulo="A menina que conversava com a Lua"
          detalhe="Ana Martins · Capítulo 5 · A noite clara"
          categoria="Fantasia"
          :progresso="65"
          rotulo-progresso="4 min restantes"
        />
      </div>
      <h3>Vertical</h3>
      <div class="cards-grade cards-grade--340">
        <CardContinuarLendo
          layout="vertical"
          titulo="Caminhos de casa"
          detalhe="Pedro Almeida · Capítulo 3 · O atalho do rio"
          categoria="Aventura"
          :progresso="45"
          rotulo-progresso="Página 12 de 28"
        />
        <CardContinuarLendo
          layout="vertical"
          formato="audiobook"
          titulo="A menina que conversava com a Lua"
          detalhe="Ana Martins · Capítulo 5 · A noite clara"
          categoria="Fantasia"
          :progresso="65"
          rotulo-progresso="4 min restantes"
        />
      </div>
    </section>

    <section aria-labelledby="ds-player">
      <h2 id="ds-player">Player de áudio</h2>
      <p class="vitrine-nota">
        Pausado e Reproduzindo. Só a interface: o estado é daqui da vitrine, sem áudio de verdade.
        Teste os botões e a barra (clique, ou Tab e setas).
      </p>
      <div class="coluna coluna--640">
        <PlayerAudio
          v-for="(p, i) in players"
          :key="i"
          titulo="O jardim das pequenas coisas"
          capitulo="Capítulo 1 · Um pequeno começo"
          :tocando="p.tocando"
          :tempo-atual="p.tempo"
          :duracao="368"
          :velocidade="p.velocidade"
          @alternar="p.tocando = !p.tocando"
          @voltar10="p.tempo = Math.max(0, p.tempo - 10)"
          @avancar10="p.tempo = Math.min(368, p.tempo + 10)"
          @buscar="p.tempo = $event"
          @velocidade="trocarVelocidade(p)"
        />
      </div>
    </section>

    <section aria-labelledby="ds-leitor">
      <h2 id="ds-leitor">Barra do leitor</h2>
      <p class="vitrine-nota">Ações do leitor de texto: voltar, ajustar texto, ouvir e salvar marcador.</p>
      <div class="linha-lista"><BarraLeitor pagina="Página 1 de 2" /></div>
    </section>

    <!-- ===== Layout ===== -->
    <section aria-labelledby="ds-menu-superior">
      <h2 id="ds-menu-superior">Menu superior</h2>
      <p class="vitrine-nota">Visitante mostra “Entrar”; leitor logado mostra “Meu espaço”.</p>
      <div class="cabecalhos-lista">
        <div class="moldura"><MenuSuperior :links="linksDemo" acao-para="/design-system" /><span class="botao-estado">Visitante</span></div>
        <div class="moldura">
          <MenuSuperior leitor :links="[{ texto: 'Início', to: '/design-system' }, { texto: 'Acervo', to: '/design-system' }, { texto: 'Acessibilidade', to: '/design-system' }]" acao-para="/design-system" />
          <span class="botao-estado">Leitor</span>
        </div>
      </div>
    </section>

    <section aria-labelledby="ds-rodape">
      <h2 id="ds-rodape">Rodapé</h2>
      <p class="vitrine-nota">Rodapé padrão das páginas públicas. A ilustração lateral da home fica fora do componente.</p>
      <div class="moldura"><Rodape /></div>
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

.vitrine > section {
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

/* Componentes de formulário, navegação, leitura e layout */
.coluna {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-24);
  max-width: 420px;
  margin-top: var(--espaco-24);
}

.coluna--240 { max-width: 240px; }
.coluna--312 { max-width: 312px; }
.coluna--400 { max-width: 400px; }
.coluna--520 { max-width: 520px; }
.coluna--640 { max-width: 640px; }
.coluna--860 { max-width: 860px; }

.fundo-escuro {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: var(--espaco-32);
  margin-top: var(--espaco-24);
  padding: var(--espaco-24);
  border-radius: var(--raio-20);
  background: var(--destaque-escuro);
}

.exemplo-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.onda-demo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-4);
}

.onda-demo > :first-child {
  padding-top: var(--espaco-24);
  background: var(--destaque-escuro);
}

.progresso-grade {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 400px));
  gap: var(--espaco-24);
  margin-top: var(--espaco-24);
}

.cards-grade--340 {
  grid-template-columns: repeat(auto-fill, 340px);
}

.moldura {
  overflow: hidden;
  border: 1px solid var(--borda-padrao);
  border-radius: var(--raio-12);
}

.moldura > .botao-estado {
  display: block;
  padding: var(--espaco-8) var(--espaco-16);
}
</style>
