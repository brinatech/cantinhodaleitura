<template>
  <footer class="rodape">
    <img class="deco deco-nuvem-rodape" src="../images/imgs-footer/nuvem-footer.png" alt="" aria-hidden="true">

    <div class="rodape-grid">
      <div class="rodape-marca">
        <img src="../images/imgs-footer/logo-footer.png" alt="Cantinho da Leitura">
        <p>Um cantinho para descobrir, imaginar e aprender. Uma iniciativa de leitura que acolhe.</p>
      </div>

      <nav class="rodape-coluna" aria-labelledby="rodape-biblioteca">
        <h2 id="rodape-biblioteca">Biblioteca</h2>
        <ul>
          <li><a href="#sobre">Sobre o projeto</a></li>
          <li><a href="#acervo">Acervo</a></li>
          <li><a href="#acessibilidade">Acessibilidade</a></li>
        </ul>
      </nav>

      <nav class="rodape-coluna" aria-labelledby="rodape-sesfa">
        <h2 id="rodape-sesfa">SESFA</h2>
        <ul>
          <li><a href="#sesfa">ONG parceira</a></li>
          <li><a href="#contato">Contato a definir pela equipe</a></li>
          <li><a href="#redes-sociais">Redes sociais a definir</a></li>
        </ul>
      </nav>

      <div class="rodape-ilustracao" aria-hidden="true">
        <img class="rodape-livro" src="../images/imgs-footer/livro.png" alt="">
        <img class="rodape-garoto" src="../images/imgs-footer/garoto-cadeira.png" alt="">
      </div>
    </div>

    <p class="rodape-copy">
      Cantinho da Leitura · SESFA &nbsp;/&nbsp; Protótipo acadêmico · Conteúdo de demonstração
    </p>
  </footer>
</template>

<style scoped>
.rodape {
  position: relative;
  overflow: hidden;
  padding: 30px 160px 40px;
  background-color: #eef6fd;
  color: #436f86;
}

.deco {
  position: absolute;
  pointer-events: none;
}

.deco-nuvem-rodape {
  left: -40px;
  bottom: -20px;
  width: 340px;
}

.rodape-grid,
.rodape-copy {
  position: relative;
  z-index: 1;                         /* texto na frente da nuvem */
}

.rodape p,
.rodape li {
  font-weight: 500;
}

.rodape-grid {
  display: grid;
  grid-template-columns: 1.3fr 0.9fr 1fr 1.2fr;
  gap: 40px;
  align-items: start;
}

.rodape-marca img {
  width: 160px;
  margin-bottom: 16px;
}

.rodape-marca p {
  max-width: 230px;
  font-size: 13px;
  line-height: 1.6;
}

.rodape-coluna {
  padding-top: 10px;
}

.rodape-coluna h2 {
  margin-bottom: 12px;
  color: #1d5577;
  font-size: 16px;
  font-weight: 700;
}

.rodape-coluna ul {
  list-style: none;
}

.rodape-coluna li {
  font-size: 13px;
  line-height: 1.4;
  color: #526572;
}

.rodape-coluna a {
  color: inherit;
  text-decoration: none;
}

.rodape-coluna a:hover,
.rodape-coluna a:focus-visible {
  color: #1d5577;
  text-decoration: underline;
}

.rodape-ilustracao {
  position: relative;
  width: 220px;
  height: 180px;
}

.rodape-livro {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 220px;
}

.rodape-garoto {
  position: absolute;
  top: 0;
  left: 40px;
  width: 120px;
}

.rodape-copy {
  margin-top: 30px;
  font-size: 13px;
  text-align: center;
  color: #526572;
}

/* Celular / tablet */
@media (max-width: 900px) {
  .rodape {
    padding: 30px 20px;
  }

  .rodape-grid {
    grid-template-columns: 1fr;
  }

  .rodape-ilustracao {
    display: none;
  }
}
</style>
