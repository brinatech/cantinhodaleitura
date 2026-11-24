// HU-20 (VERSÃO PROPOSTA, aguardando a SESFA): conta de criança/adolescente criada pelo responsável.
// - criarContaMenor: o responsável preenche; a conta nasce bloqueada e ele recebe um link por e-mail.
// - buscarAutorizacao / autorizar / recusar: a página aberta por esse link (sem login; o token é a prova).
import { chamarApi } from './api.js'

export const criarContaMenor = ({ nome, nomeUsuario, senha, responsavelNome, responsavelEmail, autorizo }) =>
  chamarApi('POST', '/api/v1/cadastros_menores', {
    cadastro_menor: {
      nome,
      nome_usuario: nomeUsuario,
      password: senha,
      responsavel_nome: responsavelNome,
      responsavel_email: responsavelEmail,
      autorizo,
    },
  })

const caminhoDo = (token) => `/api/v1/autorizacoes_menor/${encodeURIComponent(token)}`

export const buscarAutorizacao = (token) => chamarApi('GET', caminhoDo(token))
export const autorizar = (token) => chamarApi('PATCH', caminhoDo(token))
export const recusar = (token) => chamarApi('DELETE', caminhoDo(token))
