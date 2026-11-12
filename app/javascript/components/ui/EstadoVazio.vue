<!--
  Estado vazio (Figma: "Estado vazio"). Busca sem resultado, favoritos vazios,
  histórico vazio e erro de carregamento: troque "titulo" e "descricao".
  A ação opcional (ex.: um Botao contorno "Limpar filtros") vai no slot "acao".
-->
<script setup>
import ilustracao from '../../images/ilustracoes/estado-vazio.png'

defineProps({
  titulo: { type: String, required: true },
  descricao: { type: String, default: '' },
  nivel: { type: Number, default: 2, validator: (valor) => valor >= 1 && valor <= 6 },
})
</script>

<template>
  <section class="vazio">
    <img class="vazio-ilustracao" :src="ilustracao" alt="">
    <component :is="`h${nivel}`" class="vazio-titulo">{{ titulo }}</component>
    <!-- Atenção: o Figma define esta descrição em 12px, sem estilo de texto do design system.
         Seguimos o Figma; vale confirmar com o design se não deveria ser a Legenda (14px). -->
    <p v-if="descricao" class="vazio-descricao">{{ descricao }}</p>
    <div v-if="$slots.acao" class="vazio-acao"><slot name="acao" /></div>
  </section>
</template>

<style scoped>
.vazio {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--espaco-16);
  width: 100%;
  max-width: 420px;
  padding: var(--espaco-32);
  border-radius: var(--raio-20);
  background: var(--fundo-nuvem);
  text-align: center;
}

.vazio-ilustracao {
  width: 104px;
  height: 139px;
  object-fit: cover;
}

.vazio-titulo {
  color: var(--texto-principal);
  font: var(--fonte-subtitulo);
}

.vazio-descricao {
  max-width: 356px;
  color: var(--texto-secundario);
  font: 400 0.75rem/normal var(--fonte-familia);
}
</style>
