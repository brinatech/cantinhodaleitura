<!--
  Menu superior (Figma: "Menu superior"). Cabeçalho do site.
  Visitante mostra "Entrar"; leitor logado (leitor) mostra "Meu espaço".
  "links" troca os links do meio e "acaoPara" a rota do botão; sem eles, usa os
  do Figma.
  "sobreBanner": versão da tela inicial. O menu flutua sobre o banner e só o
  logo e os links ficam numa faixa branca de canto arredondado; o botão fica
  direto sobre a imagem. Quem usa posiciona o menu (absolute) em cima do banner.
  Até 768px o menu vira um botão que abre e fecha a lista (links + ação).
-->
<script setup>
import { computed, ref, watch } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import Botao from '../ui/Botao.vue'
import Icone from '../ui/Icone.vue'
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
        { texto: 'Acervo', to: '/acervo' },
      ],
)
const linksDoMenu = computed(() => props.links ?? linksPadrao.value)
const destinoDaAcao = computed(() => props.acaoPara ?? (props.leitor ? '/minhas-leituras' : '/entrar'))
const textoDaAcao = computed(() => (props.leitor ? 'Meu espaço' : 'Entrar'))

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

    <Botao class="menu-acao" :to="destinoDaAcao">
      <template v-if="leitor" #icone><Icone nome="usuario" /></template>
      {{ textoDaAcao }}
    </Botao>

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
  gap: var(--espaco-48);
  list-style: none;
}

.menu-link {
  color: var(--texto-principal);
  font: var(--fonte-interface);
  text-decoration: none;
  white-space: nowrap;
}

.menu-link:hover {
  text-decoration: underline;
}

.menu-link.router-link-exact-active {
  font-weight: 700;
}

.menu-logo:focus-visible,
.menu-link:focus-visible,
.menu-alternar:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 4px;
  border-radius: var(--raio-8);
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
  padding: var(--espaco-12) var(--espaco-48) var(--espaco-12) var(--margem);
  border-radius: 0 0 41.5px 0;
  background: var(--fundo-superficie);
}

.menu--sobre-banner .menu-nav {
  flex: 0 1 auto;
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
    align-items: flex-start;
    gap: var(--espaco-8);
    width: 100%;
  }

  .menu--aberto .menu-link {
    display: block;
    padding: var(--espaco-8) 0;
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
