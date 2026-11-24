<!--
  Minhas listas de leitura (HU-13 Task 4). Sem tela no Figma: segue Favoritos/Histórico.
  Formulário para criar uma lista nova e a grade com as listas do leitor (a mexida mais
  recentemente primeiro). Cada card mostra até 3 capas, o nome, a descrição e quantos livros tem,
  e leva ao detalhe da lista (onde se edita, exclui e tira livros).
-->
<script setup>
import { onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import LayoutLogado from '../components/layout/LayoutLogado.vue'
import FormLista from '../components/listas/FormLista.vue'
import Alerta from '../components/ui/Alerta.vue'
import Botao from '../components/ui/Botao.vue'
import EstadoVazio from '../components/ui/EstadoVazio.vue'
import Icone from '../components/ui/Icone.vue'
import { chaveCategoria } from '../components/ui/categorias.js'
import { criarLista, listarListas } from '../services/listasService.js'

const listas = ref([])
const carregando = ref(true)
const erro = ref(false)

const salvando = ref(false)
const errosServidor = ref({})
const erroCriar = ref('')
const aviso = ref('')
const formulario = ref(null) // remonta o formulário para limpar os campos depois de criar

async function carregar() {
  carregando.value = true
  erro.value = false
  try {
    listas.value = await listarListas()
  } catch {
    erro.value = true
  } finally {
    carregando.value = false
  }
}

async function criar(dados) {
  salvando.value = true
  errosServidor.value = {}
  erroCriar.value = ''
  aviso.value = ''
  try {
    const nova = await criarLista(dados)
    listas.value = [nova, ...listas.value]
    aviso.value = `Lista "${nova.nome}" criada.`
    formulario.value = Date.now()
  } catch (falha) {
    if (falha.status === 422) errosServidor.value = falha.erros ?? {}
    else erroCriar.value = 'Não foi possível criar a lista. Tente de novo.'
  } finally {
    salvando.value = false
  }
}

const quantos = (total) => (total === 1 ? '1 livro' : `${total} livros`)

onMounted(carregar)
</script>

<template>
  <LayoutLogado>
    <div class="listas">
      <header class="listas-topo">
        <h1 class="listas-titulo">Listas de leitura</h1>
        <p class="listas-subtitulo">Organize seus livros do seu jeito: por tema, por momento, por quem vai ler junto.</p>
      </header>

      <section class="listas-cartao" aria-labelledby="titulo-nova-lista">
        <h2 id="titulo-nova-lista" class="listas-cartao-titulo">Nova lista</h2>
        <FormLista :key="formulario" :salvando="salvando" :erros-servidor="errosServidor" @salvar="criar" />
        <Alerta v-if="erroCriar" tipo="erro">{{ erroCriar }}</Alerta>
        <Alerta v-if="aviso" tipo="sucesso">{{ aviso }}</Alerta>
      </section>

      <p v-if="carregando" class="listas-aviso" role="status">Carregando suas listas…</p>

      <EstadoVazio
        v-else-if="erro"
        class="listas-estado"
        titulo="Não conseguimos carregar suas listas"
        descricao="Verifique sua conexão e tente de novo."
      >
        <template #acao><Botao tipo="contorno" @click="carregar">Tentar de novo</Botao></template>
      </EstadoVazio>

      <EstadoVazio
        v-else-if="!listas.length"
        class="listas-estado"
        titulo="Você ainda não tem listas"
        descricao="Crie a primeira acima. Depois, na página de um livro, use &quot;Adicionar à lista&quot;."
      />

      <section v-else aria-labelledby="titulo-minhas-listas" class="listas-secao">
        <h2 id="titulo-minhas-listas" class="listas-cartao-titulo">Minhas listas ({{ listas.length }})</h2>

        <ul class="listas-grade">
          <li v-for="lista in listas" :key="lista.id">
            <article class="lista-card">
              <!-- Até 3 capas, uma do lado da outra; sem livros, um ícone -->
              <div class="lista-capas" aria-hidden="true">
                <template v-if="lista.capas.length">
                  <div
                    v-for="livro in lista.capas"
                    :key="livro.id"
                    class="lista-capa"
                    :class="`cat-${chaveCategoria(livro.categoria?.nome)}`"
                  >
                    <img v-if="livro.capa_url" :src="livro.capa_url" alt="">
                    <Icone v-else nome="livro" :tamanho="28" />
                  </div>
                </template>
                <div v-else class="lista-capa lista-capa--vazia"><Icone nome="lista" :tamanho="32" /></div>
              </div>

              <h3 class="lista-nome">
                <RouterLink class="lista-link" :to="`/listas-de-leitura/${lista.id}`">{{ lista.nome }}</RouterLink>
              </h3>
              <p v-if="lista.descricao" class="lista-descricao">{{ lista.descricao }}</p>
              <p class="lista-total">{{ quantos(lista.total_livros) }}</p>
            </article>
          </li>
        </ul>
      </section>
    </div>
  </LayoutLogado>
</template>

<style scoped>
.listas {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-32);
  max-width: 1096px; /* mesma largura do Acervo */
  margin-inline: auto;
}

.listas-topo {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
}

.listas-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.listas-subtitulo,
.listas-aviso {
  color: var(--texto-secundario);
  font: var(--fonte-corpo);
}

.listas-cartao {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-16);
  max-width: 560px;
  padding: var(--espaco-24);
  border-radius: var(--raio-20);
  background: var(--fundo-superficie);
  box-shadow: var(--sombra-cartao);
}

.listas-cartao-titulo {
  color: var(--texto-principal);
  font: var(--fonte-subtitulo);
}

.listas-secao {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-16);
}

.listas-estado {
  align-self: center;
}

.listas-grade {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(min(240px, 100%), 1fr));
  gap: 20px;
  list-style: none;
}

/* ===== Card de lista: o card inteiro é clicável (o link do nome cobre tudo) ===== */
.lista-card {
  position: relative;
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
  height: 100%;
  padding: var(--espaco-16);
  border: 1px solid var(--borda-padrao);
  border-radius: var(--raio-20);
  background: var(--fundo-pagina);
  box-shadow: var(--sombra-cartao);
}

.lista-card:has(.lista-link:focus-visible) {
  border-color: var(--borda-foco);
  box-shadow: inset 0 0 0 2px var(--borda-foco), var(--sombra-cartao);
}

.lista-capas {
  display: flex;
  gap: var(--espaco-8);
  height: 120px;
  margin-bottom: var(--espaco-4);
}

.lista-capa {
  position: relative;
  display: grid;
  flex: 1;
  place-items: center;
  overflow: hidden;
  border-radius: var(--raio-12);
  background: var(--cat-capa);
  color: var(--texto-principal);
}

.lista-capa img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.lista-capa--vazia {
  background: var(--fundo-nuvem);
}

.lista-nome {
  color: var(--texto-principal);
  font: var(--fonte-botao);
}

.lista-link {
  color: inherit;
  text-decoration: none;
}

.lista-link:focus-visible {
  outline: none; /* o foco aparece na borda do card */
}

.lista-link::after {
  content: '';
  position: absolute;
  inset: 0;
}

.lista-descricao {
  display: -webkit-box;
  overflow: hidden;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  color: var(--texto-corpo);
  font: var(--fonte-legenda);
}

.lista-total {
  margin-top: auto;
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}
</style>
