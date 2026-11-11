<script>
    export default {
        name: 'BannerCarrossel'
    }
</script>

<template>
  <section class="banner">
    <div class="banner-conteudo">
      <span class="banner-tag">Leitura que acolhe</span>

      <h1>Um mundo de histórias.<br>Um cantinho para você.</h1>

      <p>Leia, ouça e descubra novas possibilidades. No seu tempo, do seu jeito.</p>

      <a href="#acervo" class="banner-botao">Explorar o acervo</a>
    </div>

    <div class="banner-pontos">
      <button class="ponto ativo" aria-label="Slide 1"></button>
      <button class="ponto" aria-label="Slide 2"></button>
      <button class="ponto" aria-label="Slide 3"></button>
    </div>
  </section>
</template>

<style scoped>
.banner {
  position: relative;                 /* referência para os pontinhos */
  display: flex;
  align-items: flex-end;              /* joga o conteúdo para baixo */
  height: 615px;
  padding: 0 0 45px 130px;            /* distância da borda esquerda e de baixo */
  border-radius: 0 0 30px 30px;       /* cantos de baixo arredondados */
  overflow: hidden;
  color: white;

  /* gradiente escuro à esquerda + imagem */
  background-image:
    linear-gradient(
      to right,
      rgba(0, 0, 0, 0.8) 0%,
      rgba(0, 0, 0, 0.5) 35%,
      transparent 65%
    ),
    url('../images/img-banner.png');

  background-size: cover;
  background-position: center;
}

.banner-conteudo {
  max-width: 520px;
}

.banner-tag {
  display: inline-block;
  padding: 10px 40px;
  border-radius: 6px;
  background-color: #5bc8f5;
  color: #0d3b66;
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
}

.banner h1 {
  margin: 10px 0 8px;
  font-size: 40px;
  line-height: 1.2;
}

.banner p {
  font-size: 16px;
}

.banner-botao {
  display: inline-block;
  margin-top: 40px;
  padding: 14px 56px;
  border-radius: 6px;
  background-color: #5bc8f5;
  color: #0d3b66;
  font-weight: 700;
  text-decoration: none;
  transition: transform 0.3s ease, box-shadow 0.3s ease, background-color 0.3s ease;
}

.banner-botao:hover,
.banner-botao:focus-visible {
  transform: translateY(-3px);                      /* sobe um pouquinho */
  background-color: #3fb8ec;                        /* azul um tom mais forte */
  box-shadow: 0 8px 18px rgba(29, 85, 119, 0.35);   /* sombra azulada */
}

.banner-botao:active {
  transform: translateY(0);                         /* "afunda" ao clicar */
  box-shadow: 0 3px 8px rgba(29, 85, 119, 0.3);
}

/* Contorno visível para quem navega pelo teclado */
.banner-botao:focus-visible {
  outline: 3px solid #1d5577;
  outline-offset: 3px;
}

/* Mesmo comportamento que estava na HomeView: o botão não sobe no hover.
   Apague este bloco para ele voltar a subir. */
.banner-botao:hover,
.banner-botao:focus-visible {
  transform: none;
}

.banner-pontos {
  position: absolute;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);        /* centraliza na horizontal */
  display: flex;
  gap: 16px;
}

.ponto {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background-color: white;
}

.ponto.ativo {
  background-color: #5bc8f5;
}
</style>
