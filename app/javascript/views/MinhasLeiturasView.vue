<!--
  Minhas leituras (Figma: "Minhas leituras · área logada"). Primeira tela do leitor:
  boas-vindas com resumo, os livros em andamento e as novidades do acervo.
  shortcut: dados de exemplo fixos (como no Figma). Trocar pelos dados do leitor
  (histórico e marcadores) e do acervo quando o backend tiver essas APIs.
-->
<script setup>
import LayoutLogado from '../components/layout/LayoutLogado.vue'
import Botao from '../components/ui/Botao.vue'
import CabecalhoSecao from '../components/ui/CabecalhoSecao.vue'
import CardContinuarLendo from '../components/ui/CardContinuarLendo.vue'
import CardLivro from '../components/ui/CardLivro.vue'
import DestaquePalavra from '../components/ui/DestaquePalavra.vue'
import Icone from '../components/ui/Icone.vue'
import IconeBolha from '../components/ui/IconeBolha.vue'
import Selo from '../components/ui/Selo.vue'
import globo from '../images/ilustracoes/globo-livros.png'
import gato from '../images/ilustracoes/gato-dormindo.png'
import lamparina from '../images/imgs-baixo-banner/lamparina.png'
import nuvem from '../images/imgs-baixo-banner/nuvem.png'
import menina from '../images/imgs-baixo-banner/garota-com-fone.png'

const nome = 'Maria'

const resumo = [
  { texto: '3 em andamento', icone: 'livro', cor: 'laranja' },
  { texto: '5 livros lidos', icone: 'estrela', cor: 'rosa' },
  { texto: '2h ouvindo', icone: 'fones', cor: 'ceu' },
]

const emAndamento = [
  { titulo: 'Caminhos de casa', detalhe: 'Pedro Almeida · Capítulo 3', categoria: 'Aventura', formato: 'texto', progresso: 40, rotuloProgresso: 'Página 11 de 28' },
  { titulo: 'A menina que conversava com a Lua', detalhe: 'Ana Martins · Capítulo 5', categoria: 'Fantasia', formato: 'audiobook', progresso: 60, rotuloProgresso: '4 min restantes' },
  { titulo: 'O jardim das pequenas coisas', detalhe: 'Clara Ribeiro · Capítulo 1', categoria: 'Natureza', formato: 'texto', progresso: 20, rotuloProgresso: 'Página 3 de 16' },
]

const novidades = [
  { titulo: 'Sementes de amanhã', autor: 'Marina Santos', categoria: 'Natureza' },
  { titulo: 'As cartas do vento', autor: 'João Oliveira', categoria: 'Clássicos' },
  { titulo: 'O dragão que tinha medo do escuro', autor: 'Lucas Prado', categoria: 'Fantasia' },
  { titulo: 'O mapa do quintal', autor: 'Rita Souza', categoria: 'Aventura' },
]
</script>

<template>
  <LayoutLogado>
    <div class="leituras">
      <section class="boas-vindas" aria-labelledby="titulo-boas-vindas">
        <img class="boas-vindas-nuvem" :src="nuvem" alt="" aria-hidden="true">
        <img class="boas-vindas-menina" :src="menina" alt="" aria-hidden="true">

        <Selo tom="laranja">Olá, {{ nome }}!</Selo>
        <h1 id="titulo-boas-vindas" class="boas-vindas-titulo">
          Vamos continuar uma <DestaquePalavra>história?</DestaquePalavra>
        </h1>
        <p class="boas-vindas-texto">Seus livros guardam a página onde você parou. É só escolher e seguir lendo ou ouvindo.</p>

        <ul class="resumo">
          <li v-for="item in resumo" :key="item.texto" class="resumo-item">
            <IconeBolha :icone="item.icone" :cor="item.cor" :tamanho="36" :tamanho-icone="24" />
            {{ item.texto }}
          </li>
        </ul>
      </section>

      <section class="secao" aria-labelledby="titulo-andamento">
        <div class="secao-topo">
          <CabecalhoSecao id="titulo-andamento" titulo="Continue de onde parou" subtitulo="Seu marcador está salvo em cada livro.">
            <template #ilustracao><img :src="globo" alt=""></template>
          </CabecalhoSecao>
          <Botao tipo="contorno" to="/historico">
            <template #icone><Icone nome="historico" /></template>
            Ver histórico
          </Botao>
        </div>

        <ul class="grade grade--continuar">
          <li v-for="livro in emAndamento" :key="livro.titulo">
            <!-- shortcut: o leitor ainda não existe; a ação leva ao acervo -->
            <CardContinuarLendo layout="vertical" to="/acervo" v-bind="livro" />
          </li>
        </ul>
      </section>

      <section class="secao secao--novidades" aria-labelledby="titulo-novidades">
        <img class="secao-gato" :src="gato" alt="" aria-hidden="true">

        <div class="secao-topo">
          <CabecalhoSecao id="titulo-novidades" titulo="Novidades no acervo" subtitulo="Livros que acabaram de chegar no cantinho.">
            <template #ilustracao><img :src="lamparina" alt=""></template>
          </CabecalhoSecao>
          <Botao tipo="contorno" to="/acervo">
            <template #icone><Icone nome="seta-direita" /></template>
            Ver todo o acervo
          </Botao>
        </div>

        <ul class="grade grade--novidades">
          <li v-for="livro in novidades" :key="livro.titulo">
            <CardLivro :titulo="livro.titulo" :autor="livro.autor" :categoria="livro.categoria" formato="Texto e audiobook" to="/acervo" />
          </li>
        </ul>
      </section>
    </div>
  </LayoutLogado>
</template>

<style scoped>
.leituras {
  display: flex;
  flex-direction: column;
  gap: 40px;
  max-width: 1096px; /* largura do conteúdo no Figma */
  margin-inline: auto;
}

/* ===== Boas-vindas ===== */
.boas-vindas {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 14px;
  min-height: 276px;
  padding: var(--espaco-32) 36px;
  overflow: hidden;
  border-radius: 32px;
  background: var(--apoio-laranja-suave);
}

.boas-vindas > :not(img) {
  position: relative; /* texto acima dos adesivos */
}

.boas-vindas-nuvem,
.boas-vindas-menina {
  position: absolute;
  pointer-events: none;
}

.boas-vindas-nuvem {
  top: -26px;
  right: 170px;
  width: 300px;
  opacity: 0.9;
}

.boas-vindas-menina {
  top: 69px;
  right: var(--espaco-32);
  width: 230px;
}

.boas-vindas-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.boas-vindas-texto {
  max-width: 520px;
  color: var(--texto-corpo);
  font: var(--fonte-corpo);
}

.resumo {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-12);
  list-style: none;
}

.resumo-item {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 6px var(--espaco-16) 6px 6px;
  border-radius: var(--raio-total);
  background: var(--fundo-superficie);
  color: var(--texto-principal);
  font: var(--fonte-botao);
}

/* ===== Seções ===== */
.secao {
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.secao-topo {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  justify-content: space-between;
  gap: var(--espaco-16);
}

.secao-gato {
  position: absolute;
  top: 54px;
  left: 61%;
  z-index: 1;
  width: 140px;
  pointer-events: none;
}

.grade {
  display: grid;
  gap: 20px;
  list-style: none;
}

/* Colunas fluidas: 3 (continuar) e 4 (novidades) na largura do Figma, menos quando aperta */
.grade--continuar {
  grid-template-columns: repeat(auto-fit, minmax(min(300px, 100%), 1fr));
}

.grade--novidades {
  grid-template-columns: repeat(auto-fit, minmax(min(240px, 100%), 1fr));
}

.grade > li {
  display: flex;
}

.grade > li > * {
  flex: 1;
}

/* ===== Telas menores ===== */
@media (max-width: 1000px) {
  .boas-vindas-nuvem,
  .boas-vindas-menina,
  .secao-gato {
    display: none;
  }
}

@media (max-width: 640px) {
  .leituras {
    gap: var(--espaco-32);
  }

  .boas-vindas {
    padding: var(--espaco-24) var(--espaco-24);
    border-radius: var(--raio-20);
  }

  .boas-vindas-titulo {
    font: var(--fonte-titulo-cartao);
  }
}
</style>
