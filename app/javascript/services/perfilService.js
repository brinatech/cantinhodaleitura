// Dados do leitor logado (API do Rails: /api/v1/perfil).
import { chamarApi } from './api.js'

export const buscarPerfil = () => chamarApi('GET', '/api/v1/perfil')

export const salvarPerfil = ({ nome, email }) => chamarApi('PATCH', '/api/v1/perfil', { usuario: { nome, email } })

export const trocarSenha = (senhaAtual, senhaNova) =>
  chamarApi('PATCH', '/api/v1/perfil/senha', { senha_atual: senhaAtual, password: senhaNova })
