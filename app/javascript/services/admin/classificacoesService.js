// Classificações de um livro (API admin do Rails: /api/v1/admin/livros/:livro_id/classificacoes).
// Só administrador: visitante recebe 401 e leitor 403 (ErroApi com o status).
import { chamarApi } from '../api.js'

const caminho = (livroId) => `/api/v1/admin/livros/${encodeURIComponent(livroId)}/classificacoes`

export const listarClassificacoes = (livroId) => chamarApi('GET', caminho(livroId))

export const criarClassificacao = (livroId, { tipo, nome, descricao }) =>
  chamarApi('POST', caminho(livroId), { classificacao: { tipo, nome, descricao } })

export const excluirClassificacao = (livroId, id) =>
  chamarApi('DELETE', `${caminho(livroId)}/${encodeURIComponent(id)}`)
