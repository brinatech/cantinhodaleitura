import './categorias.css'

// Cada categoria tem uma cor. A cor nunca vem sozinha: o nome sempre aparece escrito junto.
const conhecidas = ['aventura', 'fantasia', 'natureza', 'classicos']

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
