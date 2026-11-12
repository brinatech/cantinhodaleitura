<!--
  Página provisória das rotas que o menu e a home já apontam, mas que ainda não
  foram construídas (Sobre, Acervo, Favoritos, Histórico...).
  Cada tela real troca a sua rota em router/index.js e esta página some.
  Rotas da área logada (meta.logada) aparecem dentro do menu lateral.
  Sem título na rota (meta.titulo), vale como "página não encontrada".
-->
<script setup>
import { useRoute } from 'vue-router'
import LayoutLogado from '../components/layout/LayoutLogado.vue'
import MenuSuperior from '../components/layout/MenuSuperior.vue'
import Rodape from '../components/layout/Rodape.vue'
import Botao from '../components/ui/Botao.vue'
import EstadoVazio from '../components/ui/EstadoVazio.vue'

const rota = useRoute()
</script>

<template>
  <component :is="rota.meta.logada ? LayoutLogado : 'div'">
    <MenuSuperior v-if="!rota.meta.logada" />

    <component :is="rota.meta.logada ? 'div' : 'main'" class="em-breve">
      <EstadoVazio
        :titulo="rota.meta.titulo ? `${rota.meta.titulo}: em breve` : 'Página não encontrada'"
        :descricao="rota.meta.titulo ? 'Essa página ainda está sendo construída.' : 'Esse endereço não existe no Cantinho da Leitura.'"
      >
        <template #acao>
          <Botao :to="rota.meta.logada ? '/minhas-leituras' : '/'">
            {{ rota.meta.logada ? 'Voltar às minhas leituras' : 'Voltar ao início' }}
          </Botao>
        </template>
      </EstadoVazio>
    </component>

    <Rodape v-if="!rota.meta.logada" />
  </component>
</template>

<style scoped>
.em-breve {
  display: flex;
  justify-content: center;
  padding: var(--espaco-64) var(--espaco-24);
  background: var(--fundo-pagina);
}
</style>
