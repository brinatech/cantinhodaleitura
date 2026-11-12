<!--
  Card de livro · carregando (Figma). Esqueleto exibido enquanto o acervo carrega.
  O container da lista deve ter aria-busy="true" enquanto carrega; aqui o
  esqueleto também avisa. Sem animação, para respeitar quem pede menos movimento.
-->
<template>
  <div class="esqueleto" aria-busy="true">
    <span class="bloco selo"></span>
    <span class="bloco capa"></span>
    <span class="bloco titulo"></span>
    <span class="bloco autor"></span>
    <span class="bloco formato"></span>
  </div>
</template>

<style scoped>
.esqueleto {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--espaco-12);
  width: 100%;
  padding: var(--espaco-16);
  border: 1px solid var(--borda-padrao);
  border-radius: var(--raio-20);
  background: var(--fundo-pagina);
}

.bloco {
  display: block;
  flex-shrink: 0;
  border-radius: var(--raio-8);
  background: var(--fundo-suave);
}

.selo {
  width: 120px;
  height: 10px;
}

.capa {
  width: 100%;
  height: 260px;
  border-radius: var(--raio-12);
}

.titulo {
  width: 200px;
  height: 18px;
}

.autor {
  width: 120px;
  height: 14px;
}

.formato {
  width: 150px;
  height: 28px;
}
</style>
