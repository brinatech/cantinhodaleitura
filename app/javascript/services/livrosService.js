// Conversa com a API de livros do Rails.
// GET /api/v1/livros → lista de livros no formato { id, titulo, autor, capa_url, categoria, formatos }
export async function listarLivros() {
  const resposta = await fetch('/api/v1/livros', { headers: { Accept: 'application/json' } })

  // fetch só falha sozinho se a internet cair; erro do servidor (404, 500) a gente verifica aqui
  if (!resposta.ok) throw new Error(`Erro ${resposta.status} ao carregar os livros`)

  return resposta.json()
}
