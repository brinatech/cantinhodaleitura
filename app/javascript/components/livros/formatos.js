// Formatos de um livro como vêm da API ({ formatos: [{ tipo: 'texto' | 'audio' }] }) → o que o card mostra.

export const temAudio = (livro) => livro.formatos?.some((formato) => formato.tipo === 'audio') ?? false

// Texto da tag do CardLivro ("Texto e audiobook", "Audiobook", "Texto"); sem arquivo, vazio (sem tag)
export function textoFormato(livro) {
  const tipos = (livro.formatos ?? []).map((formato) => formato.tipo)
  if (tipos.includes('texto') && tipos.includes('audio')) return 'Texto e audiobook'
  if (tipos.includes('audio')) return 'Audiobook'
  if (tipos.includes('texto')) return 'Texto'
  return ''
}
