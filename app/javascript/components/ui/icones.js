// Os 29 ícones do Figma (+ "grafico", criado para os relatórios, fora do Figma), lidos de images/icones/*.svg (traço trocado por currentColor).
// O nome do arquivo é o nome do ícone: "seta-baixo.svg" → "seta-baixo".
const arquivos = import.meta.glob('../../images/icones/*.svg', {
  query: '?raw',
  import: 'default',
  eager: true,
})

export const icones = Object.fromEntries(
  Object.entries(arquivos).map(([caminho, svg]) => [caminho.split('/').pop().replace('.svg', ''), svg]),
)
