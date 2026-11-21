// Categorias do acervo (API admin do Rails: /api/v1/admin/categorias).
// Só administrador: visitante recebe 401 e leitor 403 (ErroApi com o status).
// Excluir categoria que ainda tem livros devolve 409.
import { chamarApi } from '../api.js'

const CAMINHO = '/api/v1/admin/categorias'
const caminhoDe = (id) => `${CAMINHO}/${encodeURIComponent(id)}`

export const listarCategorias = () => chamarApi('GET', CAMINHO)

export const criarCategoria = ({ nome, descricao }) =>
  chamarApi('POST', CAMINHO, { categoria: { nome, descricao } })

export const editarCategoria = (id, { nome, descricao }) =>
  chamarApi('PATCH', caminhoDe(id), { categoria: { nome, descricao } })

export const excluirCategoria = (id) => chamarApi('DELETE', caminhoDe(id))
