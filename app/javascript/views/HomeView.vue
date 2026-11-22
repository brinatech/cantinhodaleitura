<!--
  Tela inicial (Figma: "Wireframe - 1"). Só monta componentes do design system;
  aqui ficam o posicionamento das seções e das ilustrações.
-->
<script setup>
import { onMounted, ref } from 'vue'
import BannerCarrossel from '../components/BannerCarrossel.vue'
import MenuSuperior from '../components/layout/MenuSuperior.vue'
import Rodape from '../components/layout/Rodape.vue'
import Botao from '../components/ui/Botao.vue'
import CabecalhoSecao from '../components/ui/CabecalhoSecao.vue'
import CardLivro from '../components/ui/CardLivro.vue'
import Icone from '../components/ui/Icone.vue'
import Selo from '../components/ui/Selo.vue'
import { temAudio, textoFormato } from '../components/livros/formatos.js'
import { listarLivros } from '../services/livrosService.js'
import coruja from '../images/imgs-livros-destaque/coruja.png'
import lamparina from '../images/imgs-baixo-banner/lamparina.png'
import garotaComFone from '../images/imgs-baixo-banner/garota-com-fone.png'
import nuvem from '../images/imgs-baixo-banner/nuvem.png'
import nuvemRoxa from '../images/imgs-baixo-banner/nuvem-roxa.png'
import nuvemArcoiris from '../images/imgs-baixo-banner/nuvem-arcoiris.png'
import arcoIrisEstrela from '../images/imgs-baixo-banner/arco-iris-estrela.png'
import fundoChamada from '../images/imgs-cima-footer/fundo-cima-footer.png'
import nuvemRodape from '../images/imgs-footer/nuvem-footer.png'
import livroRodape from '../images/imgs-footer/livro.png'
import garotoRodape from '../images/imgs-footer/garoto-cadeira.png'

// Livros em destaque: os 5 mais lidos do acervo (leituras registradas pela HU-10 Task 3).
// Sem leituras ainda (acervo novo), a API completa com os mais recentes.
// Se a API falhar, a seção some e a home continua (o botão "Explorar acervo" fica).
const livrosDestaque = ref([])
const carregandoDestaque = ref(true)

onMounted(async () => {
  try {
    livrosDestaque.value = (await listarLivros({ ordem: 'mais_lidos' })).slice(0, 5)
  } catch {
    livrosDestaque.value = []
  } finally {
    carregandoDestaque.value = false
  }
})
</script>

<template>
  <div class="pagina">
    <MenuSuperior class="menu-sobre-banner" sobre-banner />

    <main>
      <BannerCarrossel />

      <section class="apresentacao" aria-labelledby="titulo-apresentacao">
        <!-- Decorações (escondidas de leitores de tela) -->
        <img class="deco deco-nuvem" :src="nuvem" alt="" aria-hidden="true">
        <img class="deco deco-nuvem-roxa" :src="nuvemRoxa" alt="" aria-hidden="true">
        <img class="deco deco-nuvem-arcoiris" :src="nuvemArcoiris" alt="" aria-hidden="true">
        <img class="deco deco-estrela" :src="arcoIrisEstrela" alt="" aria-hidden="true">

        <!-- v-aparecer: cada bloco aparece ao entrar na tela rolando a página (directives/aparecer.js) -->
        <div v-aparecer class="apresentacao-grid">
          <div class="apresentacao-texto">
            <Selo tom="suave">Um mundo ao seu alcance</Selo>

            <h2 id="titulo-apresentacao" class="apresentacao-titulo">
              Histórias que aproximam.<br>Leitura que transforma.
            </h2>

            <p class="apresentacao-descricao">
              O Cantinho da Leitura nasce para ampliar o acesso aos livros e acolher
              diferentes formas de ler. Uma biblioteca para famílias, pessoas e novas
              possibilidades.
            </p>

            <Botao to="/sobre">Conheça o projeto</Botao>
          </div>

          <article class="card-ouvir">
            <div class="card-ouvir-texto">
              <Icone class="card-ouvir-icone" nome="fones" :tamanho="48" />
              <h3 class="card-ouvir-titulo">Para ler. Para ouvir.<br>Para todo mundo.</h3>
              <p class="card-ouvir-descricao">Textos ajustáveis e audiobooks fazem parte da proposta da biblioteca.</p>
            </div>

            <img class="card-ouvir-img" :src="garotaComFone" alt="" aria-hidden="true">
          </article>
        </div>

        <CabecalhoSecao
          v-aparecer
          class="apresentacao-destaque"
          titulo="Livros em destaque"
          subtitulo="Uma boa história pode ser seu próximo começo."
        >
          <template #ilustracao><img :src="lamparina" alt=""></template>
        </CabecalhoSecao>
      </section>

      <section class="livros-destaque" aria-label="Livros em destaque">
        <img class="deco deco-coruja" :src="coruja" alt="" aria-hidden="true">

        <p v-if="carregandoDestaque" class="livros-aviso" role="status">Carregando livros…</p>

        <!-- Os livros entram um por um (cascata) quando a seção aparece -->
        <ul v-else-if="livrosDestaque.length" v-aparecer class="livros-lista aparecer-em-cascata">
          <li v-for="(livro, indice) in livrosDestaque" :key="livro.id" class="livros-item" :style="{ '--ordem': indice }">
            <CardLivro
              :titulo="livro.titulo"
              :autor="livro.autor || ''"
              :categoria="livro.categoria?.nome"
              :capa-url="livro.capa_url"
              :formato="textoFormato(livro)"
              :icone-formato="temAudio(livro) ? 'fones' : 'livro'"
              :to="{ name: 'livro-detalhe', params: { id: livro.id } }"
              :mostrar-categoria="false"
              :mostrar-favoritar="false"
            />
          </li>
        </ul>

        <Botao class="livros-acao" to="/acervo-publico">Explorar acervo →</Botao>
      </section>

      <section class="chamada" aria-labelledby="titulo-chamada">
        <div v-aparecer class="chamada-box" :style="{ '--fundo-chamada': `url('${fundoChamada}')` }">
          <h2 id="titulo-chamada" class="chamada-titulo">Seu próximo capítulo<br>começa neste cantinho.</h2>
          <Botao class="chamada-acao" to="/entrar">Entrar para acessar</Botao>
        </div>
      </section>
    </main>

    <Rodape>
      <template #decoracao>
        <img class="rodape-nuvem" :src="nuvemRodape" alt="">
        <div class="rodape-ilustracao">
          <img class="rodape-livro" :src="livroRodape" alt="">
          <img class="rodape-garoto" :src="garotoRodape" alt="">
        </div>
      </template>
    </Rodape>
  </div>
</template>

<style scoped>
.pagina {
  --margem: clamp(var(--espaco-24), 9.8vw, 141px);

  position: relative; /* referência para o menu que flutua sobre o banner */
  background: var(--fundo-pagina);
}

/* O menu flutua em cima do banner (o ".pagina >" vence o position do componente) */
.pagina > .menu-sobre-banner {
  position: absolute;
  inset: 0 0 auto;
  z-index: 2;
}

/* ===== Apresentação (abaixo do banner) ===== */
.apresentacao {
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  gap: 90px;
  padding: 60px var(--margem) 50px;
}

.apresentacao-grid,
.apresentacao-destaque {
  position: relative;
  z-index: 1; /* conteúdo acima das nuvens */
}

.apresentacao-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--espaco-64);
  align-items: center;
}

.apresentacao-texto {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-16);
}

.apresentacao-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.apresentacao-descricao {
  max-width: 460px;
  color: var(--texto-corpo);
  font: var(--fonte-corpo);
}

.card-ouvir {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--espaco-16);
  padding: 56px var(--espaco-32);
  border: 1px solid var(--fundo-superficie);
  border-radius: var(--raio-40);
  background: var(--fundo-nuvem);
  box-shadow: var(--sombra-cartao);
}

.card-ouvir-texto {
  flex: 1 0 auto;
  display: flex;
  flex-direction: column;
  gap: var(--espaco-16);
}

.card-ouvir-icone,
.card-ouvir-titulo {
  color: var(--texto-principal);
}

.card-ouvir-titulo {
  font: var(--fonte-titulo-cartao);
}

.card-ouvir-descricao {
  max-width: 250px;
  color: var(--texto-corpo);
  font: var(--fonte-corpo);
}

.card-ouvir-img {
  width: 220px;
  flex-shrink: 1;
  min-width: 0;
}

/* ===== Decorações (ficam atrás do conteúdo) ===== */
.deco {
  position: absolute;
  pointer-events: none;
}

.deco-nuvem {
  top: 20px;
  left: 38%;
  width: 190px;
}

.deco-nuvem-roxa {
  top: 400px;
  left: 40px;
  width: 135px;
}

.deco-nuvem-arcoiris {
  right: 0;
  bottom: 0;
  width: 640px;
}

.deco-estrela {
  right: 0;
  bottom: 140px;
  width: 175px;
}

/* ===== Livros em destaque ===== */
.livros-destaque {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--espaco-24);
  padding: var(--espaco-8) 0 var(--espaco-48);
}

.livros-lista {
  position: relative;
  z-index: 1;
  display: flex;
  justify-content: safe center; /* centraliza, mas se não couber começa no 1º card (sem cortar) */
  gap: var(--espaco-16);
  width: 100%;
  padding: var(--espaco-16) var(--margem) var(--espaco-24);
  scroll-padding-inline: var(--margem); /* o encaixe da rolagem respeita o espaço lateral */
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  list-style: none;
  scrollbar-width: none;
}

.livros-lista::-webkit-scrollbar {
  display: none;
}

.livros-item {
  display: flex; /* cards com a mesma altura, mesmo com título de 1 ou 2 linhas */
  flex: 0 0 272px; /* largura do Card de livro no Figma */
  scroll-snap-align: start;
}

.livros-item > * {
  flex: 1;
}

.livros-aviso {
  position: relative;
  z-index: 1;
  color: var(--texto-secundario);
  font: var(--fonte-corpo);
}

.livros-acao {
  position: relative;
  z-index: 1;
  min-width: 250px;
}

.deco-coruja {
  left: 60px;
  bottom: -70px; /* negativo = desce e invade a chamada */
  z-index: 5; /* na frente dos cards e da chamada */
  width: 110px;
}

/* ===== Chamada (acima do rodapé) ===== */
.chamada {
  padding: 0 var(--espaco-32) var(--espaco-48);
  /* metade da cor da página + metade da cor do rodapé: a caixa fica "entre" as duas */
  background: linear-gradient(to bottom, var(--fundo-pagina) 50%, var(--fundo-nuvem) 50%);
}

.chamada-box {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: var(--espaco-32);
  aspect-ratio: 3072 / 700; /* menor que a imagem: corta só a faixa bege de baixo */
  padding: 0 clamp(var(--espaco-24), 7.5vw, 108px) 35px;
  border-radius: var(--raio-40);
  overflow: hidden;
  color: var(--texto-inverso);
  background-image:
    linear-gradient(to top, rgb(47 47 47 / 60%), transparent 60%),
    var(--fundo-chamada);
  background-size: cover;
  background-position: center top;
}

.chamada-titulo {
  font: var(--fonte-display);
  line-height: 1;
}

.chamada-acao {
  flex-shrink: 0;
  min-width: 300px;
}

/* ===== Rodapé: ilustrações ===== */
.rodape-nuvem {
  position: absolute;
  left: -40px;
  bottom: -20px;
  width: 340px;
}

.rodape-ilustracao {
  position: absolute;
  top: var(--espaco-48);
  right: var(--margem);
  width: 294px;
  height: 249px;
}

.rodape-livro {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
}

.rodape-garoto {
  position: absolute;
  top: 0;
  left: 61px;
  width: 159px;
}

/* ===== Responsividade ===== */
@media (max-width: 1280px) {
  .deco-nuvem-arcoiris {
    width: 520px;
  }

  .deco-coruja {
    left: 30px;
    width: 90px;
  }
}

/* Apresentação vira uma coluna: texto em cima, card embaixo */
@media (max-width: 1024px) {
  .apresentacao {
    gap: 70px;
    padding-top: var(--espaco-48);
  }

  .apresentacao-grid {
    grid-template-columns: 1fr;
  }

  .apresentacao-descricao,
  .card-ouvir-descricao {
    max-width: none;
  }

  .deco-nuvem,
  .deco-nuvem-roxa,
  .rodape-ilustracao {
    display: none;
  }

  .deco-estrela {
    width: 130px;
  }

  .chamada {
    padding-inline: var(--espaco-24);
  }

  .chamada-box {
    aspect-ratio: 3072 / 1000; /* um pouco mais alta para o texto caber */
  }

  .chamada-titulo {
    font: var(--fonte-titulo);
    line-height: 1.1;
  }
}

@media (max-width: 768px) {
  /* O menu vira uma barra normal no topo (não flutua mais sobre o banner) */
  .pagina > .menu-sobre-banner {
    position: relative;
  }

  .apresentacao {
    gap: 56px;
    padding-bottom: var(--espaco-32);
  }

  .card-ouvir {
    flex-direction: column;
    padding: var(--espaco-32) var(--espaco-24);
    text-align: center;
  }

  .card-ouvir-texto {
    align-items: center;
  }

  .deco-nuvem-arcoiris {
    width: 380px;
  }

  .deco-estrela {
    width: 100px;
  }

  .deco-coruja {
    display: none;
  }

  /* Chamada: texto e botão empilhados, altura pelo conteúdo em vez da proporção da imagem */
  .chamada-box {
    flex-direction: column;
    justify-content: flex-end;
    align-items: flex-start;
    aspect-ratio: auto;
    min-height: 300px;
    padding: var(--espaco-24);
  }

  .chamada-acao {
    min-width: 0;
  }
}

@media (max-width: 640px) {
  .apresentacao-texto {
    align-items: center;
    text-align: center;
  }

  .card-ouvir-img {
    width: 170px;
  }

  .chamada {
    padding-inline: var(--espaco-16);
  }

  /* Chamada vira um card: a ilustração inteira em cima (sem cortar a coruja e o dragão)
     e o texto embaixo, num fundo escuro que continua a onda da imagem.
     A arte colorida ocupa ~21,5% da largura da imagem; o resto é bege. */
  .chamada-box {
    --altura-arte: calc((100vw - 32px) * 0.215);
    justify-content: flex-start;
    min-height: 0;
    padding: calc(var(--altura-arte) + var(--espaco-16)) var(--espaco-16) var(--espaco-24);
    background:
      linear-gradient(var(--destaque-escuro), var(--destaque-escuro)) bottom / 100% calc(100% - var(--altura-arte)) no-repeat,
      var(--fundo-chamada) top / 100% auto no-repeat;
  }

  .chamada-acao {
    align-self: stretch; /* botão na largura toda */
  }

  .livros-item {
    flex-basis: 240px;
  }
}
</style>
