<!--
  Rodapé (Figma: "Rodapé"). Rodapé padrão de todas as páginas públicas.
  As ilustrações (nuvem, leitor) são opcionais e entram no slot "decoracao",
  posicionadas por quem usa; ficam atrás do texto e fora do alcance do mouse.
  Os textos de contato da SESFA ainda são os do Figma ("a definir pela equipe").
-->
<script setup>
import { RouterLink } from 'vue-router'
import logo from '../../images/imgs-footer/logo-footer.png'

const links = [
  { texto: 'Sobre o projeto', to: '/sobre' },
  { texto: 'Acervo', to: '/acervo' },
  { texto: 'Acessibilidade', to: '/acessibilidade' },
]
</script>

<template>
  <footer class="rodape">
    <div class="rodape-decoracao" aria-hidden="true"><slot name="decoracao" /></div>

    <div class="rodape-colunas">
      <div class="rodape-marca">
        <img class="rodape-logo" :src="logo" alt="Cantinho da Leitura" width="220">
        <p>Um cantinho para descobrir, imaginar e aprender. Uma iniciativa de leitura que acolhe.</p>
      </div>

      <nav class="rodape-coluna" aria-label="Biblioteca">
        <h2 class="rodape-titulo">Biblioteca</h2>
        <ul>
          <li v-for="link in links" :key="link.texto">
            <RouterLink class="rodape-link" :to="link.to">{{ link.texto }}</RouterLink>
          </li>
        </ul>
      </nav>

      <div class="rodape-coluna">
        <h2 class="rodape-titulo">SESFA</h2>
        <ul>
          <li>ONG parceira</li>
          <li>Contato a definir pela equipe</li>
          <li>Redes sociais a definir</li>
        </ul>
      </div>
    </div>

    <hr class="rodape-divisor">

    <p class="rodape-nota">Cantinho da Leitura · SESFA &nbsp;/&nbsp; Protótipo acadêmico · Conteúdo de demonstração</p>
  </footer>
</template>

<style scoped>
.rodape {
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  gap: var(--espaco-32);
  padding: var(--espaco-48) clamp(var(--espaco-24), 9.8vw, 141px) var(--espaco-32);
  background: var(--fundo-nuvem);
  color: var(--texto-secundario);
  font: var(--fonte-interface);
}

.rodape-decoracao {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.rodape-colunas,
.rodape-divisor,
.rodape-nota {
  position: relative; /* acima da decoração */
}

.rodape-colunas {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-32) 64px;
}

.rodape-marca {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-12);
  max-width: 333px;
}

.rodape-logo {
  height: auto;
}

.rodape-coluna {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-12);
}

.rodape-titulo {
  color: var(--texto-principal);
  font: var(--fonte-botao);
}

.rodape-coluna ul {
  list-style: none;
}

.rodape-link {
  color: inherit;
  text-decoration: none;
}

.rodape-link:hover {
  color: var(--texto-principal);
  text-decoration: underline;
}

.rodape-link:focus-visible {
  outline: 3px solid var(--borda-foco);
  outline-offset: 3px;
  border-radius: var(--raio-8);
}

.rodape-divisor {
  height: 1px;
  border: 0;
  background: var(--borda-padrao);
}

.rodape-nota {
  font: var(--fonte-legenda);
}
</style>
