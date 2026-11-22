<!--
  Página admin provisória: editar as classificações de um livro.
  Quando existir a tela admin de livros (HU-07 Task 4), o componente ClassificacoesLivro
  pode ir para dentro dela e esta página deixa de ser necessária.
-->
<script setup>
import { computed, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import LayoutLogado from '../../components/layout/LayoutLogado.vue'
import ClassificacoesLivro from '../../components/admin/ClassificacoesLivro.vue'
import Botao from '../../components/ui/Botao.vue'
import { buscarLivro } from '../../services/livrosService.js'

const rota = useRoute()
const livroId = computed(() => rota.params.id)
const titulo = ref('')

watch(livroId, async (id) => {
  titulo.value = ''
  try {
    titulo.value = (await buscarLivro(id)).titulo
  } catch {
    // Sem título a página continua: o editor mostra o erro (ex.: livro não encontrado)
  }
}, { immediate: true })
</script>

<template>
  <LayoutLogado>
    <div class="admin-pagina">
      <Botao class="admin-voltar" tipo="contorno" :to="`/acervo/${livroId}`">← Voltar ao livro</Botao>

      <div>
        <p class="admin-rotulo">Administração</p>
        <h1 class="admin-titulo">{{ titulo ? `Classificações de "${titulo}"` : 'Classificações do livro' }}</h1>
      </div>

      <ClassificacoesLivro :livro-id="livroId" />
    </div>
  </LayoutLogado>
</template>

<style scoped>
.admin-pagina {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-24);
  max-width: 720px;
  margin-inline: auto;
}

.admin-voltar {
  align-self: flex-start;
}

.admin-rotulo {
  margin-bottom: var(--espaco-4);
  color: var(--texto-secundario);
  font: var(--fonte-rotulo);
  letter-spacing: var(--letras-rotulo);
  text-transform: uppercase;
}

.admin-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}
</style>
