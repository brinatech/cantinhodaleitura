<!--
  Estrutura da área logada (Figma: "Barra lateral" + "Barra superior"): menu lateral
  à esquerda, barra com busca, Acessibilidade e perfil em cima, e o conteúdo da
  página no slot. Em telas menores o menu lateral vira uma gaveta aberta pelo
  botão de menu. O painel "Ajustes de leitura" abre pelo botão Acessibilidade.
  O nome do leitor vem da sessão (stores/auth.js); "Sair" encerra a sessão.
-->
<script setup>
import { computed, ref, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import Botao from '../ui/Botao.vue'
import CampoBusca from '../ui/CampoBusca.vue'
import Icone from '../ui/Icone.vue'
import ItemMenuLateral from '../ui/ItemMenuLateral.vue'
import PainelAcessibilidade from './PainelAcessibilidade.vue'
import { useAuthStore } from '../../stores/auth.js'
import logo from '../../images/logo-header.png'

const auth = useAuthStore()
const leitor = computed(() => ({ nome: auth.usuario?.nome ?? '' }))
// Só para o admin saber que está com poderes extras; quem protege as ações é o Rails
const administrador = computed(() => auth.usuario?.tipo_usuario === 'administrador')

const principais = [
  { texto: 'Minhas leituras', to: '/minhas-leituras', icone: 'livro' },
  { texto: 'Acervo', to: '/acervo', icone: 'bussola' },
  { texto: 'Favoritos', to: '/favoritos', icone: 'coracao' },
  { texto: 'Listas de leitura', to: '/listas-de-leitura', icone: 'lista' },
  { texto: 'Histórico', to: '/historico', icone: 'historico' },
]
// Só aparece para administrador (conveniência: quem protege é o Rails)
const administracao = computed(() =>
  auth.usuario?.tipo_usuario === 'administrador'
    ? [
        { texto: 'Livros', to: '/admin/livros', icone: 'livro' },
        { texto: 'Categorias', to: '/admin/categorias', icone: 'marcador' },
        { texto: 'Relatórios', to: '/admin/relatorios', icone: 'grafico' },
      ]
    : [],
)
const secundarios = [
  { texto: 'Meu perfil', to: '/meu-perfil', icone: 'usuario' },
  { texto: 'Sobre o projeto', to: '/sobre', icone: 'info' },
  { texto: 'Sair', icone: 'sair', acao: sair }, // sem "to": vira botão
]

const rota = useRoute()
const roteador = useRouter()

async function sair() {
  await auth.sair()
  roteador.push('/')
}

const menuAberto = ref(false)
watch(() => rota.fullPath, () => (menuAberto.value = false))

// O campo mostra o que está buscado na URL (/acervo?busca=...) e acompanha quando ela muda
const buscaDaRota = () => (typeof rota.query.busca === 'string' ? rota.query.busca : '')
const busca = ref(buscaDaRota())
watch(() => rota.query.busca, () => (busca.value = buscaDaRota()))
const buscar =() => roteador.push({ path: '/acervo', query: busca.value.trim() ? { busca: busca.value.trim() } : {} })

const painel = ref(null)
</script>

<template>
  <div class="logado" :class="{ 'logado--menu-aberto': menuAberto }" @keydown.esc="menuAberto = false">
    <aside id="menu-lateral" class="lateral">
      <RouterLink class="lateral-logo" to="/minhas-leituras">
        <img :src="logo" alt="Cantinho da Leitura" width="180">
      </RouterLink>

      <nav class="lateral-nav" aria-label="Menu do leitor">
        <p class="lateral-rotulo">Menu</p>
        <!-- Também nas subpáginas: "Listas de leitura" em /listas-de-leitura/5, "Acervo" em /acervo/3 -->
        <ItemMenuLateral v-for="item in principais" :key="item.to" :to="item.to" :icone="item.icone" :ativo="rota.path === item.to || rota.path.startsWith(`${item.to}/`)">
          {{ item.texto }}
        </ItemMenuLateral>

        <template v-if="administracao.length">
          <p class="lateral-rotulo lateral-rotulo--secao">Administração</p>
          <!-- startsWith: "Livros" continua destacado em /admin/livros/:id/classificacoes -->
          <ItemMenuLateral v-for="item in administracao" :key="item.to" :to="item.to" :icone="item.icone" :ativo="rota.path.startsWith(item.to)">
            {{ item.texto }}
          </ItemMenuLateral>
        </template>

        <hr class="lateral-divisor">

        <ItemMenuLateral v-for="item in secundarios" :key="item.texto" :to="item.to" :icone="item.icone" :ativo="rota.path === item.to" @click="item.acao?.()">
          {{ item.texto }}
        </ItemMenuLateral>
      </nav>
    </aside>

    <div class="logado-fundo" aria-hidden="true" @click="menuAberto = false"></div>

    <div class="logado-area">
      <header class="barra">
        <button
          type="button"
          class="barra-menu"
          :aria-expanded="menuAberto"
          aria-controls="menu-lateral"
          @click="menuAberto = !menuAberto"
        >
          <Icone :nome="menuAberto ? 'fechar' : 'lista'" :rotulo="menuAberto ? 'Fechar menu' : 'Abrir menu'" />
        </button>

        <form class="barra-busca" role="search" @submit.prevent="buscar">
          <CampoBusca v-model="busca" placeholder="Busque um livro, autor ou categoria" />
        </form>

        <Botao class="barra-acessibilidade" tipo="contorno" aria-haspopup="dialog" @click="painel.abrir()">
          <template #icone><Icone nome="acessibilidade" /></template>
          <span class="barra-acessibilidade-texto">Acessibilidade</span>
        </Botao>

        <RouterLink class="perfil" to="/meu-perfil" :aria-label="`Meu perfil, ${leitor.nome}${administrador ? ', administrador' : ''}`">
          <span class="perfil-avatar" aria-hidden="true">{{ leitor.nome[0] }}</span>
          <span class="perfil-textos">
            <span class="perfil-nome">{{ leitor.nome }}</span>
            <span v-if="administrador" class="perfil-papel">Administrador</span>
          </span>
          <Icone class="perfil-seta" nome="seta-baixo" :tamanho="18" />
        </RouterLink>
      </header>

      <main class="logado-conteudo">
        <slot />
      </main>
    </div>

    <PainelAcessibilidade ref="painel" />
  </div>
</template>

<style scoped>
.logado {
  display: flex;
  min-height: 100vh;
  background: var(--fundo-pagina);
}

/* ===== Menu lateral (264px no Figma) ===== */
.lateral {
  position: sticky;
  top: 0;
  z-index: 20;
  display: flex;
  flex: 0 0 264px;
  flex-direction: column;
  gap: var(--espaco-4);
  width: 264px;
  height: 100vh;
  padding: 28px 20px var(--espaco-24);
  overflow-y: auto;
  border-right: 1px solid var(--borda-padrao);
  background: var(--fundo-superficie);
}

.lateral-logo {
  display: inline-flex;
  align-self: flex-start;
  margin-bottom: 28px;
  border-radius: var(--raio-8);
}

.lateral-logo img {
  width: 180px;
  height: auto;
}

.lateral-logo:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 3px;
}

.lateral-nav {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: var(--espaco-4);
}

.lateral-rotulo {
  padding: 0 0 var(--espaco-8) var(--espaco-16);
  color: var(--texto-secundario);
  font: var(--fonte-rotulo);
  letter-spacing: var(--letras-rotulo);
  text-transform: uppercase;
}

.lateral-rotulo--secao {
  padding-top: var(--espaco-16);
}

/* Separa o grupo de baixo (perfil, sobre, sair): empurra para o fim do menu */
.lateral-divisor {
  height: 1px;
  margin: auto 0 var(--espaco-8);
  border: 0;
  background: var(--borda-padrao);
}

.logado-fundo {
  display: none;
}

/* ===== Área da direita ===== */
.logado-area {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.barra {
  position: sticky;
  top: 0;
  z-index: 10;
  display: flex;
  align-items: center;
  gap: var(--espaco-16);
  padding: var(--espaco-16) 40px;
  border-bottom: 1px solid var(--borda-padrao);
  background: var(--fundo-superficie);
}

.barra-menu {
  display: none;
  padding: var(--espaco-8);
  border: 0;
  border-radius: var(--raio-8);
  background: transparent;
  color: var(--texto-principal);
  cursor: pointer;
  transition: background-color var(--duracao-rapida) var(--curva);
}

.barra-menu:hover {
  background: var(--camada-hover);
}

.barra-menu:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 2px;
}

.barra-busca {
  flex: 1 1 440px;
  max-width: 440px;
  min-width: 0;
  margin-right: auto;
}

.perfil {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: var(--espaco-4) var(--espaco-12) var(--espaco-4) var(--espaco-4);
  border-radius: var(--raio-total);
  background: var(--fundo-nuvem);
  color: var(--texto-principal);
  font: var(--fonte-botao);
  text-decoration: none;
  transition: background-color var(--duracao-rapida) var(--curva);
}

.perfil:hover {
  background: color-mix(in srgb, var(--fundo-nuvem), var(--texto-principal) 8%);
}

.perfil:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 2px;
}

/* Nome em cima e, para o admin, o papel menor embaixo */
.perfil-textos {
  display: flex;
  flex-direction: column;
  line-height: 1.2;
}

.perfil-papel {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}

.perfil-avatar {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: var(--destaque-ceu);
  color: var(--texto-sobre-cor);
}

.logado-conteudo {
  flex: 1;
  padding: var(--espaco-32) 40px 56px;
}

/* ===== Telas menores: o menu lateral vira gaveta ===== */
@media (max-width: 1100px) {
  .lateral {
    position: fixed;
    inset: 0 auto 0 0;
    visibility: hidden; /* fechada: fora da tela, do Tab e dos leitores de tela */
    transform: translateX(-100%);
    transition: transform 0.25s ease, visibility 0.25s;
    box-shadow: var(--sombra-flutuante);
  }

  .logado--menu-aberto .lateral {
    visibility: visible;
    transform: none;
  }

  .logado--menu-aberto .logado-fundo {
    position: fixed;
    inset: 0;
    z-index: 15;
    display: block;
    background: color-mix(in srgb, var(--texto-corpo) 40%, transparent);
  }

  .barra-menu {
    display: inline-flex;
  }
}

@media (prefers-reduced-motion: reduce) {
  .lateral {
    transition: none;
  }
}

@media (max-width: 768px) {
  .barra {
    gap: var(--espaco-8);
    padding: var(--espaco-12) var(--espaco-16);
  }

  .logado-conteudo {
    padding: var(--espaco-24) var(--espaco-16) var(--espaco-48);
  }

  /* Acessibilidade e perfil só com o ícone/avatar; o nome continua para leitores de tela */
  .barra-acessibilidade-texto,
  .perfil-textos {
    position: absolute;
    width: 1px;
    height: 1px;
    overflow: hidden;
    clip-path: inset(50%);
    white-space: nowrap;
  }

  .barra-acessibilidade {
    padding: var(--espaco-12);
  }

  .perfil {
    padding: var(--espaco-4);
  }

  .perfil-seta {
    display: none;
  }
}

@media (max-width: 520px) {
  /* Sem espaço para a busca ao lado dos botões: ela desce para uma linha própria */
  .barra {
    flex-wrap: wrap;
  }

  .barra-busca {
    order: 5;
    flex-basis: 100%;
    max-width: none;
  }

  .barra-menu {
    margin-right: auto;
  }
}
</style>
