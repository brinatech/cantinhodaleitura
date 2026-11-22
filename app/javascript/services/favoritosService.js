// Favoritos do leitor logado (API do Rails: /api/v1/favoritos, HU-12).
// Os erros (401 sem login, 404, 409 já favorito) chegam como ErroApi: quem chama decide o que fazer.
import { chamarApi } from './api.js'

// [{ livro_id, data_favorito, livro: { id, titulo, autor, capa_url, categoria } }], do mais recente ao mais antigo
export const listarFavoritos = () => chamarApi('GET', '/api/v1/favoritos')

export const favoritar = (livroId) => chamarApi('POST', '/api/v1/favoritos', { livro_id: livroId })

export const desfavoritar = (livroId) => chamarApi('DELETE', `/api/v1/favoritos/${livroId}`)
