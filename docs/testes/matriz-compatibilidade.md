# Matriz de compatibilidade

HU-18 Task 2. Navegadores, sistemas e dispositivos em que o sistema deve funcionar. A lista de prioridades abaixo
é uma **decisão da equipe, sem validação da SESFA**; ajustar se a SESFA informar o que usa. Preencher a coluna de
resultado a cada rodada de testes.

## 1. Combinações prioritárias

| Prioridade | Ambiente | Navegador | Resultado |
|---|---|---|---|
| Alta | Windows 10/11 | Chrome e Edge (atuais) | |
| Alta | Android (celular) | Chrome | |
| Alta | iPhone (iOS) | Safari | |
| Média | Windows | Firefox | |
| Média | macOS | Safari e Chrome | |
| Média | Linux | Firefox e Chromium | |
| Baixa | Tablet (Android e iPad) | Chrome e Safari | |

Leitores de tela a cobrir: NVDA com Firefox ou Chrome (Windows), VoiceOver com Safari (iPhone e Mac) e
TalkBack com Chrome (Android).

## 2. Fluxos testados em cada combinação

Marcar ✔ (ok), ✘ (falha, descrever na seção 4) ou — (não se aplica).

| Fluxo | O que verificar |
|---|---|
| Catálogo | Home, busca, filtros, acervo público |
| Detalhe | Página do livro e botões de ação |
| Login e cadastro | Formulários, erros por campo, recuperação de senha |
| Leitura | PDF (trocar de página, zoom, tela cheia), áudio, voz alta, marcador de página |
| Ajustes | Tamanho, espaço entre linhas, tema escuro, alto contraste, modo calmo |
| Administração | Livros, categorias, classificações, relatórios |

## 3. Condições a variar

- Larguras: 320, 375, 768 e 1280 px, em pé e deitado.
- Zoom do navegador em 200% e tamanho do texto A++ nos ajustes.
- Teclado apenas, sem mouse.
- Redução de movimento ligada no sistema.

## 4. Resultados

| Data | Ambiente | Fluxo | Resultado | Falha / observação | Prioridade |
|---|---|---|---|---|---|
| 24/11/2026 | Brave 157 (Chromium), Linux, 1280 e 375 px | Telas de visitante (home, entrar, criar conta, acervo, sobre) | ✔ sem falha crítica (axe, teclado, contraste claro e escuro, sem rolagem horizontal) | Veja `revisao-telas-acessibilidade.md`. Não cobriu telas logadas nem leitor de tela real. | — |

## 5. Critério de saída

- Falhas críticas corrigidas ou aceitas por escrito pela equipe.
- Combinações de prioridade **Alta** testadas nos seis fluxos.
