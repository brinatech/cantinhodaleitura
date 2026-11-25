<script setup>
import MenuSuperior from '../components/layout/MenuSuperior.vue'
import Rodape from '../components/layout/Rodape.vue'
import Botao from '../components/ui/Botao.vue'
import Selo from '../components/ui/Selo.vue'
</script>

<template>
  <div class="pagina-institucional">
    <MenuSuperior />
    <main class="conteudo" aria-labelledby="titulo-sobre">
      <header class="abertura">
        <Selo tom="suave">Cantinho da Leitura</Selo>
        <h1 id="titulo-sobre">Histórias que aproximam</h1>
        <p class="introducao">Um espaço digital para descobrir livros, imaginar novos mundos e compartilhar o gosto pela leitura.</p>
      </header>

      <section aria-labelledby="proposta">
        <h2 id="proposta">Uma biblioteca para diferentes formas de ler</h2>
        <p>O Cantinho da Leitura nasceu com a proposta de ampliar o acesso aos livros e acolher diferentes formas de leitura. No acervo, você pode explorar títulos e, conforme os materiais disponíveis, ler ou ouvir histórias.</p>
        <p>A plataforma também oferece recursos para organizar sua experiência, como listas de leitura, favoritos e histórico. Os recursos disponíveis podem variar de acordo com o livro e com o acesso à sua conta.</p>
      </section>

      <section class="chamada" aria-labelledby="explore">
        <div>
          <h2 id="explore">Encontre sua próxima história</h2>
          <p>Explore os livros disponíveis e escolha por onde começar.</p>
        </div>
        <Botao to="/acervo-publico">Explorar o acervo</Botao>
      </section>

      <p class="nota">O Cantinho da Leitura é um protótipo acadêmico desenvolvido em parceria com uma ONG. As informações e os materiais exibidos podem ser de demonstração.</p>
    </main>
    <Rodape />
  </div>
</template>

<style scoped>
.pagina-institucional { min-height: 100vh; background: var(--fundo-pagina); color: var(--texto-corpo); font: var(--fonte-interface); }
.conteudo { max-width: 960px; margin: 0 auto; padding: var(--espaco-64) var(--espaco-24); }
.abertura { max-width: 740px; margin-bottom: var(--espaco-48); }
h1 { margin: var(--espaco-16) 0; color: var(--texto-principal); font: var(--fonte-display); }
h2 { margin-bottom: var(--espaco-16); color: var(--texto-principal); font: var(--fonte-titulo-cartao); }
p { margin: 0 0 var(--espaco-16); line-height: 1.75; }
.introducao { font: var(--fonte-corpo); }
section { max-width: 760px; margin-bottom: var(--espaco-48); }
.chamada { display: flex; align-items: center; justify-content: space-between; gap: var(--espaco-24); padding: var(--espaco-32); border-radius: var(--raio-20); background: var(--fundo-suave); }
.chamada p { margin: 0; }
.nota { margin-top: var(--espaco-48); color: var(--texto-secundario); font: var(--fonte-legenda); }
@media (max-width: 600px) { h1 { font-size: 2.1rem; } .chamada { align-items: flex-start; flex-direction: column; } }
</style>
