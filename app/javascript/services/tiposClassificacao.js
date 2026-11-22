// Tipos de classificação aceitos pelo backend (Classificacao::TIPOS no model).
// Lista provisória até a SESFA aprovar a taxonomia: se mudar lá, mude aqui também.
export const TIPOS_CLASSIFICACAO = [
  { valor: 'genero', rotulo: 'Gênero' },
  { valor: 'faixa_etaria', rotulo: 'Faixa etária' },
  { valor: 'formato', rotulo: 'Formato' },
  { valor: 'acessibilidade', rotulo: 'Acessibilidade' },
]

// "faixa_etaria" → "Faixa etária". Tipo desconhecido (dado antigo) aparece como veio.
export const rotuloTipo = (valor) => TIPOS_CLASSIFICACAO.find((tipo) => tipo.valor === valor)?.rotulo ?? valor
