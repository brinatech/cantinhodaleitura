// Histórico de leitura do leitor logado (API do Rails: /api/v1/historico, HU-14).
import { chamarApi } from './api.js'

// Avisa que leu a página "pagina" de "totalPaginas". O servidor guarda as datas e o progresso (que só aumenta).
export const registrarLeitura = (livroId, pagina, totalPaginas) =>
  chamarApi('PUT', `/api/v1/historico/${livroId}`, { pagina, total_paginas: totalPaginas })
