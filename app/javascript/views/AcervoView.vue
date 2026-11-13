<!--
  Acervo (Figma: "Acervo · área logada"). Lista os livros do catálogo com busca e filtros.
  A busca por texto fica na barra de cima (LayoutLogado), que manda para /acervo?busca=...;
  esta tela lê a URL e mostra os livros que combinam (HU-02, Task 2 do backlog).
  A estante (filtros + cards) é o CatalogoLivros, que também servirá ao acervo do visitante.
  shortcut: livros de exemplo fixos, no mesmo formato do GET /api/v1/livros.
  Trocar por livrosService.listar() quando o banco tiver livros cadastrados.
-->
<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import LayoutLogado from '../components/layout/LayoutLogado.vue'
import CatalogoLivros from '../components/livros/CatalogoLivros.vue'

const rota = useRoute()
const roteador = useRouter()

// A busca vem da URL (/acervo?busca=lua), que a barra de cima preenche
const busca = computed(() => (typeof rota.query.busca === 'string' ? rota.query.busca : ''))

// Tira só o ?busca= da URL e mantém o resto; replace: não cria um passo a mais no "voltar"
const limparBusca = () => {
  const { busca: _removida, ...resto } = rota.query
  roteador.replace({ query: resto })
}

const livros = [
  { id: 1, titulo: 'O jardim das pequenas coisas', autor: 'Clara Ribeiro', capa_url: null, categoria: { nome: 'Natureza' }, formatos: [{ tipo: 'texto' }, { tipo: 'audio' }] },
  { id: 2, titulo: 'A menina que conversava com a Lua', autor: 'Ana Martins', capa_url: null, categoria: { nome: 'Fantasia' }, formatos: [{ tipo: 'texto' }, { tipo: 'audio' }] },
  { id: 3, titulo: 'Caminhos de casa', autor: 'Pedro Almeida', capa_url: null, categoria: { nome: 'Aventura' }, formatos: [{ tipo: 'texto' }] },
  { id: 4, titulo: 'O mar que mora em mim', autor: 'Luiza Costa', capa_url: null, categoria: { nome: 'Natureza' }, formatos: [{ tipo: 'texto' }, { tipo: 'audio' }] },
  { id: 5, titulo: 'Sementes de amanhã', autor: 'Marina Santos', capa_url: null, categoria: { nome: 'Natureza' }, formatos: [{ tipo: 'texto' }] },
  { id: 6, titulo: 'As cartas do vento', autor: 'João Oliveira', capa_url: null, categoria: { nome: 'Clássicos' }, formatos: [{ tipo: 'texto' }, { tipo: 'audio' }] },
  { id: 7, titulo: 'O dragão que tinha medo do escuro', autor: 'Lucas Prado', capa_url: null, categoria: { nome: 'Fantasia' }, formatos: [{ tipo: 'audio' }] },
  { id: 8, titulo: 'O mapa do quintal', autor: 'Rita Souza', capa_url: null, categoria: { nome: 'Aventura' }, formatos: [{ tipo: 'texto' }, { tipo: 'audio' }] },
]
</script>

<template>
  <LayoutLogado>
    <div class="acervo">
      <header class="acervo-topo">
        <h1 class="acervo-titulo">Acervo</h1>
        <p class="acervo-subtitulo">Encontre uma história que combine com seu momento.</p>
      </header>

      <CatalogoLivros :livros="livros" :busca="busca" @limpar-busca="limparBusca" />
    </div>
  </LayoutLogado>
</template>

<style scoped>
.acervo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-32);
  max-width: 1096px; /* largura do conteúdo no Figma (igual a Minhas leituras) */
  margin-inline: auto;
}

.acervo-topo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
}

.acervo-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.acervo-subtitulo {
  color: var(--texto-secundario);
  font: var(--fonte-corpo);
}
</style>
