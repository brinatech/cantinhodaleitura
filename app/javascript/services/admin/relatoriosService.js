// Relatórios da biblioteca, só para administradores (API: /api/v1/admin/relatorios, HU-22).
import { chamarApi } from '../api.js'

// inicio e fim: 'AAAA-MM-DD' (sem eles, o mês atual). Devolve:
// { periodo, dados_desde, livros: { total, novos_no_periodo, por_mes: [{ mes, total }] },
//   leitores_cadastrados, acessos: { visualizacao|leitura|download: { total, leitores, visitantes } },
//   mais_acessados: [{ livro_id, titulo, leituras, visualizacoes, downloads, total }] }
export function buscarResumo({ inicio, fim } = {}) {
  const busca = new URLSearchParams()
  if (inicio) busca.set('inicio', inicio)
  if (fim) busca.set('fim', fim)
  const texto = busca.toString()
  return chamarApi('GET', `/api/v1/admin/relatorios/resumo${texto ? `?${texto}` : ''}`)
}
