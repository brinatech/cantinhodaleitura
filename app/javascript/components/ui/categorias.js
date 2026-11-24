import './categorias.css'

// Cada categoria tem uma cor. A cor nunca vem sozinha: o nome sempre aparece escrito junto.
// As 4 primeiras são do Figma; infantil, poesia e ciencias foram acrescentadas pela equipe.
export const CATEGORIAS_COM_COR = ['aventura', 'fantasia', 'natureza', 'classicos', 'infantil', 'poesia', 'ciencias']
const conhecidas = CATEGORIAS_COM_COR

// "Fantasia", "clássicos", "NATUREZA " (nome vindo da API) → chave da categoria.
// Categoria que o design ainda não tem cor cai em "neutro".
export function chaveCategoria(nome = '') {
  const chave = nome
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .trim()
    .toLowerCase()
  return conhecidas.includes(chave) ? chave : 'neutro'
}
