// Conversa com a API de livros do Rails.
// GET /api/v1/livros → lista de livros no formato { id, titulo, autor, capa_url, categoria, formatos }
// params opcionais, os mesmos do backend (LivrosQuery): ex. { ordem: 'recentes' }
export async function listarLivros(params = {}) {
  const busca = new URLSearchParams(params).toString()
  const resposta = await fetch(`/api/v1/livros${busca ? `?${busca}` : ''}`, { headers: { Accept: 'application/json' } })

  // fetch só falha sozinho se a internet cair; erro do servidor (404, 500) a gente verifica aqui
  if (!resposta.ok) throw new Error(`Erro ${resposta.status} ao carregar os livros`)

  return resposta.json()
}

export class ErroApiLivros extends Error {
  constructor(mensagem, status) {
    super(mensagem)
    this.name = 'ErroApiLivros'
    this.status = status
  }
}

const livroValido = (dados) =>
  dados !== null &&
  typeof dados === 'object' &&
  !Array.isArray(dados) &&
  dados.id !== null &&
  dados.id !== undefined &&
  typeof dados.titulo === 'string' &&
  dados.titulo.trim() !== ''

const buscarJson = async (url, signal) => {
  const resposta = await fetch(url, {
    headers: { Accept: 'application/json' },
    signal,
  })

  let dados = null
  try {
    dados = await resposta.json()
  } catch {
    // O corpo pode não ser JSON em uma falha inesperada da API.
  }

  if (!resposta.ok) {
    throw new ErroApiLivros(dados?.erro || 'Não foi possível carregar o livro.', resposta.status)
  }

  return dados
}

export async function buscarLivro(id, { signal } = {}) {
  const dados = await buscarJson(`/api/v1/livros/${encodeURIComponent(id)}`, signal)

  if (!livroValido(dados)) {
    throw new ErroApiLivros('A API retornou um livro inválido.', 200)
  }

  return dados
}
