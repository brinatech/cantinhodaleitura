// Cadastro, sessão e recuperação de senha (API do Rails: ver config/routes.rb).
import { chamarApi, ErroApi } from './api.js'

// Quem está logado agora, ou null (a sessão vive no cookie; 401 só quer dizer "sem login")
export async function usuarioAtual() {
  try {
    return await chamarApi('GET', '/api/v1/sessao')
  } catch (erro) {
    if (erro instanceof ErroApi && erro.status === 401) return null
    throw erro
  }
}

export const entrar = (email, senha) => chamarApi('POST', '/api/v1/sessao', { email, password: senha })

export const cadastrar = ({ nome, email, senha }) =>
  chamarApi('POST', '/api/v1/usuarios', { usuario: { nome, email, password: senha } })

export const sair = () => chamarApi('DELETE', '/api/v1/sessao')

export const solicitarRecuperacao = (email) => chamarApi('POST', '/api/v1/recuperacao_senha', { email })

export const redefinirSenha = (token, senha) =>
  chamarApi('PATCH', '/api/v1/recuperacao_senha', { token, password: senha })
