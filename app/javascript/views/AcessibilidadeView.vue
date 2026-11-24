<script setup>
import MenuSuperior from '../components/layout/MenuSuperior.vue'
import Rodape from '../components/layout/Rodape.vue'
import Botao from '../components/ui/Botao.vue'
</script>

<template>
  <div class="pagina-institucional">
    <MenuSuperior />
    <main class="conteudo" aria-labelledby="titulo-acessibilidade">
      <header class="abertura">
        <p class="sobretitulo">Cantinho da Leitura</p>
        <h1 id="titulo-acessibilidade">Acessibilidade e ajustes de leitura</h1>
        <p class="introducao">Conheça os recursos disponíveis para adaptar a leitura às suas preferências.</p>
      </header>

      <section aria-labelledby="ajustes">
        <h2 id="ajustes">Ajuste a experiência</h2>
        <p>Use o botão “Acessibilidade” no menu para abrir os ajustes de leitura. No painel, você pode alterar o tamanho do texto e o espaço entre linhas, escolher tema claro ou escuro e ativar leitura em voz alta, alto contraste ou modo calmo.</p>
        <p>As preferências são guardadas neste navegador. Você pode voltar ao painel quando quiser para modificá-las.</p>
      </section>

      <section aria-labelledby="formatos">
        <h2 id="formatos">Leia ou ouça</h2>
        <p>Alguns títulos podem oferecer leitura em texto ou áudio. A disponibilidade depende dos arquivos e formatos cadastrados para cada livro. Na página de um título, confira as opções apresentadas.</p>
      </section>

      <section aria-labelledby="ajuda">
        <h2 id="ajuda">Encontrou uma barreira?</h2>
        <p>Este projeto está em desenvolvimento. Se algum recurso não funcionar como esperado, conte à equipe responsável pelo projeto para que a experiência possa ser aprimorada.</p>
        <Botao tipo="contorno" to="/sobre">Conheça o projeto</Botao>
      </section>
    </main>
    <Rodape />
  </div>
</template>

<style scoped>
.pagina-institucional { min-height: 100vh; background: var(--fundo-pagina); color: var(--texto-corpo); font: var(--fonte-interface); }
.conteudo { max-width: 960px; margin: 0 auto; padding: var(--espaco-64) var(--espaco-24); }
.abertura { max-width: 740px; margin-bottom: var(--espaco-48); }
.sobretitulo { color: var(--texto-secundario); font: var(--fonte-rotulo); letter-spacing: var(--letras-rotulo); text-transform: uppercase; }
h1 { margin: var(--espaco-16) 0; color: var(--texto-principal); font: var(--fonte-display); }
h2 { margin-bottom: var(--espaco-16); color: var(--texto-principal); font: var(--fonte-titulo-cartao); }
p { margin: 0 0 var(--espaco-16); line-height: 1.75; }
.introducao { font: var(--fonte-corpo); }
section { max-width: 760px; margin-bottom: var(--espaco-48); }
@media (max-width: 600px) { h1 { font-size: 2.1rem; } }
</style>
