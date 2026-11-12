<!--
  Menu superior (Figma: "Menu superior"). Cabeçalho do site.
  Visitante mostra "Entrar"; leitor logado (leitor) mostra "Meu espaço".
  "links" troca os links do meio e "acaoPara" a rota do botão; sem eles, usa os
  do Figma (as rotas ainda vão ser criadas).
  shortcut: no mobile o Figma pede um menu recolhível; aqui os links só ficam
  mais juntos. Fazer o recolhível junto com a tela responsiva do Início.
-->
<script setup>
import { computed } from 'vue'
import { RouterLink } from 'vue-router'
import Botao from '../ui/Botao.vue'
import Icone from '../ui/Icone.vue'
import logo from '../../images/logo-header.png'

const props = defineProps({
  leitor: { type: Boolean, default: false },
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
</script>

<template>
  <header class="menu">
    <RouterLink class="menu-logo" to="/">
      <img :src="logo" alt="Cantinho da Leitura" width="196" height="62.8">
    </RouterLink>

    <nav aria-label="Menu principal">
      <ul class="menu-links">
        <li v-for="link in linksDoMenu" :key="link.texto">
          <RouterLink class="menu-link" :to="link.to">{{ link.texto }}</RouterLink>
        </li>
      </ul>
    </nav>

    <Botao :to="destinoDaAcao">
      <template v-if="leitor" #icone><Icone nome="usuario" /></template>
      {{ leitor ? 'Meu espaço' : 'Entrar' }}
    </Botao>
  </header>
</template>

<style scoped>
.menu {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--espaco-24);
  min-height: 88px;
  padding: var(--espaco-12) clamp(var(--espaco-24), 9.8vw, 141px);
  background: var(--fundo-superficie);
}

.menu-logo {
  display: inline-flex;
  flex-shrink: 0;
}

.menu-logo img {
  height: 62.8px;
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

.menu-logo:focus-visible,
.menu-link:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 4px;
  border-radius: var(--raio-8);
}

@media (max-width: 768px) {
  .menu-links {
    gap: var(--espaco-24);
  }
}
</style>
