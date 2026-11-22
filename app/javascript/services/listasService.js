// Listas de leitura do leitor logado (API do Rails: /api/v1/listas_leitura, HU-13).
import { chamarApi } from './api.js'

// [{ id, nome, descricao, data_criacao, total_livros, livro_ids, capas: [{ id, titulo, capa_url, categoria }] }]
export const listarListas = () => chamarApi('GET', '/api/v1/listas_leitura')

// { ...resumo, livros: [{ id, titulo, autor, capa_url, categoria }] }
export const buscarLista = (id) => chamarApi('GET', `/api/v1/listas_leitura/${id}`)

export const criarLista = ({ nome, descricao }) => chamarApi('POST', '/api/v1/listas_leitura', { nome, descricao })

export const salvarLista = (id, { nome, descricao }) =>
  chamarApi('PATCH', `/api/v1/listas_leitura/${id}`, { nome, descricao })

export const excluirLista = (id) => chamarApi('DELETE', `/api/v1/listas_leitura/${id}`)

export const adicionarLivro = (listaId, livroId) =>
  chamarApi('POST', `/api/v1/listas_leitura/${listaId}/livros`, { livro_id: livroId })

export const removerLivro = (listaId, livroId) => chamarApi('DELETE', `/api/v1/listas_leitura/${listaId}/livros/${livroId}`)
