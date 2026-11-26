# Cantinho da Leitura

Sistema de Biblioteca Virtual desenvolvido com **Ruby on Rails**, **Vue.js**, **Vite** e **PostgreSQL**, com o objetivo de disponibilizar um ambiente digital para consulta, organização e acesso a materiais de leitura.

## 🚀 Tecnologias utilizadas

| Tecnologia | Versão / Descrição |
|---|---|
| Ruby | 3.4.13 |
| Ruby on Rails | 8.1.4.1 |
| Node.js | 26.13.0 |
| Vue.js | Framework JavaScript |
| Vite | Ferramenta de desenvolvimento Frontend |
| PostgreSQL | Sistema gerenciador de banco de dados |

## 📋 Pré-requisitos

Antes de iniciar o projeto, certifique-se de que as seguintes ferramentas estejam instaladas:

- [Ruby](https://www.ruby-lang.org/pt/)
- [Node.js](https://nodejs.org/)
- [PostgreSQL](https://www.postgresql.org/)
- [Git](https://git-scm.com/)

Recomenda-se utilizar as versões indicadas na seção de tecnologias utilizadas para evitar incompatibilidades.

## ⚙️ Instalação do projeto

Siga as etapas abaixo para obter o projeto e instalar suas dependências.

### 1. Clonar o repositório

```bash
git clone https://github.com/extension-projects/cantinhodaleitura.git
```

### 2. Acessar a pasta do projeto

```bash
cd cantinhodaleitura
```

### 3. Instalar as dependências do Ruby

Instale as gems necessárias para executar a aplicação Rails:

```bash
bundle install
```

### 4. Instalar as dependências do JavaScript

Instale os pacotes necessários para o Vue.js e Vite:

```bash
npm install
```

### 5. Configurar o banco de dados

Certifique-se de que o PostgreSQL esteja instalado e em execução.

Prepare o banco de dados utilizando:

```bash
bundle exec rails db:prepare
```

O comando prepara o banco de dados da aplicação, criando-o e executando as migrations pendentes quando necessário.

> **Observação:** Caso seja necessário, configure as credenciais de acesso ao PostgreSQL no arquivo `config/database.yml`.

Por padrão, o projeto usa o usuário `postgres`, o host `localhost`, a porta `5432` e os bancos
`cantinhodaleitura_development` e `cantinhodaleitura_test`. Esses valores podem ser sobrescritos
pelas variáveis `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`,
`DATABASE_NAME` e `DATABASE_TEST_NAME`.

## ▶️ Executando o projeto

Para executar a aplicação em ambiente de desenvolvimento, é necessário iniciar o servidor Backend (Rails) e o servidor Frontend (Vite).

Abra dois terminais na pasta raiz do projeto.

### Terminal 1 — Backend (Ruby on Rails)

Inicie o servidor Rails:

```bash
bundle exec rails server
```

### Terminal 2 — Frontend (Vue.js + Vite)

Inicie o servidor de desenvolvimento do Vite:

```bash
bundle exec vite dev
```

Após iniciar os dois servidores, acesse a aplicação pelo navegador:

**http://localhost:3000**

> **Importante:** Os dois servidores precisam permanecer em execução durante o desenvolvimento da aplicação.

## Deploy no Render

O arquivo `render.yaml` cria um serviço web Docker e um PostgreSQL no Render. A imagem instala o Node.js e as dependências do Vite antes de compilar os assets; as conexões Solid Cache, Solid Queue e Solid Cable usam o mesmo PostgreSQL. Na inicialização, o sistema roda `db:seed` para cadastrar os dois livros de exemplo e anexar as capas, PDFs e áudios que estão em `db/seeds/arquivos/livros`.

1. Envie o repositório para o GitHub.
2. No Render, escolha **New > Blueprint**, conecte este repositório e selecione a branch desejada.
3. Quando solicitado, informe `RAILS_MASTER_KEY` com o conteúdo local de `config/master.key`. Não coloque essa chave no repositório.
4. Crie os serviços e aguarde o build. O endereço público aparecerá no painel do serviço.

O Blueprint está configurado no plano gratuito para uma demonstração. Nesse plano, o serviço pode dormir após inatividade e o PostgreSQL gratuito expira após 30 dias. Os arquivos de exemplo são recuperados do repositório e anexados novamente na inicialização se o filesystem temporário for limpo; arquivos enviados pelos usuários não são persistidos. Para uso real, escolha planos pagos e configure armazenamento persistente (ou Active Storage em um serviço externo) antes de receber dados importantes. Consulte as [limitações atuais do plano gratuito do Render](https://render.com/docs/free).

## Autenticação da API

A API usa sessão Rails em cookie assinado e criptografado. O cookie é `HttpOnly`, não
fica disponível em `localStorage` e usa `Secure` automaticamente em produção. Por
padrão, `SameSite=Lax` protege a sessão; se o Vue e a API estiverem em sites diferentes,
configure `SESSION_COOKIE_SAME_SITE=none` e sirva a aplicação exclusivamente por HTTPS.

O frontend deve enviar o cookie nas requisições:

```js
fetch("/api/v1/sessao", {
	method: "POST",
	credentials: "include",
	headers: { "Content-Type": "application/json" },
	body: JSON.stringify({ email, password })
})
```

`POST /api/v1/sessao` inicia a sessão, `GET /api/v1/sessao` retorna o usuário
autenticado e `DELETE /api/v1/sessao` encerra a sessão. Rotas protegidas respondem
`401 Unauthorized` quando o cookie está ausente, inválido ou associado a um usuário
inativo.

## 📁 Estrutura do projeto

A aplicação segue a estrutura padrão do Ruby on Rails, com a organização dos arquivos do Frontend integrada ao projeto.

```text
cantinhodaleitura/
│
├── app/
│   ├── controllers/       # Controllers da aplicação
│   ├── models/            # Models e regras de domínio
│   ├── views/             # Views da aplicação
│   └── javascript/        # Código JavaScript e componentes Vue.js
│
├── config/                # Arquivos de configuração
│   └── database.yml       # Configurações do banco de dados
│
├── db/
│   ├── migrate/           # Migrations do banco de dados
│   └── schema.rb          # Estrutura atual do banco
│
├── test/                  # Testes automatizados
│
├── package.json           # Dependências e scripts JavaScript
├── Gemfile                # Dependências Ruby
├── Gemfile.lock           # Versões das gems instaladas
└── README.md              # Documentação do projeto
```

### Principais diretórios

| Diretório | Responsabilidade |
|---|---|
| `app/controllers/` | Receber requisições e coordenar as operações da aplicação. |
| `app/models/` | Representar as entidades e implementar regras de negócio. |
| `app/views/` | Organizar as views da aplicação. |
| `app/javascript/` | Armazenar o
