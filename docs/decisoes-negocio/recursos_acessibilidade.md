# Recursos de acessibilidade do material

HU-17 Task 1. Define quais recursos de acessibilidade o sistema reconhece em cada livro, como eles são
representados e de onde vem cada um.

**Status: decisão da equipe, sem validação da SESFA.** A equipe não tem contato com a SESFA e decidiu seguir
sem esperar. Se a SESFA validar depois, esta lista pode mudar (o que muda está na seção 5).

## 1. Quais recursos

| Recurso (nome exato) | Quem oferece | Situação na v1 |
|---|---|---|
| Leitura em voz alta | O leitor, com a voz do navegador (`speechSynthesis`), para o texto do PDF | Funciona. Declarar no livro é opcional. |
| Alto contraste | A plataforma inteira, pelo painel "Ajustes de leitura" | Funciona. Declarar no livro é opcional. |
| Audiodescrição | Arquivo de áudio alternativo | **Só declarado.** Ainda não há onde guardar o arquivo (seção 3). |
| Libras | Vídeo em Libras | **Só declarado.** Mesma limitação. |
| Legendas | Arquivo de legenda para o áudio ou vídeo | **Só declarado.** Mesma limitação. |
| Texto alternativo em imagens | Descrição das imagens do material | **Só declarado.** Vale quando o material foi preparado com isso. |

"Declarado" quer dizer: o administrador informou que o material tem o recurso. A tela mostra a declaração
na lista "Informado no cadastro deste livro" e **não** cria botão nem player para ela.

## 2. Como é representado (sem tabela nova)

- Cada recurso é uma linha da tabela `classificacaos` com `tipo = "acessibilidade"` e `nome` igual a um dos
  nomes da tabela acima. O campo `descricao` é livre (ex.: "Narração em português, 12 min").
- O model `Classificacao` aceita só esses nomes quando o tipo é `acessibilidade` (`RECURSOS_ACESSIBILIDADE`).
  Classificações antigas com outro nome continuam sendo exibidas; só não podem ser salvas de novo.
- O admin escolhe o recurso numa lista fechada no editor de classificações (`/#/admin/livros/:id/classificacoes`),
  para não aparecerem "Libras", "libras" e "LIBRAS" como recursos diferentes.
- A API pública do livro (`GET /api/v1/livros/:id`) já devolve `classificacoes`. O leitor filtra as de tipo
  `acessibilidade`.
- A busca do catálogo já filtra por elas: `GET /api/v1/livros?tipo_classificacao=acessibilidade&classificacao=Libras`.

## 3. Arquivos alternativos (legenda, Libras, audiodescrição)

- O DER não tem tabela de anexos, e `ArquivoMaterial` só aceita os tipos `texto` e `audio`. **Não implementado.**
- Proposta para quando houver necessidade: ampliar `ArquivoMaterial::TIPOS` (`audiodescricao`, `libras`,
  `legenda`) com uma migration nova, sem editar as antigas, e um campo `idioma`. Cada arquivo alternativo
  aponta para o livro (`livro_id`), e o arquivo principal continua sendo o `texto`/`audio` já existente.
- Formato sugerido: legenda em `.vtt`; Libras em vídeo `.mp4`; audiodescrição em `.mp3`. Idioma padrão `pt-BR`.
  Hoje os tipos MIME permitidos não incluem vídeo nem `.vtt`, então isso exige mudar a lista de permitidos.
- Enquanto isso não existir, esses recursos aparecem só como declaração.

## 4. Regras de exibição

- Ausência de recurso não aparece como disponibilidade. Recurso declarado sem arquivo não tem botão.
- Leitura em voz alta só é oferecida no leitor de PDF (livro com `texto`), e a tela avisa se o navegador ou
  a página (PDF de imagem) não permitem.

## 5. O que muda se a SESFA validar depois

- **Lista de recursos diferente:** editar `RECURSOS_ACESSIBILIDADE` em `app/models/classificacao.rb` e o espelho
  em `app/javascript/services/tiposClassificacao.js`. Registros antigos não são apagados.
- **Arquivos alternativos obrigatórios:** implementar a seção 3.
