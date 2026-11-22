// Livros do acervo (API admin do Rails: /api/v1/admin/livros).
// Só administrador: visitante recebe 401 e leitor 403 (ErroApi com o status).
// Criar e editar vão como FormData, porque levam o arquivo do livro (PDF ou áudio).
import { chamarApi } from '../api.js'

const CAMINHO = '/api/v1/admin/livros'
const caminhoDe = (id) => `${CAMINHO}/${encodeURIComponent(id)}`

// Monta a "caixa" no formato que o Rails espera: livro[titulo], livro[arquivo][tipo]...
function montarFormulario({ titulo, autor, descricao, idCategoria, tipoArquivo, arquivo }) {
  const dados = new FormData()
  dados.append('livro[titulo]', titulo)
  dados.append('livro[autor]', autor)
  dados.append('livro[descricao]', descricao)
  dados.append('livro[id_categoria]', idCategoria)
  // Na edição o arquivo é opcional: só vai na caixa se a pessoa escolheu um novo
  if (arquivo) {
    dados.append('livro[arquivo][tipo]', tipoArquivo)
    dados.append('livro[arquivo][arquivo]', arquivo)
  }
  return dados
}

export const listarLivrosAdmin = () => chamarApi('GET', CAMINHO)

export const criarLivro = (livro) => chamarApi('POST', CAMINHO, montarFormulario(livro))

export const editarLivro = (id, livro) => chamarApi('PATCH', caminhoDe(id), montarFormulario(livro))

export const excluirLivro = (id) => chamarApi('DELETE', caminhoDe(id))
