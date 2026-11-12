# BIBLIOTECA VIRTUAL ACESSÍVEL – SESFA

## BACKLOG TÉCNICO E FUNCIONAL

**Épicos • Histórias de Usuário • Tasks**

Tecnologias: Ruby on Rails (API) • Vue.js • PostgreSQL Base: Documento de Requisitos Oficial e DER de 10 tabelas Versão de planejamento — 08/11/2026

---

## 1. Apresentação e objetivo

Este documento transforma os requisitos funcionais e não funcionais da Biblioteca Virtual Acessível – SESFA em um backlog organizado por épicos, histórias de usuário, critérios de aceitação e tarefas técnicas executáveis. As tasks indicam comandos iniciais, arquivos a criar ou editar, responsabilidades de cada arquivo, validações, relacionamentos e testes.

A arquitetura considerada é Ruby on Rails no backend, Vue.js no frontend e PostgreSQL no banco de dados. O fluxo de implementação respeita a preferência da equipe: começar pela geração das Models, pois o comando `rails generate model` cria automaticamente a migration correspondente. A migration gerada deverá ser revisada e ajustada antes de executar `db:migrate`.

O backlog contempla os 16 requisitos funcionais e considera os requisitos não funcionais transversais. Onde o documento oficial deixa uma decisão para a SESFA, o item aparece como dependência/decisão pendente, sem inventar uma regra de negócio.

## 2. Premissas e decisões de escopo

- Existem dois tipos de conta: administrador e leitor. O campo `tipo_usuario` da tabela USUARIO diferencia esses perfis. Visitantes sem cadastro podem consultar e acessar materiais públicos, conforme a política da SESFA.
- O leitor não precisa criar conta para consultar o catálogo público. Conta de leitor é necessária para recursos individualizados: favoritos, listas, histórico e marcadores.
- Somente administradores autenticados podem acessar operações administrativas. A autorização deve ser validada no backend, não apenas escondendo botões no Vue.
- Serão utilizadas as dez tabelas do DER inicial: USUARIO, LIVRO, CATEGORIA, ACESSOS\_MATERIAIS, FAVORITOS, LISTAS\_LEITURA, LISTAS\_LEITURA\_LIVROS, HISTORICO\_LEITURA, MARCADORES\_PAGINA e CLASSIFICACOES.
- Não serão criadas tabelas AVALIACOES ou COMENTARIOS nesta versão. O RF12 condiciona essas interações à aprovação; o documento não registra aprovação explícita.
- Não será criada tabela RELATORIOS: os indicadores do RF14 serão calculados por consultas às tabelas USUARIO, LIVRO e ACESSOS\_MATERIAIS.
- Não será criada tabela LOGS\_AUDITORIA na primeira versão. Segurança, autenticação, autorização e proteção de dados serão implementadas na aplicação; auditoria detalhada poderá ser uma evolução.
- A tabela ACESSOS\_MATERIAIS permite `id_usuario` nulo para registrar acesso de visitante. FAVORITOS, LISTAS\_LEITURA, HISTORICO\_LEITURA e MARCADORES\_PAGINA exigem usuário cadastrado.
- A tabela CLASSIFICACOES complementa CATEGORIA: CATEGORIA representa a categoria principal do livro; CLASSIFICACOES guarda atributos adicionais, como gênero, faixa etária, formato e acessibilidade, conforme taxonomia aprovada pela SESFA.
- Os requisitos RF08, RF15 e parte do RF16 dependem de políticas da SESFA: regras de idade, quais materiais são restritos, procedimento de autorização de responsável, dados mínimos de menores, retenção e exclusão. A implementação deve aguardar essas definições.
- Os requisitos RNF06, RNF07 e RNF10 não possuem limites operacionais fechados no documento. Metas de desempenho, funcionamento offline, hospedagem, suporte e disponibilidade precisam ser acordadas antes de testes de aceite quantitativos.

## 3. Arquitetura e convenções técnicas

### 3.1. Organização proposta

| Camada | Responsabilidade | Pastas/arquivos principais |
| --- | --- | --- |
| Backend Rails | API REST, regras de negócio, autenticação, autorização, validações, consultas e persistência. | app/models; app/controllers/api/v1; app/services; config/routes.rb; db/migrate |
| Banco PostgreSQL | Integridade referencial, índices, unicidade, consultas e armazenamento dos dados. | db/schema.rb; migrations; constraints e índices |
| Frontend Vue.js | Telas, componentes, formulários, navegação, acessibilidade e consumo da API. | src/views; src/components; src/services; src/router; src/stores |
| Testes | Verificação de models, endpoints, permissões e componentes. | test/models; test/controllers ou requests; frontend tests |

### 3.2. Convenção de nomes e compatibilidade com o DER

O DER apresenta nomes lógicos em português e, nas três tabelas originais, PKs nomeadas `id_usuario`, `id_material` e `id_categoria`. Para evitar que o Rails infira nomes de tabela/PK incorretos, declarar explicitamente `table_name` e `primary_key` nos Models. As tabelas físicas recomendadas no PostgreSQL são os nomes em snake\_case e plural abaixo. Os nomes dos campos existentes são preservados.

| Entidade do DER | Model Rails | Tabela física | PK |
| --- | --- | --- | --- |
| USUARIO | Usuario | usuarios | id\_usuario |
| LIVRO | Livro | livros | id\_material |
| CATEGORIA | Categoria | categorias | id\_categoria |
| ACESSOS\_MATERIAIS | AcessoMaterial | acessos\_materiais | id\_acesso |
| FAVORITOS | Favorito | favoritos | id\_favorito |
| LISTAS\_LEITURA | ListaLeitura | listas\_leitura | id\_lista |
| LISTAS\_LEITURA\_LIVROS | ListaLeituraLivro | listas\_leitura\_livros | (id\_lista, id\_material) — composta |
| HISTORICO\_LEITURA | HistoricoLeitura | historico\_leitura | id\_historico |
| MARCADORES\_PAGINA | MarcadorPagina | marcadores\_pagina | id\_marcador |
| CLASSIFICACOES | Classificacao | classificacoes | id\_classificacao |

> **Atenção:** a pluralização automática do Rails pode variar para palavras em português. Por isso, cada Model deverá declarar `self.table_name`. A tabela de junção LISTAS\_LEITURA\_LIVROS foi desenhada com PK composta. Rails 7.1+ possui suporte a chave primária composta; se a versão adotada for anterior ou se a equipe preferir simplificar ActiveRecord, aprovar a troca por `id_lista_livro` como PK e manter `UNIQUE(id_lista, id_material)`. Não executar essa alteração silenciosamente: atualizar o DER primeiro.

### 3.3. Relacionamentos do DER

| Origem (1) | Destino (N) | Regra |
| --- | --- | --- |
| USUARIO | LIVRO | Um usuário cadastra vários livros; cada livro guarda `id_usuario_cadastro`. |
| CATEGORIA | LIVRO | Uma categoria classifica vários livros; cada livro pertence a uma categoria. |
| USUARIO | FAVORITOS | Um usuário possui vários favoritos; um favorito pertence a um usuário. |
| LIVRO | FAVORITOS | Um livro pode aparecer nos favoritos de vários usuários. |
| USUARIO | LISTAS\_LEITURA | Um usuário cria várias listas; cada lista pertence a um usuário. |
| LISTAS\_LEITURA | LISTAS\_LEITURA\_LIVROS | Uma lista contém vários itens/livros. |
| LIVRO | LISTAS\_LEITURA\_LIVROS | Um livro pode aparecer em várias listas. |
| USUARIO | HISTORICO\_LEITURA | Um usuário possui vários registros de histórico. |
| LIVRO | HISTORICO\_LEITURA | Um livro pode aparecer no histórico de vários usuários. |
| USUARIO | MARCADORES\_PAGINA | Um usuário pode manter marcadores para vários livros. |
| LIVRO | MARCADORES\_PAGINA | Um livro pode ter marcadores de vários usuários. |
| USUARIO | ACESSOS\_MATERIAIS | Um usuário autenticado pode gerar vários acessos; `id_usuario` pode ser NULL para visitante. |
| LIVRO | ACESSOS\_MATERIAIS | Um livro pode possuir vários registros de acesso. |
| LIVRO | CLASSIFICACOES | Um livro pode possuir várias classificações complementares. |

### 3.4. Comandos de geração: começar pelas Models

Executar os comandos na raiz do backend Rails. Eles geram os arquivos de Model e migrations. Em seguida, abrir cada migration em `db/migrate`, conferir PK, tipos, null, índices e FKs; só depois executar `bin/rails db:migrate`.

```bash
bin/rails generate model Usuario nome:string email:string senha:string tipo_usuario:string data_cadastro:datetime
bin/rails generate model Categoria nome:string descricao:text
bin/rails generate model Livro titulo:string autor:string descricao:text caminho_arquivo:string categoria:references usuario_cadastro:references
bin/rails generate model AcessoMaterial livro:references usuario:references tipo_acesso:string data_acesso:datetime
bin/rails generate model Favorito usuario:references livro:references data_favorito:datetime
bin/rails generate model ListaLeitura usuario:references nome:string descricao:text data_criacao:datetime
bin/rails generate model HistoricoLeitura usuario:references livro:references data_inicio:datetime data_ultima_leitura:datetime progresso_percentual:decimal
bin/rails generate model MarcadorPagina usuario:references livro:references pagina_atual:integer localizacao:string data_atualizacao:datetime
bin/rails generate model Classificacao livro:references tipo:string nome:string descricao:text
```

Para LISTAS\_LEITURA\_LIVROS, gerar o Model sem migration automática de referência padrão ou criar a migration manualmente, pois a PK do DER é composta. Exemplo: `bin/rails generate model ListaLeituraLivro --skip-migration`; depois criar migration específica com `create_table id: false` e primary\_key composta, conforme a versão do Rails.

Os comandos são ponto de partida, não substituem a revisão da migration. Em especial, as referências precisam apontar para as PKs personalizadas do DER, e não para uma coluna `id` padrão.

### 3.5. Padrão obrigatório para Models e migrations

- Em cada Model, declarar `self.table_name` e `self.primary_key` quando a tabela ou PK não seguir a convenção Rails.
- Declarar `belongs_to`/`has_many` com `class_name`, `foreign_key` e `primary_key` explícitos quando necessário.
- Adicionar índices UNIQUE no PostgreSQL para email, categoria.nome, par usuario/material em FAVORITOS e MARCADORES\_PAGINA e par lista/material em LISTAS\_LEITURA\_LIVROS.
- Usar `null: false` para campos obrigatórios; permitir null em `ACESSOS_MATERIAIS.id_usuario` para visitantes. Não permitir null em FK de FAVORITOS, LISTAS\_LEITURA, HISTORICO\_LEITURA e MARCADORES\_PAGINA.
- Adicionar `foreign_key: true` (com `to_table` quando necessário) e escolher `on_delete` conscientemente. Não apagar usuário ou livro em cascata sem política aprovada; preferir impedir exclusão quando houver histórico, ou usar exclusão lógica se aprovada.
- Validar regras na Model e também no banco quando forem regras de integridade (NOT NULL, UNIQUE, FK, CHECK). Validação Rails isolada não impede concorrência.
- Não guardar senha em texto puro. O valor persistido na coluna `senha` deve ser hash BCrypt; nunca retornar esse campo na API.

---

## ÉPICO 1 — Acesso público, catálogo e consulta de materiais

**Objetivo:** Permitir que visitantes e leitores encontrem e consultem o acervo público, com pesquisa, filtros e apresentação consistente dos metadados.

**Requisitos relacionados:** RF01, RF04, RF05; RNF03, RNF04, RNF05.

**Dependências/decisões:** Política da SESFA deve definir quais livros são públicos e quais exigem autenticação. A estrutura atual trata a consulta pública como padrão, sujeita às regras de restrição do Épico 3.

### HU-01 — Acessar a biblioteca como visitante ou leitor

**História:** Como visitante ou leitor, quero abrir a biblioteca e visualizar os materiais liberados, para conhecer o acervo sem precisar criar uma conta quando o acesso público estiver habilitado.

**Requisitos:** RF01

**Critérios de aceitação:**

- A página inicial apresenta catálogo quando o acesso público estiver habilitado.
- Materiais restritos não são retornados a visitantes sem autorização.
- Se a política exigir login para uma área, a API responde 401/403 e o frontend apresenta orientação de autenticação.
- A consulta pública não expõe dados pessoais de quem cadastrou o material.

#### Task 1 — Preparar rota e endpoint público do catálogo

**Objetivo:** Criar endpoint de leitura do catálogo sem exigir login, mantendo restrições no backend.

**Arquivos envolvidos:**

- `config/routes.rb`
- `app/controllers/api/v1/livros_controller.rb`
- `app/controllers/application_controller.rb`

**O que fazer:**

1. Criar namespace `namespace :api do; namespace :v1 do` e rota `GET /livros` para `index`.
2. No `LivrosController#index`, consultar apenas livros publicados/visíveis conforme o estado de publicação que a equipe definir. Como o DER inicial não possui campo `status`, registrar a decisão: nesta versão, considerar os livros cadastrados como disponíveis ou aprovar adição de `status` antes de implementar rascunhos/publicação.
3. Não incluir senha, email ou outros dados de USUARIO na resposta; retornar apenas metadados do livro, categoria e informações públicas.
4. Manter autenticação opcional no endpoint público, mas aplicar autorização quando o livro tiver regra restritiva.

**Concluído quando:**

- `GET /api/v1/livros` funciona sem sessão para itens públicos.
- Um visitante não consegue obter material restrito apenas alterando a URL.
- A resposta contém somente atributos necessários à consulta.

#### Task 2 — Criar serviço frontend para catálogo

**Objetivo:** Centralizar chamadas HTTP do Vue para o catálogo.

**Arquivos envolvidos:**

- `src/services/api.js` (ou arquivo equivalente já existente)
- `src/services/livrosService.js`

**O que fazer:**

1. Configurar instância HTTP com `baseURL` da API, timeout e tratamento centralizado de erros.
2. Criar função `listar(params)` que envia termo, categoria e paginação como query params.
3. Criar função `buscarPorId(id)` para carregar detalhes.
4. Não montar URLs de arquivo com concatenação insegura; usar a URL/caminho devolvido pelo backend.

**Concluído quando:**

- Componentes não repetem fetch/axios diretamente.
- Erros 401, 403, 404 e 500 são tratados de forma previsível.

#### Task 3 — Construir tela inicial da biblioteca

**Objetivo:** Exibir catálogo acessível para visitantes e leitores.

**Arquivos envolvidos:**

- `src/views/InicioView.vue`
- `src/components/livros/LivroCard.vue`
- `src/components/layout/AppHeader.vue`

**O que fazer:**

1. Ao montar a tela, chamar `livrosService.listar()`.
2. Exibir título, autor, categoria e descrição resumida conforme os campos disponíveis.
3. Exibir estado de carregamento, lista vazia e falha de comunicação.
4. Não exigir login para navegação pública; apresentar entrada/cadastro como opção, não bloqueio geral.

**Concluído quando:**

- Visitante visualiza materiais públicos.
- A tela funciona em largura móvel e desktop.
- Estados de loading, vazio e erro são compreensíveis.

### HU-02 — Pesquisar e filtrar materiais

**História:** Como visitante ou leitor, quero pesquisar por termos e aplicar filtros, para localizar materiais relevantes com facilidade.

**Requisitos:** RF04, RF07

**Critérios de aceitação:**

- É possível pesquisar por título e autor; descrição pode ser incluída se aprovada para busca.
- Filtros usam apenas classificações existentes no banco.
- Filtros podem ser combinados e removidos.
- Sem resultados, a tela informa que nenhum material foi encontrado.

#### Task 1 — Implementar consulta de pesquisa no backend

**Objetivo:** Criar busca segura e combinável, sem interpolar SQL fornecido pelo usuário.

**Arquivos envolvidos:**

- `app/controllers/api/v1/livros_controller.rb`
- `app/queries/livros_query.rb` (criar)
- `test/queries/livros_query_test.rb`

**O que fazer:**

1. Criar `LivrosQuery` recebendo params permitidos: `q`, `categoria_id`, `tipo_classificacao`, `classificacao`, `page` e `per_page`.
2. Aplicar `ILIKE` com bind parameters para título e autor; limitar `per_page` a um máximo definido (ex.: 50).
3. Aplicar filtros por categoria e por classificação através de joins com categorias/classificacoes.
4. Ordenar por título ou `data_cadastro` com lista permitida; rejeitar parâmetros de ordenação arbitrários.
5. Garantir que filtros não removam a regra de visibilidade do material.

**Concluído quando:**

- Pesquisa é case-insensitive no PostgreSQL.
- Filtros combinados retornam interseção correta.
- Não existe SQL injection por parâmetros de busca.

#### Task 2 — Criar controles de pesquisa no Vue

**Objetivo:** Permitir pesquisa e filtros com estado sincronizado.

**Arquivos envolvidos:**

- `src/components/livros/BuscaLivros.vue`
- `src/views/InicioView.vue`
- `src/services/livrosService.js`

**O que fazer:**

1. Criar campo de texto com label acessível e botão limpar.
2. Carregar categorias e classificações disponíveis em controles select/checkbox.
3. Ao aplicar filtros, enviar parâmetros ao serviço e atualizar resultados.
4. Preservar filtros na URL usando query string, se o roteador estiver configurado.
5. Informar visualmente filtros ativos e permitir removê-los individualmente.

**Concluído quando:**

- A pesquisa não recarrega a página inteira.
- Filtros podem ser usados por teclado.
- Estado vazio e contagem de resultados são apresentados.

### HU-03 — Consultar detalhes de um livro

**História:** Como visitante ou leitor, quero consultar os detalhes de um material, para avaliar se ele atende ao meu interesse e às minhas necessidades.

**Requisitos:** RF05

**Critérios de aceitação:**

- Detalhe apresenta título, autor, descrição e categoria.
- Classificações complementares são apresentadas somente quando cadastradas.
- Campo ausente não é exibido como se tivesse informação.
- A API retorna 404 para material inexistente e não revela material restrito.

#### Task 1 — Implementar endpoint de detalhes

**Objetivo:** Retornar livro e associações necessárias em uma resposta controlada.

**Arquivos envolvidos:**

- `app/controllers/api/v1/livros_controller.rb`
- `app/serializers/livro_serializer.rb` (criar, se não houver serializer)
- `test/controllers/api/v1/livros_controller_test.rb`

**O que fazer:**

1. Implementar `show` localizando por `id_material`, que é a PK definida no DER.
2. Carregar `categoria` e `classificacoes` com `includes` para evitar N+1.
3. Definir explicitamente campos retornados: `id_material`, `titulo`, `autor`, `descricao`, `categoria` e classificações públicas.
4. Aplicar política de acesso antes de serializar o material.

**Concluído quando:**

- Detalhe válido retorna 200.
- ID inexistente retorna 404.
- Material sem autorização não tem metadados privados expostos.

#### Task 2 — Implementar página de detalhes

**Objetivo:** Apresentar dados completos e ações disponíveis.

**Arquivos envolvidos:**

- `src/views/LivroDetalheView.vue`
- `src/components/livros/LivroMetadados.vue`
- `src/router/index.js`

**O que fazer:**

1. Criar rota `/livros/:id`.
2. Buscar dados pelo `id_material` da rota.
3. Apresentar metadados e classificações em linguagem clara.
4. Mostrar botão ler/baixar somente quando a API indicar que a ação está permitida.
5. Exibir estado de não encontrado e de acesso negado.

**Concluído quando:**

- A página funciona ao atualizar diretamente a URL.
- Não exibe campos vazios como conteúdo real.
- Ações respeitam resposta da API.

---

## ÉPICO 2 — Cadastro, autenticação e perfis de usuário

**Objetivo:** Permitir cadastro opcional de leitores, autenticação de administradores e leitores cadastrados e diferenciação de permissões pelo `tipo_usuario`.

**Requisitos relacionados:** RF02, RF03, RF13; RNF08, RNF09.

**Dependências/decisões:** Confirmar se recuperação de senha será oferecida por email e qual provedor será utilizado. A política de criação do primeiro administrador deve ser definida para não permitir autoelevação de perfil.

### HU-04 — Cadastrar conta de leitor

**História:** Como visitante, quero criar uma conta de leitor, para utilizar favoritos, listas, histórico e marcadores.

**Requisitos:** RF02

**Critérios de aceitação:**

- Cadastro solicita apenas nome, email e senha, salvo exigência aprovada.
- Email é único, sem diferenciar maiúsculas/minúsculas.
- Novo cadastro recebe `tipo_usuario` leitor; o cliente não pode escolher administrador.
- Senha nunca é armazenada em texto puro.
- Dados inválidos retornam mensagens por campo.

#### Task 1 — Gerar Model Usuario e migration

**Objetivo:** Criar a entidade de usuários partindo da Model e ajustar a migration ao DER.

**Arquivos envolvidos:**

- `app/models/usuario.rb`
- `db/migrate/*_create_usuarios.rb`
- `db/schema.rb` (gerado após migrate)

**O que fazer:**

1. Executar `bin/rails generate model Usuario nome:string email:string senha:string tipo_usuario:string data_cadastro:datetime`.
2. Na migration, configurar `create_table :usuarios, id: :integer, primary_key: :id_usuario`; definir `nome` string limit:100, `email` string limit:150, `senha` string limit:255, `tipo_usuario` string limit:20 e `data_cadastro` datetime.
3. Adicionar `null:false` aos campos obrigatórios e índice unique para `email`. Se o gerador criar referências `id` padrão, remover e ajustar manualmente.
4. No Model, declarar `self.table_name = 'usuarios'` e `self.primary_key = 'id_usuario'`.
5. Adicionar validações: `nome` presence e length 2..100; `email` presence, length máximo 150, formato e unicidade case-insensitive; `tipo_usuario` inclusion em administrador/leitor; `senha` com mínimo definido pela política (sugestão inicial: 8 caracteres) no cadastro.
6. Normalizar email com `strip.downcase` antes de validação/persistência. Não permitir que parâmetros públicos definam `tipo_usuario` como administrador.

**Concluído quando:**

- Migration preserva os nomes lógicos do DER e PK `id_usuario`.
- Índice UNIQUE de email existe no PostgreSQL.
- Model rejeita email duplicado e `tipo_usuario` inválido.

#### Task 2 — Implementar hash de senha seguro

**Objetivo:** Guardar somente hash BCrypt na coluna `senha` já existente.

**Arquivos envolvidos:**

- `app/models/usuario.rb`
- `Gemfile`
- `test/models/usuario_test.rb`

**O que fazer:**

1. Adicionar gem `bcrypt` ao Gemfile e executar `bundle install`.
2. Como a coluna se chama `senha` e não `password_digest`, implementar setter que transforme a senha recebida em `BCrypt::Password` antes de persistir; nunca manter o texto original.
3. Implementar método `autenticar(senha_digitada)` que compare com `BCrypt::Password` armazenado e retorne usuário ou false.
4. Evitar serializar o atributo `senha` em qualquer endpoint.
5. Adicionar testes para senha correta, incorreta, hash diferente do texto original e senha ausente.

**Concluído quando:**

- Banco contém hash BCrypt, não senha em texto puro.
- Autenticação rejeita senha incorreta.
- Resposta JSON nunca contém senha/hash.

#### Task 3 — Criar endpoint de cadastro

**Objetivo:** Disponibilizar cadastro público de leitor sem permitir atribuição de privilégios.

**Arquivos envolvidos:**

- `config/routes.rb`
- `app/controllers/api/v1/usuarios_controller.rb`
- `app/serializers/usuario_serializer.rb`
- `test/controllers/api/v1/usuarios_controller_test.rb`

**O que fazer:**

1. Criar `POST /api/v1/cadastro` ou `POST /api/v1/usuarios`.
2. Permitir somente `nome`, `email` e `senha` nos strong parameters.
3. Definir `tipo_usuario = 'leitor'` no servidor, ignorando qualquer tipo enviado pelo navegador.
4. Retornar 201 com `id_usuario`, `nome` e `email`; nunca retornar senha.
5. Retornar 422 com erros de validação.

**Concluído quando:**

- Cadastro cria leitor.
- Tentativa de enviar `tipo_usuario` administrador não eleva privilégio.
- Email duplicado retorna erro sem criar segunda conta.

#### Task 4 — Criar formulário de cadastro Vue

**Objetivo:** Permitir que o visitante crie conta com retorno claro de validações.

**Arquivos envolvidos:**

- `src/views/CadastroView.vue`
- `src/services/authService.js`
- `src/router/index.js`

**O que fazer:**

1. Criar campos nome, email e senha com labels associados.
2. Validar campos obrigatórios no cliente para experiência, sem substituir validação Rails.
3. Enviar POST ao endpoint de cadastro.
4. Apresentar erros retornados pelo backend junto aos campos correspondentes.
5. Após sucesso, encaminhar para login ou iniciar sessão conforme decisão de autenticação.

**Concluído quando:**

- Formulário acessível por teclado.
- Erros do backend são apresentados.
- Frontend não envia `tipo_usuario`.

### HU-05 — Entrar e sair da plataforma

**História:** Como administrador ou leitor cadastrado, quero entrar e sair da plataforma, para acessar funcionalidades vinculadas à minha conta.

**Requisitos:** RF02, RF03

**Critérios de aceitação:**

- Email e senha válidos iniciam sessão.
- Credenciais inválidas geram mensagem genérica, sem revelar se email existe.
- Logout invalida a sessão/token.
- Rotas privadas exigem autenticação.

#### Task 1 — Criar sessão/autenticação Rails

**Objetivo:** Implementar autenticação de API com sessão segura ou token de curta duração, conforme arquitetura escolhida.

**Arquivos envolvidos:**

- `app/controllers/api/v1/sessoes_controller.rb`
- `app/controllers/concerns/autenticavel.rb` (criar)
- `config/routes.rb`
- `config/initializers/session_store.rb` (se usar sessão)

**O que fazer:**

1. Escolher e documentar mecanismo de autenticação compatível com frontend Vue separado. Preferir cookie HttpOnly, Secure em produção e SameSite adequado quando infraestrutura permitir; se usar token, definir expiração e revogação.
2. Implementar `create` para localizar usuário por email normalizado e validar senha pelo método do Model.
3. Implementar `destroy` para encerrar sessão/token.
4. Criar concern que disponibilize `current_usuario` e `before_action exigir_autenticacao`.
5. Retornar 401 para ausência/credencial inválida e não incluir hash da senha.

**Concluído quando:**

- Login e logout funcionam.
- Rotas privadas rejeitam requisição sem credencial.
- Credencial não é armazenada em localStorage se for adotado cookie HttpOnly.

#### Task 2 — Implementar guardas de rota no Vue

**Objetivo:** Controlar navegação conforme estado de autenticação sem substituir autorização backend.

**Arquivos envolvidos:**

- `src/stores/authStore.js`
- `src/router/index.js`
- `src/services/authService.js`

**O que fazer:**

1. Criar store para usuário autenticado e estado de carregamento.
2. No `beforeEach` do router, consultar sessão atual para rotas privadas.
3. Redirecionar visitante para login quando rota exigir autenticação.
4. Limpar store após logout e redirecionar para catálogo.
5. Não confiar em `tipo_usuario` guardado no navegador para autorizar ações de API.

**Concluído quando:**

- Rotas privadas não abrem para visitante.
- Atualização da página recupera estado conforme mecanismo de sessão.
- Logout limpa estado visual.

### HU-06 — Utilizar funcionalidades conforme o perfil

**História:** Como administrador ou leitor, quero visualizar e executar somente operações permitidas ao meu perfil, para proteger a administração da biblioteca.

**Requisitos:** RF03, RF13; RNF08

**Critérios de aceitação:**

- Administrador pode gerenciar livros, categorias e usuários conforme escopo.
- Leitor pode utilizar recursos pessoais e consultar materiais autorizados.
- Visitante acessa apenas funções públicas.
- Backend bloqueia tentativa de operação não autorizada, mesmo chamada manualmente.

#### Task 1 — Implementar autorização por tipo\_usuario

**Objetivo:** Criar regras centralizadas para administrador e leitor.

**Arquivos envolvidos:**

- `app/controllers/concerns/autorizacao_perfil.rb` (criar)
- `app/controllers/api/v1/*_controller.rb`
- `test/controllers/`

**O que fazer:**

1. Criar método `exigir_administrador!` que verifique `current_usuario.tipo_usuario == 'administrador'`.
2. Aplicar `before_action` em controllers de criação, edição, exclusão de livros/categorias e administração de usuários.
3. Para favoritos, listas, histórico e marcadores, exigir login e filtrar sempre por `current_usuario.id_usuario`.
4. Nunca aceitar `id_usuario` proprietário vindo do corpo da requisição para operações pessoais; usar o usuário autenticado.
5. Retornar 403 para usuário autenticado sem permissão.

**Concluído quando:**

- Leitor não executa endpoints administrativos.
- Usuário não acessa favoritos/listas de outro usuário alterando IDs.
- Testes cobrem visitante, leitor e administrador.

#### Task 2 — Adaptar menus e telas por perfil

**Objetivo:** Apresentar opções coerentes com o perfil autenticado.

**Arquivos envolvidos:**

- `src/components/layout/AppHeader.vue`
- `src/components/layout/MenuUsuario.vue`
- `src/router/index.js`

**O que fazer:**

1. Exibir painel administrativo somente quando usuário autenticado tiver `tipo_usuario` administrador.
2. Exibir recursos pessoais para leitor autenticado.
3. Para visitante, exibir opções de login/cadastro e catálogo público.
4. Tratar menu como conveniência visual; toda ação continua protegida no Rails.

**Concluído quando:**

- Menus correspondem ao perfil.
- Nenhuma proteção depende exclusivamente do Vue.

---

## ÉPICO 3 — Administração do acervo, categorias e classificações

**Objetivo:** Permitir que administradores cadastrem, revisem, organizem e atualizem livros e categorias, com classificações complementares.

**Requisitos relacionados:** RF06, RF07; RNF11.

**Dependências/decisões:** Os campos atuais de LIVRO e CATEGORIA serão preservados. A regra de publicação/rascunho não existe no DER inicial; caso seja necessária, aprovar e adicionar campo antes da implementação.

### HU-07 — Cadastrar livro no acervo

**História:** Como administrador, quero cadastrar um livro com seus metadados e arquivo, para disponibilizá-lo aos leitores.

**Requisitos:** RF06, RF05

**Critérios de aceitação:**

- Somente administrador cadastra livro.
- Título, categoria, usuário responsável e caminho/arquivo são validados conforme política.
- `id_usuario_cadastro` é preenchido pelo usuário autenticado.
- Categoria deve existir.
- Arquivo respeita formatos e tamanho definidos pela SESFA.

#### Task 1 — Gerar Model Livro e migration

**Objetivo:** Criar Model e tabela de livros mantendo os campos do DER.

**Arquivos envolvidos:**

- `app/models/livro.rb`
- `db/migrate/*_create_livros.rb`

**O que fazer:**

1. Executar `bin/rails generate model Livro titulo:string autor:string descricao:text caminho_arquivo:string categoria:references usuario_cadastro:references`.
2. Ajustar migration para tabela `livros` com PK `id_material` e campos: `titulo` VARCHAR(200), `autor` VARCHAR(150), `descricao` TEXT, `caminho_arquivo` VARCHAR(255), `id_categoria` FK para `categorias(id_categoria)`, `id_usuario_cadastro` FK para `usuarios(id_usuario)` e `data_cadastro` timestamp.
3. Definir NOT NULL nos campos que a regra exigir; título, categoria e usuário cadastrador devem ser obrigatórios. Confirmar se autor/descrição podem ser nulos com a SESFA.
4. Declarar `self.table_name = 'livros'` e `self.primary_key = 'id_material'`.
5. No Model, validar título presence/length máximo 200; autor máximo 150 quando informado; caminho máximo 255; presença e existência de categoria e usuário cadastrador.

**Concluído quando:**

- Livro usa PK `id_material`.
- FKs apontam para PKs personalizadas corretas.
- Validações e índices foram testados.

#### Task 2 — Configurar associações de Livro, Usuario e Categoria

**Objetivo:** Implementar associações ActiveRecord correspondentes ao DER.

**Arquivos envolvidos:**

- `app/models/livro.rb`
- `app/models/usuario.rb`
- `app/models/categoria.rb`

**O que fazer:**

1. Em Livro, declarar `belongs_to :categoria, class_name: 'Categoria', foreign_key: 'id_categoria', primary_key: 'id_categoria'`.
2. Em Livro, declarar `belongs_to :usuario_cadastro, class_name: 'Usuario', foreign_key: 'id_usuario_cadastro', primary_key: 'id_usuario'`.
3. Em Categoria, declarar `has_many :livros` com `class_name`, `foreign_key` e `dependent` conforme política; não apagar livros automaticamente sem decisão.
4. Em Usuario, declarar `has_many :livros_cadastrados` usando `foreign_key` `id_usuario_cadastro` e `primary_key` `id_usuario`.

**Concluído quando:**

- Livro carrega categoria e usuário cadastrador.
- Associações inversas retornam registros corretos.
- Exclusão não provoca perda acidental do acervo.

#### Task 3 — Criar endpoints administrativos de livros

**Objetivo:** Disponibilizar operações de criação e consulta para administração.

**Arquivos envolvidos:**

- `config/routes.rb`
- `app/controllers/api/v1/admin/livros_controller.rb`
- `app/controllers/concerns/autorizacao_perfil.rb`

**O que fazer:**

1. Criar namespace `admin` e rotas `index`, `create`, `update` e `destroy` conforme política de exclusão.
2. Aplicar `exigir_administrador!` em todas as ações de escrita.
3. Em `create`, preencher `id_usuario_cadastro` com `current_usuario.id_usuario`.
4. Usar strong parameters apenas para `titulo`, `autor`, `descricao`, `id_categoria` e `arquivo`; nunca aceitar `id_usuario_cadastro` do cliente.
5. Retornar erros 422 para validação e 404 para IDs inexistentes.

**Concluído quando:**

- Apenas administrador cria/altera/exclui.
- O cadastrador é definido no backend.
- Erros têm formato consistente.

#### Task 4 — Construir formulário de cadastro/edição Vue

**Objetivo:** Criar interface administrativa para manutenção dos livros.

**Arquivos envolvidos:**

- `src/views/admin/LivrosView.vue`
- `src/components/admin/FormLivro.vue`
- `src/services/admin/livrosAdminService.js`

**O que fazer:**

1. Criar listagem administrativa com título, autor, categoria e ações.
2. Criar formulário com título, autor, descrição e seleção de categoria.
3. Integrar upload de arquivo quando Active Storage ou solução equivalente for aprovada; o DER atual guarda `caminho_arquivo`, portanto definir storage antes de aceitar upload real.
4. Exibir erros de validação retornados pela API.
5. Solicitar confirmação antes de excluir e tratar conflito de exclusão por FK.

**Concluído quando:**

- Administrador cadastra, edita e consulta livros.
- Leitor não acessa a tela administrativa.
- Upload respeita limites e formatos definidos.

### HU-08 — Gerenciar categorias

**História:** Como administrador, quero cadastrar, editar e consultar categorias, para organizar o acervo.

**Requisitos:** RF06, RF07

**Critérios de aceitação:**

- Nome é obrigatório e único.
- Nome respeita limite de 100 caracteres.
- Não permitir exclusão de categoria vinculada a livros sem realocação ou regra aprovada.
- Somente administrador gerencia categorias.

#### Task 1 — Gerar Model Categoria e migration

**Objetivo:** Criar entidade de categoria com unicidade garantida no banco.

**Arquivos envolvidos:**

- `app/models/categoria.rb`
- `db/migrate/*_create_categorias.rb`

**O que fazer:**

1. Executar `bin/rails generate model Categoria nome:string descricao:text`.
2. Ajustar tabela `categorias` para PK `id_categoria`, `nome` VARCHAR(100) NOT NULL UNIQUE e `descricao` TEXT.
3. Declarar `self.table_name = 'categorias'` e `self.primary_key = 'id_categoria'`.
4. Validar nome presence, length máximo 100 e uniqueness case-insensitive; normalizar espaços e caixa.
5. Criar índice UNIQUE no PostgreSQL.

**Concluído quando:**

- Nome duplicado é rejeitado pela Model e pelo banco.
- PK `id_categoria` é utilizada.

#### Task 2 — Criar CRUD de categorias

**Objetivo:** Disponibilizar operações administrativas de categoria.

**Arquivos envolvidos:**

- `config/routes.rb`
- `app/controllers/api/v1/admin/categorias_controller.rb`
- `test/controllers/api/v1/admin/categorias_controller_test.rb`

**O que fazer:**

1. Criar `GET` index/show e `POST`/`PATCH` para criação e edição.
2. Proteger escrita com `exigir_administrador!`.
3. No `destroy`, verificar livros associados; retornar conflito 409 ou erro de validação se houver dependentes, a menos que a equipe defina outra regra.
4. Permitir somente `nome` e `descricao` nos parâmetros.

**Concluído quando:**

- CRUD funciona para administrador.
- Leitor não altera categorias.
- Categoria utilizada não é apagada silenciosamente.

#### Task 3 — Criar telas Vue de categorias

**Objetivo:** Permitir manutenção simples das categorias.

**Arquivos envolvidos:**

- `src/views/admin/CategoriasView.vue`
- `src/components/admin/FormCategoria.vue`
- `src/services/admin/categoriasAdminService.js`

**O que fazer:**

1. Criar tabela/lista de categorias e formulário de cadastro/edição.
2. Validar nome obrigatório e tamanho máximo no cliente.
3. Apresentar erro de nome já existente e de categoria em uso.
4. Não exibir ações administrativas a leitor.

**Concluído quando:**

- Administrador gerencia categorias sem editar diretamente o banco.
- Mensagens são claras e acessíveis.

### HU-09 — Classificar materiais por atributos complementares

**História:** Como administrador, quero associar classificações aos livros, para facilitar a organização e a descoberta de materiais.

**Requisitos:** RF07, RF05

**Critérios de aceitação:**

- Um livro pode possuir várias classificações.
- Cada classificação tem tipo e nome.
- Tipos aceitos seguem taxonomia aprovada pela SESFA.
- Classificações ficam disponíveis na consulta e pesquisa.

#### Task 1 — Gerar Model Classificacao e migration

**Objetivo:** Criar registros de gênero, faixa etária, formato e acessibilidade vinculados ao livro.

**Arquivos envolvidos:**

- `app/models/classificacao.rb`
- `db/migrate/*_create_classificacoes.rb`

**O que fazer:**

1. Executar `bin/rails generate model Classificacao livro:references tipo:string nome:string descricao:text`.
2. Ajustar tabela para PK `id_classificacao` e FK `id_material` referenciando `livros(id_material)`.
3. Declarar `self.table_name = 'classificacoes'` e `self.primary_key = 'id_classificacao'`.
4. Validar `tipo` inclusion em valores acordados (por exemplo genero, faixa\_etaria, formato, acessibilidade); não fixar lista final sem validação SESFA.
5. Validar `nome` presence e limite 100; criar índice por `id_material` e `tipo`.

**Concluído quando:**

- FK impede classificação sem livro.
- Tipos inválidos são rejeitados.
- Um livro pode ter várias classificações.

#### Task 2 — Criar associações e endpoints de classificação

**Objetivo:** Permitir associação e consulta de classificações.

**Arquivos envolvidos:**

- `app/models/classificacao.rb`
- `app/models/livro.rb`
- `config/routes.rb`
- `app/controllers/api/v1/admin/classificacoes_controller.rb`

**O que fazer:**

1. Em Classificacao, `belongs_to :livro` com `foreign_key` `id_material` e `primary_key` `id_material`.
2. Em Livro, `has_many :classificacoes` com `foreign_key` `id_material`; definir exclusão dependente conforme política.
3. Criar endpoints para listar classificações de um livro, criar e excluir classificação, protegendo escrita para administrador.
4. Impedir que o cliente associe classificação a livro inexistente.

**Concluído quando:**

- Associação livro-classificações funciona.
- Leitor consulta mas não altera classificações.
- Filtros podem reutilizar os registros.

#### Task 3 — Criar editor de classificações no Vue

**Objetivo:** Permitir que administrador classifique materiais.

**Arquivos envolvidos:**

- `src/components/admin/ClassificacoesLivro.vue`
- `src/services/admin/classificacoesService.js`
- `src/views/admin/LivrosView.vue`

**O que fazer:**

1. Dentro do formulário/detalhe do livro, exibir classificações atuais agrupadas por tipo.
2. Permitir adicionar tipo, nome e descrição.
3. Carregar opções de tipo a partir de configuração controlada, não texto livre sem validação.
4. Atualizar lista após criação/remoção e mostrar erros.

**Concluído quando:**

- Classificações aparecem agrupadas.
- Filtros e detalhes refletem as classificações salvas.

---

## ÉPICO 4 — Disponibilização, leitura, downloads e métricas

**Objetivo:** Permitir acesso aos arquivos conforme direitos de utilização e registrar eventos necessários aos relatórios administrativos.

**Requisitos relacionados:** RF08, RF09, RF14; RNF06, RNF11.

**Dependências/decisões:** SESFA deve informar formatos permitidos, limites de arquivo, direitos de download e regras de restrição por idade/perfil. O DER inicial não possui faixa etária nem status do livro; usar CLASSIFICACOES para faixa etária e aprovar eventual campo adicional se necessário.

### HU-10 — Abrir, ler ou baixar material

**História:** Como visitante ou leitor autorizado, quero abrir ou baixar um material nas modalidades permitidas, para consumir seu conteúdo.

**Requisitos:** RF09, RF08

**Critérios de aceitação:**

- O sistema oferece somente ações autorizadas para o material.
- Acesso respeita direitos de utilização informados pela ONG.
- Arquivo inexistente ou indisponível apresenta erro controlado.
- Toda visualização, leitura ou download elegível gera registro em ACESSOS\_MATERIAIS.

#### Task 1 — Definir e implementar armazenamento de arquivos

**Objetivo:** Armazenar arquivos de livros com segurança e URL controlada.

**Arquivos envolvidos:**

- `Gemfile`
- `config/storage.yml` (se Active Storage)
- `app/models/livro.rb`
- `db/migrate/*_active_storage*` (geradas pelo comando Rails)

**O que fazer:**

1. Confirmar com equipe se será usado Active Storage, storage local em desenvolvimento e serviço externo em produção, ou armazenamento equivalente.
2. Se usar Active Storage, executar `bin/rails active_storage:install` e `bin/rails db:migrate`.
3. Manter `caminho_arquivo` por compatibilidade com DER, ou documentar a migração para attachment; não duplicar caminhos e anexos sem estratégia.
4. Definir extensões/MIME permitidos e tamanho máximo com SESFA.
5. Garantir que arquivos restritos não tenham URL pública permanente.

**Concluído quando:**

- Arquivo é armazenado fora de diretório público não controlado.
- Tipo e tamanho são validados.
- Acesso ao arquivo passa por autorização.

#### Task 2 — Criar serviço de autorização e entrega de arquivo

**Objetivo:** Centralizar a decisão de permitir visualização/download.

**Arquivos envolvidos:**

- `app/services/livros/acesso_service.rb` (criar)
- `app/controllers/api/v1/livros_controller.rb`
- `app/policies/livro_policy.rb` (se usar Pundit)

**O que fazer:**

1. Criar método `pode_acessar?(usuario, livro, acao)` que avalie política pública/restrita, perfil e faixa etária quando regras estiverem aprovadas.
2. Negar por padrão conteúdos marcados como restritos quando não houver comprovação de autorização.
3. Gerar URL temporária ou fazer streaming autorizado do arquivo.
4. Não confiar em botão oculto no frontend; validar toda requisição no Rails.

**Concluído quando:**

- Acesso autorizado funciona.
- Acesso não autorizado retorna 403.
- URL temporária não permanece válida além do prazo configurado.

#### Task 3 — Registrar eventos de acesso

**Objetivo:** Gravar visualização, leitura e download para histórico estatístico.

**Arquivos envolvidos:**

- `app/models/acesso_material.rb`
- `app/controllers/api/v1/livros_controller.rb`
- `app/services/acessos/registrar_acesso.rb` (criar)

**O que fazer:**

1. Gerar Model AcessoMaterial com `bin/rails generate model AcessoMaterial livro:references usuario:references tipo_acesso:string data_acesso:datetime`.
2. Ajustar migration para PK `id_acesso`, FK `id_material` para `livros(id_material)`, FK `id_usuario` para `usuarios(id_usuario)` permitindo NULL, `tipo_acesso` VARCHAR(20) e `data_acesso` timestamp.
3. Declarar `belongs_to :livro` e `belongs_to :usuario, optional: true`, com PKs explícitas.
4. Validar `tipo_acesso` dentro de visualizacao, leitura e download; preencher `data_acesso` automaticamente.
5. Criar índice em `data_acesso`, `tipo_acesso` e `id_material` para relatórios.
6. Registrar evento após autorização e confirmação da ação; não registrar download bloqueado como download concluído.

**Concluído quando:**

- Acesso de visitante é gravado com `id_usuario` NULL.
- Eventos têm tipo e data válidos.
- FK de livro impede evento órfão.

#### Task 4 — Implementar leitor/visualizador no Vue

**Objetivo:** Exibir conteúdo digital e ações permitidas.

**Arquivos envolvidos:**

- `src/views/LeitorLivroView.vue`
- `src/components/leitor/VisualizadorDocumento.vue`
- `src/services/livrosService.js`

**O que fazer:**

1. Criar tela de leitura que recebe material autorizado pela API.
2. Integrar visualizador compatível com os formatos aprovados (PDF/EPUB etc. somente após decisão).
3. Disponibilizar download apenas se permitido pelo backend.
4. Apresentar mensagem quando formato não puder ser aberto no navegador.
5. Tratar falha de carregamento sem expor caminho interno do servidor.

**Concluído quando:**

- Leitura funciona nos formatos suportados.
- Download segue permissão.
- Erros de arquivo são tratados.

### HU-11 — Aplicar restrições por idade ou perfil

**História:** Como responsável pela plataforma, quero restringir materiais conforme regras da SESFA, para garantir que conteúdos sejam acessados pelo público adequado.

**Requisitos:** RF08, RF15

**Critérios de aceitação:**

- Restrições são aplicadas no catálogo, detalhe, leitura e download.
- Usuário sem condição exigida não obtém o arquivo nem seus metadados restritos.
- Visitante não recebe conteúdo cuja regra exija identificação.
- Regra de idade só é ativada após SESFA definir faixa etária e procedimento de verificação.

#### Task 1 — Formalizar regra de acesso com a SESFA

**Objetivo:** Transformar decisão institucional em regra técnica antes de codificar.

**Arquivos envolvidos:**

- `docs/decisoes-negocio/acesso_conteudos.md` (criar)

**O que fazer:**

1. Registrar se material é público, restrito por idade, restrito por perfil ou exige autorização.
2. Definir como idade será comprovada e se a data de nascimento será coletada; não coletar dado sem necessidade aprovada.
3. Definir tratamento para visitantes, leitores menores e responsáveis.
4. Definir mensagens e fluxo de bloqueio.

**Concluído quando:**

- Documento de decisão aprovado pela SESFA.
- Critérios de aceite podem ser testados sem interpretação ambígua.

#### Task 2 — Implementar política de acesso

**Objetivo:** Aplicar as regras documentadas no backend.

**Arquivos envolvidos:**

- `app/services/livros/acesso_service.rb`
- `app/controllers/api/v1/livros_controller.rb`
- `test/services/livros/acesso_service_test.rb`

**O que fazer:**

1. Implementar verificações por material e usuário autenticado.
2. Aplicar política em `index`, `show`, leitura e download.
3. Usar classificação de faixa etária somente após padronização dos valores.
4. Registrar tentativa negada se a política de métricas assim determinar, sem armazenar dados excessivos.

**Concluído quando:**

- Mesma regra vale para todas as rotas.
- Testes cobrem visitante, leitor e administrador, com idades/perfis de teste fictícios.

---

## ÉPICO 5 — Personalização da experiência do leitor

**Objetivo:** Disponibilizar recursos individuais para leitores cadastrados: favoritos, listas, histórico e marcadores de página.

**Requisitos relacionados:** RF11; RNF03, RNF04, RNF08.

**Dependências/decisões:** Os recursos selecionados pelo usuário estão no escopo. Visitantes podem consultar materiais, mas precisam de conta para salvar dados individuais.

### HU-12 — Favoritar e desfavoritar livros

**História:** Como leitor autenticado, quero marcar livros como favoritos e remover essa marcação, para encontrar rapidamente materiais de meu interesse.

**Requisitos:** RF11

**Critérios de aceitação:**

- Somente usuário autenticado utiliza favoritos.
- Um usuário não pode favoritar o mesmo livro duas vezes.
- Usuário só consulta e altera seus próprios favoritos.
- Livro inexistente não pode ser favoritado.

#### Task 1 — Gerar Model Favorito e migration

**Objetivo:** Criar associação entre usuário e livro com unicidade composta.

**Arquivos envolvidos:**

- `app/models/favorito.rb`
- `db/migrate/*_create_favoritos.rb`

**O que fazer:**

1. Executar `bin/rails generate model Favorito usuario:references livro:references data_favorito:datetime`.
2. Ajustar migration para PK `id_favorito`, FK `id_usuario` -> `usuarios(id_usuario)`, FK `id_material` -> `livros(id_material)`, `data_favorito` timestamp e índice UNIQUE `[id_usuario, id_material]`.
3. Declarar `self.table_name = 'favoritos'` e `self.primary_key = 'id_favorito'`.
4. Model `belongs_to :usuario` e `:livro` com `foreign_key`/`primary_key` explícitos.
5. Validar presença das associações e unicidade do par usuario/material; preencher `data_favorito` automaticamente.

**Concluído quando:**

- FKs corretas.
- Banco impede duplicidade mesmo em requisições simultâneas.
- Favorito não existe sem usuário e livro.

#### Task 2 — Criar endpoints de favoritos

**Objetivo:** Permitir listar, adicionar e remover favoritos do próprio usuário.

**Arquivos envolvidos:**

- `config/routes.rb`
- `app/controllers/api/v1/favoritos_controller.rb`
- `test/controllers/api/v1/favoritos_controller_test.rb`

**O que fazer:**

1. Criar `GET`/`POST`/`DELETE` em `/api/v1/favoritos`.
2. Exigir autenticação em todas as ações.
3. Na listagem, filtrar por `current_usuario.id_usuario`.
4. Na criação, usar `current_usuario`, aceitar somente `id_material` e retornar conflito se já existir.
5. Na remoção, localizar favorito dentro do escopo do usuário autenticado.

**Concluído quando:**

- Usuário A não lê ou apaga favorito de B.
- Duplicidade retorna resposta controlada.
- Visitante recebe 401.

#### Task 3 — Integrar botão de favorito no Vue

**Objetivo:** Permitir favoritar na listagem e detalhe.

**Arquivos envolvidos:**

- `src/components/livros/FavoritoButton.vue`
- `src/services/favoritosService.js`
- `src/stores/favoritosStore.js`
- `src/views/LivroDetalheView.vue`

**O que fazer:**

1. Criar botão com estado favoritado/não favoritado e nome acessível.
2. Ao clicar, chamar `POST` ou `DELETE` conforme estado.
3. Atualizar store e interface somente após resposta bem-sucedida.
4. Se visitante clicar, encaminhar ao login preservando retorno para o livro.

**Concluído quando:**

- Estado visual corresponde ao banco.
- Erro de rede não marca favorito falsamente.
- Leitor só vê seus favoritos.

### HU-13 — Criar e organizar listas de leitura

**História:** Como leitor autenticado, quero criar listas e adicionar/remover livros, para organizar materiais por interesse.

**Requisitos:** RF11

**Critérios de aceitação:**

- Usuário pode criar várias listas próprias.
- Nome é obrigatório e possui limite de 100 caracteres.
- Lista pertence a um único usuário.
- Um livro não aparece duplicado na mesma lista.
- Usuário não acessa lista de outra pessoa.

#### Task 1 — Gerar Model ListaLeitura e migration

**Objetivo:** Criar lista pertencente ao usuário.

**Arquivos envolvidos:**

- `app/models/lista_leitura.rb`
- `db/migrate/*_create_listas_leitura.rb`

**O que fazer:**

1. Executar `bin/rails generate model ListaLeitura usuario:references nome:string descricao:text data_criacao:datetime`.
2. Ajustar PK `id_lista`, FK `id_usuario` -> `usuarios(id_usuario)`, `nome` VARCHAR(100), `descricao` TEXT e `data_criacao` timestamp.
3. Declarar `table_name`/`primary_key` e `belongs_to :usuario`.
4. Validar nome presence e length máximo 100; preencher `data_criacao` automaticamente.

**Concluído quando:**

- Lista sempre possui proprietário válido.
- Nome inválido é rejeitado.

#### Task 2 — Gerar Model ListaLeituraLivro e migration de junção

**Objetivo:** Implementar N:N entre listas e livros sem permitir repetição.

**Arquivos envolvidos:**

- `app/models/lista_leitura_livro.rb`
- `db/migrate/*_create_lista_leitura_livros.rb`
- `app/models/lista_leitura.rb`
- `app/models/livro.rb`

**O que fazer:**

1. Criar Model/migration de junção com `id_lista` e `id_material` como FKs; preservar a PK composta do DER se versão Rails suportar.
2. Na migration, criar FKs para `listas_leitura(id_lista)` e `livros(id_material)`, e índice UNIQUE `[id_lista, id_material]`.
3. Se usar PK composta, configurar `self.primary_key = [:id_lista, :id_material]` e confirmar compatibilidade da versão Rails/ActiveRecord. Caso não seja compatível, solicitar aprovação para PK técnica `id_lista_livro` mantendo UNIQUE nas duas FKs.
4. Declarar associações `has_many :lista_leitura_livros` e `has_many :livros, through: ...`; configurar inversas.
5. Validar presença das duas associações.

**Concluído quando:**

- Uma lista contém vários livros.
- Um livro pode estar em várias listas.
- Mesmo livro não se repete na mesma lista.

#### Task 3 — Criar endpoints de listas e itens

**Objetivo:** Disponibilizar CRUD das listas e gestão de seus livros.

**Arquivos envolvidos:**

- `config/routes.rb`
- `app/controllers/api/v1/listas_leitura_controller.rb`
- `app/controllers/api/v1/lista_leitura_livros_controller.rb`

**O que fazer:**

1. Criar rotas aninhadas para listar, criar, atualizar e excluir listas do usuário.
2. Criar ação para adicionar e remover livro de lista.
3. Escopar todas as consultas por `current_usuario.lista_leituras`.
4. Aceitar `id_material` para adicionar item; nunca aceitar `id_usuario` do frontend.
5. Retornar 404 quando lista não pertence ao usuário e 422/409 para item duplicado.

**Concluído quando:**

- Proprietário é sempre o usuário autenticado.
- Não há acesso cruzado entre leitores.
- Operações mantêm integridade.

#### Task 4 — Criar telas de listas no Vue

**Objetivo:** Permitir criar listas e administrar itens.

**Arquivos envolvidos:**

- `src/views/MinhasListasView.vue`
- `src/views/ListaDetalheView.vue`
- `src/components/listas/FormLista.vue`
- `src/services/listasService.js`

**O que fazer:**

1. Criar tela com listas do usuário e ação criar nova lista.
2. Criar detalhe da lista com livros associados.
3. Permitir adicionar livro a uma lista e remover item.
4. Exibir lista vazia, confirmação de exclusão e mensagens de erro.

**Concluído quando:**

- Leitor cria e organiza suas listas.
- Não aparecem listas de outros usuários.

### HU-14 — Consultar histórico de leitura

**História:** Como leitor autenticado, quero consultar os materiais que acessei e retomar leituras, para acompanhar minha atividade.

**Requisitos:** RF11

**Critérios de aceitação:**

- Histórico é individual e privado.
- Ao iniciar leitura, registrar livro e data de início; em acessos seguintes, atualizar `data_ultima_leitura`.
- Histórico não deve duplicar registro por usuário/livro se a regra adotada for um registro consolidado.
- Visitante não possui histórico individual persistente.

#### Task 1 — Gerar Model HistoricoLeitura e migration

**Objetivo:** Criar acompanhamento individual por usuário e livro.

**Arquivos envolvidos:**

- `app/models/historico_leitura.rb`
- `db/migrate/*_create_historico_leituras.rb`

**O que fazer:**

1. Executar `bin/rails generate model HistoricoLeitura usuario:references livro:references data_inicio:datetime data_ultima_leitura:datetime progresso_percentual:decimal`.
2. Ajustar PK `id_historico`, FK `id_usuario` e `id_material` para PKs correspondentes, timestamps e progresso NUMERIC(5,2).
3. Criar índice UNIQUE `[id_usuario, id_material]` se o histórico representar o progresso atual consolidado; se a SESFA desejar cada sessão separada, remover unicidade e modelar sessão explicitamente.
4. Validar progresso entre 0 e 100 e datas coerentes.
5. Declarar `belongs_to :usuario` e `:livro`.

**Concluído quando:**

- Histórico sempre pertence a usuário e livro.
- Progresso fora de 0..100 é rejeitado.
- Regra de um registro consolidado está documentada.

#### Task 2 — Atualizar histórico ao abrir/avançar leitura

**Objetivo:** Registrar atividade sem duplicar linhas indevidamente.

**Arquivos envolvidos:**

- `app/services/historico_leitura/registrar.rb`
- `app/controllers/api/v1/leitor_controller.rb`
- `app/models/historico_leitura.rb`

**O que fazer:**

1. Criar serviço que recebe `current_usuario`, livro e progresso.
2. Usar `find_or_initialize_by` para par `id_usuario`/`id_material` quando histórico consolidado for adotado.
3. Na primeira leitura preencher `data_inicio`; em novas leituras atualizar `data_ultima_leitura`.
4. Atualizar progresso somente com valor validado e dentro de 0..100.
5. Não criar histórico para visitante.

**Concluído quando:**

- Primeira leitura cria registro.
- Leituras posteriores atualizam o registro correto.
- Usuário não altera histórico de terceiros.

#### Task 3 — Criar tela de histórico

**Objetivo:** Exibir materiais recentes e permitir retomar.

**Arquivos envolvidos:**

- `src/views/MeuHistoricoView.vue`
- `src/components/historico/HistoricoItem.vue`
- `src/services/historicoService.js`

**O que fazer:**

1. Buscar histórico autenticado ordenado por `data_ultima_leitura` desc.
2. Exibir título, última leitura e progresso quando disponível.
3. Criar ação retomar que abre o leitor no livro.
4. Exibir estado vazio e impedir acesso sem login.

**Concluído quando:**

- Histórico apresenta somente registros do usuário.
- Retomar abre material autorizado.

### HU-15 — Salvar marcador de página

**História:** Como leitor autenticado, quero salvar minha posição em um livro, para continuar a leitura de onde parei.

**Requisitos:** RF11

**Critérios de aceitação:**

- Marcador pertence a um usuário e a um livro.
- Um usuário mantém no máximo um marcador atual por livro, conforme DER.
- Página deve ser positiva quando utilizada.
- Localização pode armazenar posição técnica de EPUB/PDF, conforme formato.

#### Task 1 — Gerar Model MarcadorPagina e migration

**Objetivo:** Persistir posição de leitura por usuário e material.

**Arquivos envolvidos:**

- `app/models/marcador_pagina.rb`
- `db/migrate/*_create_marcador_paginas.rb`

**O que fazer:**

1. Executar `bin/rails generate model MarcadorPagina usuario:references livro:references pagina_atual:integer localizacao:string data_atualizacao:datetime`.
2. Ajustar PK `id_marcador`; FKs para `usuarios(id_usuario)` e `livros(id_material)`; `pagina_atual` INT, `localizacao` VARCHAR(255) opcional e `data_atualizacao` timestamp.
3. Criar UNIQUE `[id_usuario, id_material]`.
4. Validar `pagina_atual` maior que zero quando não nula e `localizacao` com máximo de 255.
5. Preencher `data_atualizacao` em create/update.

**Concluído quando:**

- Um marcador por usuário/livro.
- Página inválida é rejeitada.
- FKs impedem marcadores órfãos.

#### Task 2 — Criar endpoints de marcador

**Objetivo:** Salvar, consultar e atualizar marcador do usuário atual.

**Arquivos envolvidos:**

- `config/routes.rb`
- `app/controllers/api/v1/marcadores_pagina_controller.rb`

**O que fazer:**

1. Criar `GET /marcadores_pagina?livro_id=` e `PUT`/`PATCH` para salvar posição.
2. Exigir autenticação.
3. Localizar marcador por `current_usuario` e `id_material`; usar `find_or_initialize_by`.
4. Permitir somente `pagina_atual` e `localizacao`; não aceitar `id_usuario`.
5. Validar que o livro existe e é acessível.

**Concluído quando:**

- Marcador é privado.
- Salvar novamente atualiza o existente.
- Visitante recebe 401.

#### Task 3 — Integrar marcador ao leitor Vue

**Objetivo:** Salvar posição e retomar leitura.

**Arquivos envolvidos:**

- `src/components/leitor/ControleMarcador.vue`
- `src/views/LeitorLivroView.vue`
- `src/services/marcadoresService.js`

**O que fazer:**

1. Ao abrir livro, buscar marcador do usuário autenticado.
2. Ao salvar posição, enviar página/localização atual ao backend.
3. Oferecer ação retomar do marcador.
4. Não prometer retomada para formatos que não exponham posição estável; tratar formato não suportado.

**Concluído quando:**

- Posição persiste após sair e entrar novamente.
- Marcador de outro usuário nunca é exibido.

---

## ÉPICO 6 — Acessibilidade, usabilidade e compatibilidade

**Objetivo:** Implementar interface acessível e recursos de acessibilidade priorizados, garantindo uso por diferentes públicos e tecnologias assistivas.

**Requisitos relacionados:** RF10; RNF01, RNF02, RNF03, RNF04, RNF05, RNF12.

**Dependências/decisões:** A lista final de recursos (leitura em voz alta, Libras, legendas, audiodescrição, contraste, fonte e espaçamento) deve ser validada com a SESFA e usuários. O documento sugere opções, não confirma que todas serão entregues.

### HU-16 — Navegar na plataforma com recursos de acessibilidade

**História:** Como pessoa que utiliza tecnologia assistiva, quero navegar por teclado e leitor de tela, para acessar as funções sem depender exclusivamente do mouse ou da visão.

**Requisitos:** RF10; RNF01, RNF02, RNF03, RNF12

**Critérios de aceitação:**

- Controles possuem nome acessível.
- Foco de teclado é visível e segue ordem lógica.
- Formulários informam erros associados aos campos.
- Imagens informativas possuem texto alternativo; decorativas são ignoradas por leitores de tela.
- Contraste e estrutura semântica são verificados.

#### Task 1 — Definir padrão de acessibilidade frontend

**Objetivo:** Criar diretrizes reutilizáveis para componentes Vue.

**Arquivos envolvidos:**

- `docs/frontend/acessibilidade.md` (criar)
- `src/components/ui/` (componentes compartilhados)

**O que fazer:**

1. Definir uso de HTML semântico, headings em ordem, labels, `aria-label` somente quando necessário e landmarks.
2. Definir foco visível, navegação por Tab/Shift+Tab/Enter/Espaço e escape em diálogos.
3. Definir mensagens de erro com `aria-describedby` e `aria-live` para feedback dinâmico.
4. Adotar critérios WCAG aplicáveis como referência de avaliação, sem afirmar conformidade antes de testar.

**Concluído quando:**

- Diretrizes documentadas.
- Componentes base seguem padrão.

#### Task 2 — Revisar telas com teclado e leitor de tela

**Objetivo:** Corrigir barreiras de navegação nas telas principais.

**Arquivos envolvidos:**

- `src/views/**/*.vue`
- `src/components/**/*.vue`

**O que fazer:**

1. Percorrer catálogo, detalhe, login, cadastro, administração e leitor somente com teclado.
2. Verificar foco após abrir/fechar modal e após atualização de resultados.
3. Testar nomes acessíveis de botões, campos e ícones.
4. Corrigir contraste, ordem de títulos, texto alternativo e anúncios de estado.

**Concluído quando:**

- Fluxos principais podem ser concluídos por teclado.
- Leitor de tela identifica controles e erros.

#### Task 3 — Validar acessibilidade com usuários

**Objetivo:** Coletar evidências de uso real, conforme RNF12.

**Arquivos envolvidos:**

- `docs/testes/relatorio-validacao-acessibilidade.md` (criar)

**O que fazer:**

1. Preparar roteiro com tarefas: localizar livro, abrir detalhe, iniciar leitura e ajustar preferências disponíveis.
2. Convidar participantes conforme viabilidade e autorização da SESFA, sem registrar dados sensíveis desnecessários.
3. Registrar barreiras observadas, gravidade e correção proposta.
4. Reexecutar roteiro após correções.

**Concluído quando:**

- Relatório registra participantes de forma protegida, cenários, achados e correções.
- Pendências são priorizadas.

### HU-17 — Utilizar recursos assistivos de conteúdo

**História:** Como leitor que necessita de recursos assistivos, quero utilizar as opções disponíveis para o material, para compreender seu conteúdo de forma adequada.

**Requisitos:** RF10; RNF01, RNF02

**Critérios de aceitação:**

- A interface indica quais recursos estão disponíveis em cada material.
- Leitura em voz alta, Libras, legendas ou audiodescrição são exibidas somente quando implementadas e associadas ao conteúdo correto.
- Ausência de recurso não é apresentada como disponibilidade.
- Controles possuem instruções e nomes acessíveis.

#### Task 1 — Mapear recursos e metadados necessários

**Objetivo:** Definir como cada recurso será representado sem criar tabelas além do DER acordado.

**Arquivos envolvidos:**

- `docs/decisoes-negocio/recursos_acessibilidade.md`
- `app/models/classificacao.rb`

**O que fazer:**

1. Com a SESFA, listar recursos obrigatórios por tipo de material.
2. Usar CLASSIFICACOES com tipo `acessibilidade` para registrar recursos disponíveis, quando adequado.
3. Definir onde ficarão arquivos alternativos (legenda, áudio, vídeo Libras, audiodescrição); o DER atual não possui tabela de anexos, portanto aprovar estratégia de armazenamento antes de implementar múltiplos arquivos.
4. Documentar formato, idioma e relação entre arquivo principal e recurso alternativo.

**Concluído quando:**

- Taxonomia aprovada.
- Cada recurso tem representação e origem definidas.

#### Task 2 — Implementar controles de acessibilidade do leitor

**Objetivo:** Expor somente recursos disponíveis no material.

**Arquivos envolvidos:**

- `src/components/leitor/RecursosAcessibilidade.vue`
- `src/views/LeitorLivroView.vue`
- `src/services/livrosService.js`

**O que fazer:**

1. Ler classificações e metadados do material.
2. Exibir controles apenas quando o recurso correspondente existir.
3. Implementar leitura em voz alta usando API/serviço aprovado e permitir iniciar, pausar e parar; se não houver suporte no navegador, informar indisponibilidade.
4. Para legendas/Libras/audiodescrição, integrar arquivos ou players definidos pela equipe.
5. Garantir controle por teclado e foco.

**Concluído quando:**

- Nenhum recurso indisponível aparece como funcional.
- Controles são acessíveis.
- Falhas de mídia são comunicadas.

### HU-18 — Ajustar apresentação e leitura

**História:** Como leitor, quero ajustar fonte, espaçamento, contraste e modo de exibição, para tornar a leitura confortável.

**Requisitos:** RF10, RF11; RNF01, RNF03

**Critérios de aceitação:**

- Preferências aprovadas podem ser ativadas e desativadas.
- Ajustes não ocultam conteúdo nem controles.
- Contraste permanece legível.
- Preferências podem ser mantidas durante a navegação; persistência entre dispositivos depende de decisão de armazenamento.

#### Task 1 — Criar preferências visuais no Vue

**Objetivo:** Implementar ajustes de apresentação sem exigir tabela adicional na versão inicial.

**Arquivos envolvidos:**

- `src/stores/preferenciasLeituraStore.js`
- `src/components/leitor/PreferenciasLeitura.vue`
- `src/assets/styles/accessibility.css`

**O que fazer:**

1. Criar estado para tamanho de fonte, espaçamento, contraste e tema, limitado a opções testadas.
2. Aplicar classes/variáveis CSS no contêiner do leitor, evitando alterar estilos globais de formulários sem teste.
3. Oferecer controles com rótulos claros e botão restaurar padrão.
4. Persistir localmente no navegador apenas se política de privacidade aprovar; para sincronizar entre dispositivos, será necessária decisão de adicionar campos/tabela.

**Concluído quando:**

- Ajustes afetam a área de leitura.
- Conteúdo permanece utilizável em zoom e telas menores.
- Preferências podem ser restauradas.

#### Task 2 — Testar responsividade e compatibilidade

**Objetivo:** Verificar navegação nos ambientes relevantes.

**Arquivos envolvidos:**

- `docs/testes/matriz-compatibilidade.md`
- `src/views/**/*.vue`

**O que fazer:**

1. Levantar com SESFA navegadores, sistemas operacionais e dispositivos prioritários.
2. Executar fluxos de catálogo, login, leitura e administração em cada combinação definida.
3. Testar diferentes larguras, zoom e orientação.
4. Registrar falhas e priorizar correções.

**Concluído quando:**

- Matriz de compatibilidade preenchida.
- Falhas críticas corrigidas ou formalmente aceitas.

---

## ÉPICO 7 — Administração de usuários e proteção de dados

**Objetivo:** Permitir que administradores gerenciem contas e que usuários exerçam operações permitidas sobre seus dados, com atenção especial a menores.

**Requisitos relacionados:** RF13, RF15, RF16; RNF08, RNF09.

**Dependências/decisões:** Procedimentos de menores, consentimento, retenção e exclusão precisam de definição da SESFA e validação jurídica/privacidade. Não coletar data de nascimento/documento de responsável sem necessidade e base definida.

### HU-19 — Administrar contas de usuários

**História:** Como administrador autorizado, quero consultar contas e bloquear ou corrigir informações permitidas, para manter o acesso alinhado às regras da ONG.

**Requisitos:** RF13

**Critérios de aceitação:**

- Somente administrador consulta a área administrativa.
- Administrador pode executar apenas operações autorizadas.
- Conta bloqueada não inicia nova sessão.
- Não é permitido alterar o próprio tipo para administrador por endpoint público.

#### Task 1 — Definir estado da conta

**Objetivo:** Definir representação de bloqueio sem alterar silenciosamente o DER.

**Arquivos envolvidos:**

- `docs/decisoes-negocio/gestao_usuarios.md`
- `db/migrate/*_add_status_to_usuarios.rb` (somente após aprovação)

**O que fazer:**

1. Confirmar com SESFA se bloqueio será necessário e quais estados existirão.
2. Como o DER atual não possui status, propor campo `status_usuario` ou `bloqueado_em`; documentar aprovação antes da migration.
3. Se aprovado, gerar migration com `bin/rails generate migration AddStatusUsuarioToUsuarios status_usuario:string` e adicionar default/NOT NULL/índice conforme estados.
4. Validar estados permitidos no Model e impedir autenticação de conta bloqueada.

**Concluído quando:**

- Regra de bloqueio aprovada.
- Estado é validado no backend e banco.

#### Task 2 — Criar endpoints administrativos de usuários

**Objetivo:** Permitir consulta e operações permitidas sem expor credenciais.

**Arquivos envolvidos:**

- `config/routes.rb`
- `app/controllers/api/v1/admin/usuarios_controller.rb`
- `app/serializers/usuario_admin_serializer.rb`

**O que fazer:**

1. Criar `index`/`show` e ações específicas de bloqueio/desbloqueio, se aprovadas.
2. Aplicar `exigir_administrador!`.
3. Não retornar senha/hash BCrypt.
4. Restringir campos atualizáveis; `tipo_usuario` só pode ser alterado por regra administrativa explícita e auditada no fluxo da aplicação.
5. Paginar resultados e evitar exposição de dados pessoais desnecessários.

**Concluído quando:**

- Leitor não acessa gestão.
- Respostas omitem senha.
- Operações respeitam estados e permissões.

#### Task 3 — Criar painel de usuários Vue

**Objetivo:** Oferecer interface administrativa de consulta e gestão.

**Arquivos envolvidos:**

- `src/views/admin/UsuariosView.vue`
- `src/components/admin/UsuarioDetalhe.vue`
- `src/services/admin/usuariosAdminService.js`

**O que fazer:**

1. Exibir nome, email, tipo e estado permitido.
2. Adicionar busca/paginação se necessário.
3. Exibir ação bloquear/desbloquear apenas quando aprovada.
4. Solicitar confirmação e apresentar resultado do backend.

**Concluído quando:**

- Administrador consulta contas.
- Leitor não visualiza painel.
- Ações não permitidas não aparecem e são bloqueadas no backend.

### HU-20 — Cadastrar crianças e adolescentes conforme procedimento

**História:** Como responsável pelo cadastro ou responsável legal, conforme fluxo definido pela SESFA, quero registrar o acesso de crianças e adolescentes com as autorizações necessárias, para permitir utilização adequada da biblioteca.

**Requisitos:** RF15; RNF09

**Critérios de aceitação:**

- Fluxo segue procedimento formal da SESFA.
- Quando autorização for exigida, acesso correspondente só é liberado após validação.
- Cadastro solicita somente dados aprovados.
- Não existe coleta de documento/contato sem finalidade e política definidas.

#### Task 1 — Levantar e documentar procedimento de menores

**Objetivo:** Impedir implementação de fluxo de consentimento inventado.

**Arquivos envolvidos:**

- `docs/decisoes-negocio/cadastro_menores.md`

**O que fazer:**

1. Solicitar à SESFA definição de faixas etárias e quem pode iniciar cadastro.
2. Definir se menores terão conta própria, conta vinculada ao responsável ou acesso sem conta.
3. Definir dados mínimos, evidência da autorização, validade, revogação e quem pode consultar.
4. Validar política de privacidade e requisitos legais aplicáveis antes de persistir dados.

**Concluído quando:**

- Fluxo aprovado por responsável institucional.
- Campos e regras estão especificados.

#### Task 2 — Ajustar modelo somente após aprovação

**Objetivo:** Persistir apenas informações necessárias ao procedimento aprovado.

**Arquivos envolvidos:**

- `app/models/usuario.rb`
- `db/migrate/*` (migration aprovada)
- `app/models/autorizacaoResponsavel.rb` (somente se aprovada nova entidade)

**O que fazer:**

1. Comparar procedimento aprovado com as dez tabelas existentes.
2. Se for possível representar com segurança sem entidade adicional, documentar como; se não, propor tabela específica de autorização e atualizar DER/backlog.
3. Adicionar validações de presença, estado, datas e vínculo responsável-menor conforme regra aprovada.
4. Não armazenar cópia de documento ou dado sensível sem necessidade documentada.

**Concluído quando:**

- Modelo corresponde ao fluxo aprovado.
- Integridade e acesso aos dados são testados.

#### Task 3 — Implementar fluxo frontend de autorização

**Objetivo:** Guiar responsável pelo procedimento aprovado.

**Arquivos envolvidos:**

- `src/views/CadastroMenorView.vue` (se aplicável)
- `src/components/cadastro/AutorizacaoResponsavel.vue`
- `src/services/cadastroMenorService.js`

**O que fazer:**

1. Implementar telas e campos exatamente conforme procedimento aprovado.
2. Exibir aviso de privacidade e finalidade dos dados.
3. Impedir conclusão antes da autorização quando exigida.
4. Permitir consultar estado da autorização somente a perfis autorizados.

**Concluído quando:**

- Fluxo respeita as condições aprovadas.
- Não há acesso indevido aos dados do menor.

### HU-21 — Consultar, corrigir ou solicitar exclusão dos próprios dados

**História:** Como usuário, quero consultar e corrigir meus dados e solicitar exclusão quando permitida, para manter minhas informações corretas e exercer meus direitos.

**Requisitos:** RF16; RNF09

**Critérios de aceitação:**

- Usuário consulta e altera somente seus próprios dados.
- Email permanece único após alteração.
- Senha não é exibida em consultas.
- Exclusão respeita retenção e obrigações definidas; não remove registros necessários sem política aprovada.

#### Task 1 — Criar endpoints de perfil

**Objetivo:** Permitir atualização segura de dados pessoais.

**Arquivos envolvidos:**

- `config/routes.rb`
- `app/controllers/api/v1/perfil_controller.rb`
- `app/models/usuario.rb`

**O que fazer:**

1. Criar `GET`/`PATCH /api/v1/perfil` protegidos por autenticação.
2. Buscar sempre `current_usuario`, sem aceitar `id_usuario` arbitrário na URL.
3. Permitir atualizar nome e email; senha deve ter fluxo separado e exigir confirmação da senha atual, se política aprovada.
4. Aplicar as mesmas validações de Usuario e omitir senha da resposta.

**Concluído quando:**

- Usuário não altera dados de terceiro.
- Email duplicado retorna 422.
- Hash de senha nunca é retornado.

#### Task 2 — Implementar solicitação/exclusão conforme retenção

**Objetivo:** Tratar exclusão sem quebrar relacionamentos e obrigações legais.

**Arquivos envolvidos:**

- `docs/decisoes-negocio/retencao_exclusao_dados.md`
- `app/services/usuarios/exclusao_service.rb` (após aprovação)

**O que fazer:**

1. Definir com SESFA se exclusão é imediata, anonimização, desativação ou solicitação analisada.
2. Mapear FKs de favoritos, listas, histórico, marcadores, livros cadastrados e acessos.
3. Definir o que será apagado, anonimizado ou retido e por quanto tempo.
4. Implementar transação que aplique a política sem deixar registros órfãos.
5. Registrar resposta clara ao usuário sem revelar dados de terceiros.

**Concluído quando:**

- Política formal aprovada.
- Exclusão/anonimização mantém integridade referencial.
- Testes cobrem usuário com e sem dados relacionados.

#### Task 3 — Criar tela de perfil e privacidade

**Objetivo:** Apresentar dados e ações de privacidade ao usuário.

**Arquivos envolvidos:**

- `src/views/MeuPerfilView.vue`
- `src/components/perfil/DadosPessoaisForm.vue`
- `src/services/perfilService.js`

**O que fazer:**

1. Exibir dados permitidos e formulário de edição.
2. Criar confirmação para solicitação de exclusão, explicando consequências.
3. Exibir status da solicitação quando aplicável.
4. Não apresentar senha armazenada.

**Concluído quando:**

- Usuário administra seus próprios dados.
- Ações respeitam política e retornam mensagens claras.

---

## ÉPICO 8 — Relatórios administrativos e operação do sistema

**Objetivo:** Disponibilizar indicadores para a gestão da SESFA a partir dos registros reais de usuários, livros e acessos, com filtros e proteção de acesso.

**Requisitos relacionados:** RF14; RNF06, RNF08, RNF11.

**Dependências/decisões:** Os indicadores exatos e a definição de usuário ativo precisam ser confirmados. Proposta inicial: usuário ativo = conta não bloqueada que realizou login/atividade no período, mas o DER não possui `ultimo_acesso`; será necessário definir se esse campo será adicionado ou se o indicador usará apenas usuários cadastrados.

### HU-22 — Consultar relatórios administrativos

**História:** Como gestor ou administrador autorizado, quero visualizar indicadores da biblioteca, para acompanhar utilização e crescimento do acervo.

**Requisitos:** RF14

**Critérios de aceitação:**

- Somente administrador/gestor autorizado acessa relatórios.
- Exibir total de livros cadastrados e crescimento por período.
- Exibir visualizações, leituras e downloads por período e materiais mais acessados.
- Exibir usuários ativos conforme definição aprovada.
- Relatórios são calculados a partir dos dados registrados; não precisam de tabela RELATORIOS.

#### Task 1 — Definir métricas e período de apuração

**Objetivo:** Formalizar cálculo de cada indicador.

**Arquivos envolvidos:**

- `docs/relatorios/definicao_indicadores.md`

**O que fazer:**

1. Definir período padrão e filtros (dia, mês, intervalo).
2. Definir se visualização e leitura são eventos distintos e quando cada um é gravado.
3. Definir usuário ativo (login no período, qualquer ação ou conta habilitada).
4. Definir se acessos de visitante entram em totais gerais e como são apresentados.
5. Documentar fuso horário e tratamento de eventos duplicados.

**Concluído quando:**

- Cada indicador possui fórmula, fonte e período definidos.
- SESFA aprova as definições.

#### Task 2 — Implementar consultas de relatório no Rails

**Objetivo:** Calcular indicadores com SQL/ActiveRecord sem tabela de relatório.

**Arquivos envolvidos:**

- `app/queries/relatorios/biblioteca_query.rb` (criar)
- `app/controllers/api/v1/admin/relatorios_controller.rb`
- `test/queries/relatorios/biblioteca_query_test.rb`

**O que fazer:**

1. Criar consultas para COUNT de livros e agrupamento por mês usando `data_cadastro`.
2. Agrupar ACESSOS\_MATERIAIS por `tipo_acesso` e período.
3. Agrupar acessos por `id_material` para materiais mais acessados e associar título do livro.
4. Calcular usuários ativos conforme definição; se exigir data do último acesso/login, aprovar campo `ultimo_acesso_em` em USUARIO ou usar evento de acesso autenticado com cuidado.
5. Aplicar filtros de data com parâmetros e índices; evitar N+1.

**Concluído quando:**

- Totais conferem com dados de teste conhecidos.
- Períodos e filtros funcionam.
- Consulta não expõe dados pessoais desnecessários.

#### Task 3 — Proteger e expor endpoint de relatórios

**Objetivo:** Disponibilizar dados agregados apenas a administradores.

**Arquivos envolvidos:**

- `config/routes.rb`
- `app/controllers/api/v1/admin/relatorios_controller.rb`
- `app/controllers/concerns/autorizacao_perfil.rb`

**O que fazer:**

1. Criar `GET /api/v1/admin/relatorios/resumo` e endpoints específicos se necessário.
2. Aplicar `exigir_administrador!`.
3. Permitir somente filtros de data conhecidos e validar início menor ou igual ao fim.
4. Retornar estrutura JSON documentada com totais e séries temporais.

**Concluído quando:**

- Leitor/visitante recebe 403/401.
- Resposta contém agregados, não listas desnecessárias de dados pessoais.

#### Task 4 — Construir painel de relatórios Vue

**Objetivo:** Apresentar indicadores de forma compreensível.

**Arquivos envolvidos:**

- `src/views/admin/RelatoriosView.vue`
- `src/components/admin/IndicadorCard.vue`
- `src/components/admin/GraficoAcessos.vue`
- `src/services/admin/relatoriosService.js`

**O que fazer:**

1. Criar cards para usuários ativos, livros, leituras e downloads conforme definições aprovadas.
2. Criar gráfico/tabela de materiais mais acessados.
3. Adicionar filtro de período e estado de carregamento.
4. Garantir que gráficos tenham alternativa textual/tabela para leitores de tela.
5. Exibir ausência de dados sem inventar zeros quando consulta falhar.

**Concluído quando:**

- Painel corresponde aos valores da API.
- Acesso restrito a administrador.
- Informações são acessíveis sem depender apenas de cor.

---

## 4. Tasks transversais — requisitos não funcionais

As tarefas abaixo não pertencem a uma única história; devem acompanhar o desenvolvimento de todos os épicos.

### TQ-01 — Segurança de API e dados (RNF08/RNF09)

- Configurar CORS somente para a origem do frontend definida por ambiente; não usar wildcard em produção com credenciais.
- Usar HTTPS em produção, cookies seguros quando aplicável, proteção CSRF quando a autenticação usar cookie e segredos via variáveis de ambiente.
- Aplicar strong parameters em todos os controllers; nunca aceitar campos de propriedade, perfil ou FK sensível sem regra explícita.
- Configurar rate limiting para login/cadastro e mensagens genéricas de autenticação.
- Não registrar senha, token, conteúdo privado ou dados de menores em logs.
- Revisar dependências, permissões de banco e backups; usuário de aplicação PostgreSQL não deve ser superuser.

### TQ-02 — Desempenho e disponibilidade (RNF06)

- Definir metas mensuráveis com SESFA (tempo de resposta, usuários simultâneos, disponibilidade e tamanho máximo de arquivo).
- Adicionar paginação ao catálogo, administração e relatórios.
- Adicionar índices em FKs e colunas usadas em filtros/ordenação: `id_categoria`, `id_usuario_cadastro`, `id_material`, `id_usuario`, `data_acesso` e `tipo_acesso`.
- Usar `includes`/`preload` nas consultas Rails para evitar N+1.
- Medir endpoints principais com conjunto de dados representativo e registrar resultados.

### TQ-03 — Armazenamento e crescimento (RNF11)

- Levantar quantidade atual de materiais, tamanho médio/máximo e crescimento anual estimado.
- Definir armazenamento de arquivos separado do banco PostgreSQL; manter no banco somente metadados/caminho ou referências do storage.
- Definir backup do PostgreSQL e dos arquivos, retenção e teste periódico de restauração.
- Monitorar espaço de armazenamento e crescimento de ACESSOS\_MATERIAIS.

### TQ-04 — Condições de conexão (RNF07)

- Perguntar à SESFA se é necessário modo offline ou funcionamento em conexão limitada; o documento deixa essa necessidade em aberto.
- Se não houver modo offline no escopo, otimizar imagens/arquivos, paginação e feedback de carregamento.
- Se offline for aprovado, elaborar história específica para cache, sincronização e conflitos; não presumir que o navegador offline terá acesso a arquivos protegidos.

### TQ-05 — Manutenção e suporte (RNF10)

- Definir responsável por hospedagem, domínio, certificados, monitoramento, backups e atualizações.
- Documentar instalação local, variáveis de ambiente, migrações, deploy e rollback.
- Definir canal e horário de suporte, janela de manutenção e plano de continuidade com a SESFA.

### TQ-06 — Compatibilidade e usabilidade (RNF03/RNF04/RNF05)

- Definir navegadores, dispositivos e sistemas operacionais prioritários.
- Testar fluxos completos em desktop e celular e diferentes níveis de familiaridade tecnológica.
- Validar linguagem simples, consistência de botões, mensagens e prevenção de erros.
- Verificar se a SESFA deseja interfaces distintas para crianças, adolescentes e adultos; requisito ainda precisa de validação.

## 5. Mapa de rastreabilidade dos requisitos

| Requisito | Cobertura no backlog |
| --- | --- |
| RF01 — Acesso à biblioteca | Épico 1 / HU-01 |
| RF02 — Cadastro e autenticação | Épico 2 / HU-04 e HU-05 |
| RF03 — Perfis e permissões | Épico 2 / HU-06 |
| RF04 — Pesquisa e filtros | Épico 1 / HU-02 |
| RF05 — Consulta ao acervo | Épico 1 / HU-03; Épico 3 / HU-07 |
| RF06 — Gerenciamento do acervo | Épico 3 / HU-07 e HU-08 |
| RF07 — Classificação dos materiais | Épico 1 / HU-02; Épico 3 / HU-09 |
| RF08 — Controle de acesso aos conteúdos | Épico 4 / HU-10 e HU-11 |
| RF09 — Acesso aos materiais digitais | Épico 4 / HU-10 |
| RF10 — Recursos de acessibilidade | Épico 6 / HU-16, HU-17 e HU-18 |
| RF11 — Personalização da leitura | Épico 5 / HU-12 a HU-15; Épico 6 / HU-18 |
| RF12 — Interação dos usuários | Fora da primeira versão: avaliações/comentários não foram aprovados explicitamente |
| RF13 — Administração de usuários | Épico 2 / HU-06; Épico 7 / HU-19 |
| RF14 — Relatórios administrativos | Épico 8 / HU-22 |
| RF15 — Cadastro de crianças e adolescentes | Épico 7 / HU-20; depende de política SESFA |
| RF16 — Gestão de dados pessoais | Épico 7 / HU-21 |
| RNF01/RNF02/RNF12 — Acessibilidade e validação | Épico 6 / HU-16 e HU-17 |
| RNF03/RNF04/RNF05 — Usabilidade, públicos e compatibilidade | Épicos 1 e 6; tasks transversais |
| RNF06/RNF07/RNF10/RNF11 — Operação, conexão e crescimento | Épicos 4 e 8; tasks transversais |
| RNF08/RNF09 — Segurança e privacidade | Épicos 2 e 7; tasks transversais |

## 6. Ordem sugerida de implementação

1. **Etapa 0 — Confirmar decisões pendentes:** política de acesso, status/publicação, storage de arquivos, formatos, regras de menores, retenção de dados, definição de usuário ativo e requisitos operacionais.
2. **Etapa 1 — Models e migrations:** Usuario, Categoria, Livro; depois Classificacao, AcessoMaterial, Favorito, ListaLeitura, ListaLeituraLivro, HistoricoLeitura e MarcadorPagina. Revisar FKs/PKs antes de migrar.
3. **Etapa 2 — Associações ActiveRecord e testes de integridade.** Não iniciar telas dependentes antes de validar as relações.
4. **Etapa 3 — Autenticação e autorização:** cadastro de leitor, criação segura do administrador inicial e proteção das rotas.
5. **Etapa 4 — API e Vue do catálogo público,** pesquisa, detalhe, categorias e gerenciamento de livros.
6. **Etapa 5 — Arquivos,** autorização de leitura/download e registro em ACESSOS\_MATERIAIS.
7. **Etapa 6 — Recursos pessoais:** favoritos, listas, histórico e marcadores.
8. **Etapa 7 — Acessibilidade,** classificações e ajustes de experiência.
9. **Etapa 8 — Administração de usuários,** procedimentos de menores e privacidade após aprovação das políticas.
10. **Etapa 9 — Relatórios,** testes de carga, compatibilidade, validação com usuários e preparação de operação.

## 7. Checklist de revisão antes de considerar o backlog pronto para sprint

- [ ] Cada história possui responsável de negócio e prioridade definidos pelo Product Owner.
- [ ] Cada critério de aceitação é verificável e não depende de interpretação subjetiva.
- [ ] Todas as migrations usam os nomes corretos de PK/FK do DER e índices UNIQUE necessários.
- [ ] Models declaram explicitamente `table_name`, `primary_key` e associações customizadas.
- [ ] Não há senha em texto puro nem hash retornado pela API.
- [ ] Rotas administrativas e dados pessoais são protegidos no backend.
- [ ] Usuários não conseguem acessar favoritos, listas, histórico ou marcadores de outras contas.
- [ ] ACESSOS\_MATERIAIS registra eventos de forma consistente e permite calcular RF14.
- [ ] Visitantes podem acessar somente o que a política pública permite; `id_usuario` é opcional apenas em ACESSOS\_MATERIAIS.
- [ ] Recursos de acessibilidade e regras de menores foram validados com a SESFA antes de serem declarados concluídos.
- [ ] Frontend apresenta loading, vazio, sucesso e erro; telas são navegáveis por teclado.
- [ ] Testes automatizados cobrem sucesso, validações, permissões, integridade e casos de acesso negado.

## 8. Observações finais e pontos que não devem ser presumidos

O documento oficial descreve algumas funções como condicionais ou dependentes de definição da SESFA. Por isso, este backlog separa o que está no escopo proposto do que precisa de aprovação. Não foram incluídas avaliações e comentários, porque o RF12 condiciona essas funções à aprovação e não há aprovação expressa no documento.

O DER de dez tabelas cobre os recursos escolhidos, mas não representa integralmente todas as regras ainda abertas. Em particular: estado de publicação/bloqueio, faixa etária e autorização de responsáveis podem exigir atributos ou tabelas adicionais depois da definição institucional. A equipe deve atualizar o DER e este backlog se essas decisões alterarem o modelo.

A tabela ACESSOS\_MATERIAIS é a fonte para relatórios de utilização; não é necessária uma tabela RELATORIOS. LOGS\_AUDITORIA também não integra esta versão. A segurança deve ser implementada mesmo sem essa tabela.

A recomendação de preservar as três entidades originais é mantida: USUARIO, LIVRO e CATEGORIA conservam os campos do diagrama enviado. As demais entidades seguem o DER inicial de dez tabelas, com as observações técnicas sobre PKs personalizadas e chave composta.
