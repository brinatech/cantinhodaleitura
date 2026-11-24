// Tipos de classificação aceitos pelo backend (Classificacao::TIPOS no model).
// Lista provisória até a SESFA aprovar a taxonomia: se mudar lá, mude aqui também.
export const TIPOS_CLASSIFICACAO = [
  { valor: 'genero', rotulo: 'Gênero' },
  { valor: 'faixa_etaria', rotulo: 'Faixa etária' },
  { valor: 'formato', rotulo: 'Formato' },
  { valor: 'acessibilidade', rotulo: 'Acessibilidade' },
]

// Recursos que um livro pode declarar no tipo "acessibilidade" (Classificacao::RECURSOS_ACESSIBILIDADE no model).
// Decisão da equipe, sem validação da SESFA: docs/decisoes-negocio/recursos_acessibilidade.md.
export const RECURSOS_ACESSIBILIDADE = [
  'Leitura em voz alta',
  'Audiodescrição',
  'Libras',
  'Legendas',
  'Texto alternativo em imagens',
  'Alto contraste',
]

// "faixa_etaria" → "Faixa etária". Tipo desconhecido (dado antigo) aparece como veio.
export const rotuloTipo = (valor) => TIPOS_CLASSIFICACAO.find((tipo) => tipo.valor === valor)?.rotulo ?? valor
