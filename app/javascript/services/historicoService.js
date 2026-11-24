// Histórico de leitura do leitor logado (API do Rails: /api/v1/historico, HU-14).
import { chamarApi } from './api.js'

// [{ livro_id, data_inicio, data_ultima_leitura, progresso_percentual, pagina_atual, livro: {...} }],
// do lido mais recentemente para o mais antigo. pagina_atual vem do marcador (ou null).
export const listarHistorico = () => chamarApi('GET', '/api/v1/historico')

// Avisa que leu a página "pagina" de "totalPaginas". O servidor guarda as datas e o progresso (que só aumenta).
export const registrarLeitura = (livroId, pagina, totalPaginas) =>
  chamarApi('PUT', `/api/v1/historico/${livroId}`, { pagina, total_paginas: totalPaginas })
