// v-aparecer: o bloco aparece (fade + sobe um pouco) quando entra na tela ao rolar a página.
// Uso: <section v-aparecer>. Pensado para páginas de apresentação (a home), não para telas de uso.
// Não usar no que já está visível ao abrir a página: isso já tem o fade do <main> (styles/animacoes.css).
// Não usar direto num componente que já tem "transition" própria (ex.: Botao): a dele ganha e o efeito some.
// Nesses casos, pôr num elemento em volta.
//
// - Acontece uma vez só: subir e descer de novo não esconde o bloco.
// - Com "reduzir movimento": só o fade, sem subir (regra no styles/animacoes.css).
// - Sem efeito (o bloco já fica visível) no modo calmo ou em navegador sem IntersectionObserver.
//   Se este código nem rodar, nada fica escondido, porque quem esconde é a classe "revelar", que só ele põe.
// - Quem navega com Tab até um bloco ainda escondido faz ele aparecer na hora.
// - Grade com cascata dentro (aparecer-em-cascata) só começa quando o bloco aparece.

const semMovimento = () =>
  document.documentElement.hasAttribute('data-calmo') || typeof IntersectionObserver === 'undefined'

function revelar(el) {
  el.classList.add('revelado')
  el._aparecer?.observador.disconnect()
  el.removeEventListener('focusin', el._aparecer?.aoFocar)
}

export default {
  mounted(el) {
    if (semMovimento()) return

    el.classList.add('revelar')
    const observador = new IntersectionObserver(
      (entradas) => {
        if (entradas.some((entrada) => entrada.isIntersecting)) revelar(el)
      },
      // Aparece quando 15% do bloco entrou na tela (um pouco antes do fim da tela, para não parecer atrasado)
      { threshold: 0.15, rootMargin: '0px 0px -40px 0px' },
    )
    const aoFocar = () => revelar(el)

    el._aparecer = { observador, aoFocar }
    el.addEventListener('focusin', aoFocar)
    observador.observe(el)
  },

  unmounted(el) {
    el._aparecer?.observador.disconnect()
    el.removeEventListener('focusin', el._aparecer?.aoFocar)
  },
}
