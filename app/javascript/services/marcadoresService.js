// Marcador de página do leitor logado (API do Rails: /api/v1/marcadores_pagina/:livro_id, HU-15).
import { chamarApi } from './api.js'

// { livro_id, pagina_atual, localizacao, data_atualizacao } ou null (ainda não tem marcador neste livro)
export const buscarMarcador = (livroId) => chamarApi('GET', `/api/v1/marcadores_pagina/${livroId}`)

export const salvarMarcador = (livroId, paginaAtual) =>
  chamarApi('PUT', `/api/v1/marcadores_pagina/${livroId}`, { pagina_atual: paginaAtual })
