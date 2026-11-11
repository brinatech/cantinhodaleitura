<template>
  <header class="cabecalho">
    <div class="cabecalho-faixa">
      <img class="cabecalho-logo" src="../images/logo-header.png" alt="Cantinho da Leitura">
      <nav aria-label="Menu principal">
        <ul>
          <li><a href="#inicio">Início</a></li>
          <li><a href="#sobre">Sobre</a></li>
          <li><a href="#acervo">Acervo</a></li>
        </ul>
      </nav>
    </div>

    <button class="entrar-btn">Entrar</button>
  </header>
</template>

<style scoped>
/* O cabeçalho ocupa seu espaço normal na página.
   Na tela inicial, a HomeView faz ele flutuar em cima do banner. */
.cabecalho {
  position: relative;
  z-index: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-family: 'Inter', sans-serif;
  /* sem background: transparente */
}

.cabecalho-faixa {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 75%;                         /* até onde vai o branco */
  padding: 10px 10vw 10px 160px;      /* espaço à direita do nav acompanha a largura da tela */
  background-color: white;
  border-bottom-right-radius: 40px;   /* o canto arredondado */
}

.cabecalho nav ul {
  display: flex;
  gap: 120px;
  list-style: none;
}

.cabecalho nav a {
  font-size: 16px;
  font-weight: 500;
  color: #436F86;
  text-decoration: none;
  transition: color 0.3s;
}

.cabecalho nav a:hover {
  color: #5bc8f5;
}

.entrar-btn {
  margin-right: 160px;
  padding: 10px 40px;
  border: none;
  border-radius: 8px;
  background-color: #5bc8f5;
  color: #284859;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  transition: transform 0.3s ease, box-shadow 0.3s ease, background-color 0.3s ease;
}

.entrar-btn:hover,
.entrar-btn:focus-visible {
  background-color: #3fb8ec;                        /* azul um tom mais forte */
  box-shadow: 0 8px 18px rgba(29, 85, 119, 0.35);   /* sombra azulada */
}

.entrar-btn:active {
  box-shadow: 0 3px 8px rgba(29, 85, 119, 0.3);
}

.entrar-btn:focus-visible {
  outline: 3px solid #1d5577;
  outline-offset: 3px;
}
</style>
