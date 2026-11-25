# Cadastro de crianças e adolescentes (HU-20) — VERSÃO PROPOSTA

> **Status: proposta da equipe, aguardando aprovação da SESFA.** O backlog (HU-20 Task 1) pede que o procedimento seja definido pela SESFA antes de ser usado, para não existir "fluxo de consentimento inventado". Como não foi possível falar com a ONG durante o projeto, a equipe implementou **uma proposta** com coleta mínima de dados, para a ONG avaliar. **Não deve ir para produção com crianças reais sem essa aprovação.** As telas mostram o aviso "Versão proposta".

## Por que precisa de cuidado

Dados de crianças e adolescentes têm proteção especial na LGPD (art. 14): o tratamento precisa do consentimento específico de pelo menos um dos pais ou do responsável legal, com esforço razoável para verificar que o consentimento veio mesmo dele, e só com os dados estritamente necessários.

## O modelo escolhido: o responsável cria a conta

1. Na tela "Criar conta" há o link **"criar uma conta para criança ou adolescente"** (`/criar-conta-crianca`).
2. **O responsável preenche**: o nome dele e o e-mail dele; o nome ou apelido da criança, um **nome de usuário** e a senha da conta.
3. Ele lê o **aviso de privacidade** e marca a declaração obrigatória: "Sou pai, mãe ou responsável legal [...] e autorizo".
4. A conta nasce **bloqueada** e o responsável recebe um **e-mail com um link** (vale 7 dias, uma resposta só).
5. No link (`/autorizar-menor`), ele vê o resumo e o aviso de novo e escolhe **Autorizar** ou **Não autorizo**.
   - Autorizar: a conta passa a entrar.
   - Não autorizo: o cadastro é **apagado**.
6. A criança entra com o **nome de usuário** e a senha, e usa a biblioteca como qualquer leitor.
7. Se ninguém responder em 7 dias, o cadastro é **apagado sozinho** (`LimparCadastrosMenoresPendentesJob`, todo dia às 3h em produção).

A confirmação pelo e-mail é o "esforço razoável" de verificação: quem autoriza precisa ter acesso ao e-mail informado como do responsável.

### Por que nome de usuário

Crianças pequenas geralmente não têm e-mail, e cada e-mail só pode ter uma conta (um responsável com dois filhos não conseguiria). O nome de usuário (3 a 30 caracteres: letras sem acento, números, `.`, `-`, `_`, nunca `@`) resolve isso; o login aceita e-mail **ou** nome de usuário (com `@` é e-mail).

## Dados guardados (coleta mínima)

| Dado | Para quê |
|---|---|
| Nome ou apelido da criança | Aparecer no cantinho dela |
| Nome de usuário e senha (hash) | Entrar sem e-mail |
| Nome e e-mail do responsável | Confirmar a autorização e recuperar a senha |
| Data da autorização (`autorizado_em`) | Provar quando o responsável autorizou |
| Uso da biblioteca (favoritos, listas, onde parou) | Continuar as leituras (igual aos outros leitores) |

**Não** são coletados: data de nascimento, idade exata, CPF, documentos, escola, endereço ou telefone.

## Outras regras

- A conta de menor é sempre **leitor**; não pode virar administrador por nenhum endpoint público.
- **Esqueci a senha**: com o nome de usuário, o link vai para o **e-mail do responsável**.
- **Meu perfil** da criança: troca o nome e a senha; não tem campo de e-mail.
- **Excluir a conta** (HU-21): funciona igual; além do nome e do nome de usuário, os dados do responsável também são apagados.
- **Administração (HU-19)**: filtro "Crianças e adolescentes", selo "Menor", responsável e situação da autorização. Só administrador vê (`exigir_administrador!`). O administrador pode desativar a conta como a de qualquer leitor.

## Onde está no código

- Banco: migration `AdicionaCadastroDeMenoresAosUsuarios` (`menor`, `nome_usuario`, `responsavel_nome`, `responsavel_email`, `autorizado_em`).
- Backend: `Usuario` (validações, `para_login`, token `autorizacao_responsavel`), `CadastrosMenoresController`, `AutorizacoesMenorController`, `UsuarioMailer#autorizar_menor`, `LimparCadastrosMenoresPendentesJob`.
- Front: `CadastroMenorView`, `AutorizacaoMenorView`, `components/cadastro/AvisoPrivacidadeMenor.vue`, `services/cadastroMenorService.js`.
- Em desenvolvimento os e-mails não são enviados de verdade: a tela de confirmação mostra o botão **"Abrir o link do e-mail"** (modo demonstração). Em produção ele não aparece.

## Perguntas para a SESFA

1. Até que idade a conta precisa do responsável (menos de 18? menos de 12, como o ECA define criança)? Adolescentes podem criar a própria conta com aviso ao responsável?
2. O cadastro pode ser feito pela internet, ou deve ser presencial na ONG (com autorização em papel)?
3. A confirmação por e-mail é suficiente, ou a ONG quer outra verificação?
4. O responsável deve poder ver o que a criança lê (histórico, favoritos)?
5. Um responsável com vários filhos: contas separadas (como está) ou uma conta dele com perfis?
6. Por quanto tempo guardar os dados depois que a criança para de usar a biblioteca?
