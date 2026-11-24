import { chamarApi } from '../api.js'

const CAMINHO = '/api/v1/admin/usuarios'

export const listarUsuarios = () => chamarApi('GET', CAMINHO)

export const atualizarUsuario = (id, dados) =>
  chamarApi('PATCH', `${CAMINHO}/${encodeURIComponent(id)}`, { usuario: dados })
