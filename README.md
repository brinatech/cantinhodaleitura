# Cantinho da Leitura

Sistema de Biblioteca Virtual desenvolvido com **Ruby on Rails**, **Vue.js**, **Vite** e **PostgreSQL**, com o objetivo de disponibilizar um ambiente digital para consulta, organização e acesso a materiais de leitura.

## 🚀 Tecnologias utilizadas

| Tecnologia | Versão / Descrição |
|---|---|
| Ruby | 3.4.12 |
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