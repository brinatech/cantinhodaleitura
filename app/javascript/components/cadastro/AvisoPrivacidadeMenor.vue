<!--
  Aviso de privacidade da conta de criança/adolescente (HU-20, versão proposta).
  Mostrado ao responsável no cadastro e de novo na página de autorização.
  O texto segue docs/decisoes-negocio/cadastro_menores.md: se a regra mudar, mude os dois.
-->
<template>
  <section class="aviso" aria-labelledby="aviso-privacidade-titulo">
    <h2 id="aviso-privacidade-titulo" class="aviso-titulo">O que guardamos e por quê</h2>
    <ul class="aviso-lista">
      <li><strong>Nome ou apelido da criança</strong>: para aparecer no cantinho dela.</li>
      <li><strong>Nome de usuário e senha</strong>: para ela entrar sem precisar de e-mail.</li>
      <li><strong>Nome e e-mail do responsável</strong>: para confirmar a autorização e recuperar a senha.</li>
      <li><strong>O que ela lê na biblioteca</strong> (favoritos, listas, onde parou): só para ela continuar as leituras.</li>
    </ul>
    <p class="aviso-texto">
      Não pedimos data de nascimento, CPF nem documentos. Os dados não são compartilhados com ninguém.
      O responsável pode excluir a conta a qualquer momento em "Meu perfil", e tudo o que identifica a criança é apagado.
    </p>
  </section>
</template>

<style scoped>
.aviso {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-8);
  padding: var(--espaco-16);
  border-radius: var(--raio-12);
  background: var(--fundo-nuvem);
}

.aviso-titulo {
  color: var(--texto-principal);
  font: var(--fonte-botao);
}

.aviso-lista {
  display: flex;
  flex-direction: column;
  gap: var(--espaco-4);
  padding-left: var(--espaco-24);
  color: var(--texto-corpo);
  font: var(--fonte-interface);
}

.aviso-texto {
  color: var(--texto-secundario);
  font: var(--fonte-legenda);
}
</style>
