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

/* ===== Responsividade ===== */

/* 2xl */
@media (max-width: 1536px) {
  .cabecalho-faixa {
    padding-left: 120px;
  }

  .cabecalho nav ul {
    gap: 80px;
  }

  .entrar-btn {
    margin-right: 120px;
  }
}

/* xl */
@media (max-width: 1280px) {
  .cabecalho-faixa {
    padding-left: 80px;
  }

  .cabecalho nav ul {
    gap: 56px;
  }

  .entrar-btn {
    margin-right: 80px;
  }
}

/* lg */
@media (max-width: 1024px) {
  .cabecalho-faixa {
    padding-left: 40px;
  }

  .cabecalho nav ul {
    gap: 32px;
  }

  .entrar-btn {
    margin-right: 40px;
  }
}

/* md: o próprio header vira a faixa branca na largura toda.
   Numa linha só: logo à esquerda, menu centralizado, Entrar à direita */
@media (max-width: 768px) {
  .cabecalho {
    gap: 16px;
    padding: 10px 24px;
    background-color: white;
    border-radius: 0 0 24px 24px;
  }

  .cabecalho-faixa {
    flex: 1;                          /* ocupa o espaço entre as bordas e o botão */
    gap: 16px;
    width: auto;
    padding: 0;
    background-color: transparent;    /* o branco agora vem do header */
    border-radius: 0;
  }

  .cabecalho-logo {
    flex-shrink: 0;
    height: 48px;                     /* logo original: 196 x 62 */
  }

  .cabecalho nav {
    flex: 1;
  }

  .cabecalho nav ul {
    justify-content: center;          /* menu centralizado no espaço que sobra */
    gap: 20px;
  }

  .cabecalho nav a {
    font-size: 14px;
  }

  .entrar-btn {
    flex-shrink: 0;
    margin-right: 0;
    padding: 8px 22px;
    font-size: 14px;
  }
}

/* sm */
@media (max-width: 640px) {
  .cabecalho {
    padding: 10px 20px;
  }

  .cabecalho-logo {
    height: 40px;
  }

  .cabecalho nav ul {
    gap: 16px;
  }

  .cabecalho nav a {
    font-size: 13px;
  }

  .entrar-btn {
    padding: 8px 18px;
  }
}

/* xs: sem o logo, para sobrar espaço para o menu */
@media (max-width: 475px) {
  .cabecalho {
    padding: 12px 16px;
  }

  .cabecalho-logo {
    display: none;
  }

  .cabecalho nav ul {
    gap: 20px;
  }

  .cabecalho nav a {
    font-size: 14px;
  }
}
</style>
