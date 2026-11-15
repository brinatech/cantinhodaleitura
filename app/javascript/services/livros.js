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

export async function listarLivros({ signal } = {}) {
  const dados = await buscarJson('/api/v1/livros', signal)

  if (!Array.isArray(dados) || !dados.every(livroValido)) {
    throw new ErroApiLivros('A API retornou uma lista de livros inválida.', 200)
  }

  return dados
}
