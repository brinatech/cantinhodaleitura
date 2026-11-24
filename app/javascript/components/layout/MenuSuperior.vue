<!--
  Menu superior (Figma: "Menu superior"). Cabeçalho do site.
  O botão da direita segue a sessão: visitante "Entrar"; leitor logado "Meu espaço";
  administrador "Administração" (cada um vai para o seu início).
  "links" troca os links do meio e "acaoPara" a rota do botão; sem eles, usa os
  do Figma.
  "sobreBanner": versão da tela inicial. O menu flutua sobre o banner e só o
  logo e os links ficam numa faixa branca de canto arredondado; o botão fica
  direto sobre a imagem. Quem usa posiciona o menu (absolute) em cima do banner.
  Até 768px o menu vira um botão que abre e fecha a lista (links + ação).
  "Acessibilidade" (BotaoAcessibilidade) abre o mesmo painel de ajustes da área logada: o visitante
  também precisa de letra maior, contraste etc. No celular ele fica sempre à mostra,
  ao lado do botão de menu, em vez de escondido dentro do menu fechado.
-->
<script setup>
import { computed, ref, watch } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import Botao from '../ui/Botao.vue'
import Icone from '../ui/Icone.vue'
import BotaoAcessibilidade from './BotaoAcessibilidade.vue'
import { useAuthStore } from '../../stores/auth.js'
import logo from '../../images/logo-header.png'

const props = defineProps({
  leitor: { type: Boolean, default: false },
  sobreBanner: { type: Boolean, default: false },
  links: { type: Array, default: null }, // [{ texto, to }]
  acaoPara: { type: [String, Object], default: null },
})

const linksPadrao = computed(() =>
  props.leitor
    ? [
        { texto: 'Início', to: '/' },
        { texto: 'Acervo', to: '/acervo' },
        { texto: 'Acessibilidade', to: '/acessibilidade' },
      ]
    : [
        { texto: 'Início', to: '/' },
        { texto: 'Sobre', to: '/sobre' },
        { texto: 'Acervo', to: '/acervo-publico' }, // shortcut: visitante ainda não tem o acervo (ver router)
      ],
)
const linksDoMenu = computed(() => props.links ?? linksPadrao.value)

// O botão da direita segue quem está logado: visitante "Entrar"; leitor "Meu espaço";
// administrador "Administração". Cada um vai para o seu início (stores/auth.js)
const auth = useAuthStore()
const logado = computed(() => props.leitor || Boolean(auth.usuario))
const destinoDaAcao = computed(() => props.acaoPara ?? (auth.usuario ? auth.inicio : logado.value ? '/minhas-leituras' : '/entrar'))
const textoDaAcao = computed(() => (auth.ehAdministrador ? 'Administração' : logado.value ? 'Meu espaço' : 'Entrar'))

const aberto = ref(false)
const rota = useRoute()
watch(() => rota.fullPath, () => (aberto.value = false))
</script>

<template>
  <header class="menu" :class="{ 'menu--sobre-banner': sobreBanner, 'menu--aberto': aberto }" @keydown.esc="aberto = false">
    <div class="menu-faixa">
      <RouterLink class="menu-logo" to="/">
        <img :src="logo" alt="Cantinho da Leitura" width="196" height="62.8">
      </RouterLink>

      <nav id="menu-lista" class="menu-nav" aria-label="Menu principal">
        <ul class="menu-links">
          <li v-for="link in linksDoMenu" :key="link.texto">
            <RouterLink class="menu-link" :to="link.to">{{ link.texto }}</RouterLink>
          </li>
        </ul>
      </nav>
    </div>

    <div class="menu-acoes">
      <BotaoAcessibilidade class="menu-acessibilidade" />

      <Botao class="menu-acao" :to="destinoDaAcao">
        <template v-if="logado" #icone><Icone nome="usuario" /></template>
        {{ textoDaAcao }}
      </Botao>
    </div>

    <button
      type="button"
      class="menu-alternar"
      :aria-expanded="aberto"
      aria-controls="menu-lista"
      @click="aberto = !aberto"
    >
      <Icone :nome="aberto ? 'fechar' : 'lista'" :rotulo="aberto ? 'Fechar menu' : 'Abrir menu'" />
    </button>
  </header>
</template>

<style scoped>
.menu {
  --margem: clamp(var(--espaco-24), 9.8vw, 141px);

  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--espaco-24);
  min-height: 88px;
  padding: var(--espaco-12) var(--margem);
  background: var(--fundo-superficie);
}

.menu-faixa {
  display: contents; /* fora da home, logo e links ficam direto na barra */
}

/* Acessibilidade e Entrar lado a lado, na ponta direita */
.menu-acoes {
  display: flex;
  flex-shrink: 0;
  align-items: center;
  gap: var(--espaco-12);
}

.menu-logo {
  display: inline-flex;
  flex-shrink: 0;
}

.menu-logo img {
  height: 62.8px;
}

.menu-nav {
  flex: 1;
  display: flex;
  justify-content: center;
}

.menu-links {
  display: flex;
  align-items: center;
  gap: var(--espaco-24); /* espaço entre as pílulas: cada link fica "independente" */
  list-style: none;
}

/* Cada link é uma "pílula": letra maior (18px), área de clique de pelo menos 44px de altura
   e fundo que escurece de leve ao passar o mouse (o mesmo padrão do menu lateral da área logada) */
.menu-link {
  display: inline-flex;
  align-items: center;
  min-height: 44px;
  padding: 10px 18px;
  border-radius: var(--raio-total);
  color: var(--texto-principal);
  font: var(--fonte-corpo);
  text-decoration: none;
  white-space: nowrap;
  transition: background-color var(--duracao-rapida) var(--curva);
}

.menu-link:hover {
  background: var(--camada-hover);
}

/* Página atual: negrito e fundo azul-claro */
.menu-link.router-link-exact-active {
  background: var(--fundo-suave);
  font-weight: 700;
}

.menu-logo:focus-visible,
.menu-alternar:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 4px;
  border-radius: var(--raio-8);
}

/* A pílula já é redonda: o contorno do foco acompanha o formato dela */
.menu-link:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 2px;
}

.menu-alternar {
  display: none;
  padding: var(--espaco-8);
  border: 0;
  background: transparent;
  color: var(--texto-principal);
  cursor: pointer;
}

/* ===== Na home: faixa branca só atrás do logo e dos links ===== */
.menu--sobre-banner {
  min-height: 0;
  padding: 0 var(--margem) 0 0;
  background: transparent;
}

.menu--sobre-banner .menu-faixa {
  display: flex;
  flex: 0 1 74%;
  align-items: center;
  justify-content: space-between;
  gap: var(--espaco-24);
  min-height: 83px;
  /* 96px à direita: os links não ficam em cima da curva da faixa */
  padding: var(--espaco-12) 96px var(--espaco-12) var(--margem);
  border-radius: 0 0 41.5px 0;
  background: var(--fundo-superficie);
}

.menu--sobre-banner .menu-nav {
  flex: 0 1 auto;
}

/* ===== Telas médias (tablet deitado, notebook pequeno): a faixa da home encolhe =====
   Espaços menores para os links não encostarem no logo */
@media (min-width: 769px) and (max-width: 1100px) {
  .menu-links {
    gap: var(--espaco-4);
  }

  .menu-link {
    padding-inline: var(--espaco-12);
  }

  .menu--sobre-banner .menu-faixa {
    padding-right: var(--espaco-48);
  }
}

/* ===== Celular: menu recolhível ===== */
@media (max-width: 768px) {
  .menu,
  .menu--sobre-banner {
    position: relative;
    flex-wrap: wrap;
    gap: var(--espaco-12);
    min-height: 0;
    padding: var(--espaco-12) var(--espaco-24);
    border-radius: 0 0 var(--raio-20) var(--raio-20);
    background: var(--fundo-superficie);
  }

  .menu--sobre-banner .menu-faixa,
  .menu-faixa {
    display: contents;
  }

  .menu-logo {
    margin-right: auto;
  }

  .menu-logo img {
    height: 48px;
  }

  .menu-alternar {
    display: inline-flex;
    order: 2;
  }

  /* Celular: as ações saem do grupo para cada uma ir para o seu lugar */
  .menu-acoes {
    display: contents;
  }

  /* Acessibilidade sempre à mostra, antes do botão de menu */
  .menu-acessibilidade {
    order: 1;
  }

  /* Fechado: some da tela e dos leitores de tela. Aberto: ocupa a linha de baixo */
  .menu-nav,
  .menu-acao {
    display: none;
  }

  .menu--aberto .menu-nav,
  .menu--aberto .menu-acao {
    display: flex;
    order: 3;
    flex: 1 0 100%;
  }

  .menu--aberto .menu-links {
    flex-direction: column;
    align-items: stretch;
    gap: var(--espaco-4);
    width: 100%;
  }

  /* Celular: cada link ocupa a linha inteira (fácil de tocar), com a mesma pílula */
  .menu--aberto .menu-link {
    display: flex;
    width: 100%;
    border-radius: var(--raio-12);
  }

  .menu--aberto .menu-acao {
    order: 4;
    justify-content: center;
  }

  .menu--aberto {
    box-shadow: var(--sombra-flutuante);
  }
}
</style>
