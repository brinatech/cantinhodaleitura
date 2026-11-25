<!--
  Rodapé (Figma: "Rodapé"). Rodapé padrão de todas as páginas públicas.
  As ilustrações (nuvem e menino lendo) já vêm por padrão em todas as páginas; quem quiser
  outra decoração passa o slot "decoracao". Ficam fora do alcance do mouse.
  A coluna de contato da ONG (Figma) foi tirada a pedido da equipe: o nome da ONG não aparece nas telas.
-->
<script setup>
import { RouterLink } from 'vue-router'
import logo from '../../images/imgs-footer/logo-footer.png'
import nuvem from '../../images/imgs-footer/nuvem-footer.png'
import livro from '../../images/imgs-footer/livro.png'
import garoto from '../../images/imgs-footer/garoto-cadeira.png'

const links = [
  { texto: 'Sobre o projeto', to: '/sobre' },
  { texto: 'Acervo', to: '/acervo' },
  { texto: 'Acessibilidade', to: '/acessibilidade' },
]
</script>

<template>
  <footer class="rodape">
    <div class="rodape-decoracao" aria-hidden="true">
      <!-- Padrão de todas as páginas (o da Home). Quem quiser outra decoração passa o slot "decoracao". -->
      <slot name="decoracao">
        <img class="rodape-nuvem" :src="nuvem" alt="">
        <div class="rodape-ilustracao">
          <img class="rodape-livro" :src="livro" alt="">
          <img class="rodape-garoto" :src="garoto" alt="">
        </div>
      </slot>
    </div>

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
    </div>

    <hr class="rodape-divisor">

    <p class="rodape-nota">Cantinho da Leitura &nbsp;/&nbsp; Protótipo acadêmico · Conteúdo de demonstração</p>
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

/* Decoração padrão (veio da Home): nuvem embaixo à esquerda, menino lendo à direita */
.rodape-nuvem {
  position: absolute;
  left: -40px;
  bottom: -20px;
  width: 340px;
}

.rodape-ilustracao {
  position: absolute;
  top: var(--espaco-48);
  right: clamp(var(--espaco-24), 9.8vw, 141px); /* a mesma margem lateral do rodapé */
  width: 294px;
  height: 249px;
  z-index: 1; /* fica na frente da linha divisória (a nuvem continua atrás) */
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

/* Em telas menores a ilustração cobriria os links: some */
@media (max-width: 1024px) {
  .rodape-ilustracao {
    display: none;
  }
}

.rodape-colunas,
.rodape-divisor,
.rodape-nota {
  position: relative; /* acima da decoração */
}

/* 3 faixas: marca | links | vazio. As laterais têm o mesmo tamanho (1fr),
   então a coluna de links fica no centro da página. */
.rodape-colunas {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
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

/* No celular: uma faixa só, links embaixo da marca, alinhados à esquerda */
@media (max-width: 768px) {
  .rodape-colunas {
    grid-template-columns: 1fr;
  }
}

.rodape-titulo {
  color: var(--texto-principal);
  font: var(--fonte-botao);
  font-size: 1.195rem; /* ~19px: um pouco maior que o texto do rodapé */
  letter-spacing: 0.03em;
}

.rodape-coluna ul {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: var(--espaco-4, 4px);
  font-size: 1.0825rem; /* ~17,3px */
  letter-spacing: 0.02em;
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
