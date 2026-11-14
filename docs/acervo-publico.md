# Acervo: livros da API e acervo público

## Resumo

- **Livros da API:** as duas telas de acervo carregam os livros do `GET /api/v1/livros`, o endpoint de catálogo da branch `feat/public-catalog-api`.
- **Acervo público:** a rota `/acervo-publico` deixou de mostrar "Em breve" e virou a tela de acervo para quem não está logado.
- **Mesma estante nas duas telas:** os acervos logado e público usam o mesmo `CatalogoLivros` (filtros, busca e cards) e o mesmo `livrosService`.
- **Design system:** o acervo público usa o `CampoBusca` e os tokens de `styles/tokens.css`, como o resto do site.

## Como funciona

### Carregando os livros

Quando a tela abre, ela chama o `listarLivros()` e mostra **uma** destas três coisas:

| Situação | O que aparece |
|---|---|
| Esperando a resposta | "Carregando livros…" (o leitor de tela anuncia, com `role="status"`) |
| A API falhou | `EstadoVazio` "Não conseguimos carregar o acervo", com o botão **"Tentar de novo"** |
| Os livros chegaram | O `CatalogoLivros`, com filtros, busca e cards |

O `CatalogoLivros` não mudou para receber os livros da API: os livros de exemplo já estavam no mesmo formato do JSON do endpoint.

### Busca

- **Acervo logado (`/acervo`):** a busca é a da barra superior do `LayoutLogado` e acontece ao apertar Enter.
- **Acervo público (`/acervo-publico`):** o visitante não tem essa barra, então o campo fica na própria página, ao lado do título, e filtra **enquanto a pessoa digita**.

Nos dois casos, o termo vai para a URL (`?busca=lua`), procura em título e autor, ignora maiúsculas e acentos, e combina com os chips de categoria e "Com audiobook". A busca e os filtros ainda acontecem **no navegador** (ver Pendências).

## Testando no seu computador

O banco local começa vazio, e sem livros as telas mostram "Nenhum livro encontrado".

1. Pegue o `livros_teste.rb` com quem já tem (ele fica em `tmp/`, que não vai para o git) e coloque na pasta `tmp/` do projeto.
2. Rode:
   ```bash
   bundle exec rails runner tmp/livros_teste.rb
   ```
   Ele cria 1 usuário administrador, 4 categorias (Aventura, Clássicos, Fantasia e Natureza) e 12 livros. Pode rodar mais de uma vez: ele não duplica nada.
3. Com o `bin/dev` rodando, abra `http://localhost:3000/#/acervo` e `http://localhost:3000/#/acervo-publico`.

> **Ruby 4.0 no Windows:** o `rails console` não abre, porque falta a gem `fiddle`. O `rails runner` funciona normalmente.

### O que conferir

| Teste | Resultado esperado |
|---|---|
| Abrir uma das telas | Os 12 livros do banco |
| Chip de categoria / "Com audiobook" | Só os livros daquela categoria / com áudio |
| Buscar "lua" | Só "A menina que conversava com a Lua"; a URL ganha `?busca=lua` |
| F12 → aba Rede | O pedido `livros` com status `200` |
| Erro: trocar `/api/v1/livros` por `/api/v1/livrosX` no service | O aviso de erro com "Tentar de novo" (desfaça a troca depois) |


