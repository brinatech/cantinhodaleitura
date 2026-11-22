// Chamadas à API do Rails que mudam algo ou dependem da sessão (cookie).
// O Rails confere o token CSRF em POST/PATCH/DELETE: a página traz o primeiro na meta tag e
// cada resposta da sessão traz um novo no header X-CSRF-Token (o login troca a sessão e o token).
let tokenCsrf = document.querySelector('meta[name="csrf-token"]')?.content ?? ''

export class ErroApi extends Error {
  // erros: { campo: [mensagens] } como o Rails devolve no 422
  constructor(mensagem, status, erros = {}) {
    super(mensagem)
    this.name = 'ErroApi'
    this.status = status
    this.erros = erros
  }
}

export async function chamarApi(metodo, url, corpo) {
  // FormData = "caixa" com arquivos (upload). Vai do jeito que está, sem virar JSON.
  const ehFormulario = corpo instanceof FormData
  const resposta = await fetch(url, {
    method: metodo,
    credentials: 'same-origin',
    headers: {
      Accept: 'application/json',
      ...(corpo && !ehFormulario && { 'Content-Type': 'application/json' }),
      ...(metodo !== 'GET' && { 'X-CSRF-Token': tokenCsrf }),
    },
    body: ehFormulario ? corpo : corpo ? JSON.stringify(corpo) : undefined,
  })


  tokenCsrf = resposta.headers.get('X-CSRF-Token') || tokenCsrf

  let dados = null
  try {
    dados = await resposta.json()
  } catch {
    // 204 ou corpo que não é JSON (falha inesperada do servidor)
  }

  if (!resposta.ok) {
    throw new ErroApi(dados?.erro ?? 'Não foi possível concluir. Tente de novo.', resposta.status, dados?.erros)
  }

  return dados
}
