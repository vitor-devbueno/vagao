# Documento 2 — Requisitos Funcionais do aplicativo Mobile (login e navegação) — Semana 5

Os arquivos reais (`Documento2_Especificacao_de_Requisitos_VAGAO.docx` e
`Plano_de_Acao_Individual_VAGAO.docx`) estão fora do repositório, em `~/Downloads`, e são
`.docx` binários — este arquivo reúne o texto pronto para copiar neles manualmente.

## 10.1 Conferência dos RFs existentes

Os dois RFs já previstos para login e navegação do Mobile batem exatamente com o que foi
implementado nesta semana — **nenhum ajuste de texto é necessário**:

| RF | Texto do Documento 2 | Entregue por | Veredicto |
|---|---|---|---|
| RF15 | "Autenticar usuário (Mobile)." | `TelaLogin` + `ServicoAutenticacao.entrar` (POST `/api/auth/login`) + `AutenticacaoApiServlet` reutilizando `UsuarioDAO.autenticar` | ✅ |
| RF16 | "Navegação por perfil (Mobile)." | `TelaCarregamento` e `TelaLogin` ramificando por `usuario.isAdmin`/`isCliente` para `TelaHomeAdmin`/`TelaHomeCliente` | ✅ |

## 10.2 RF novo — RF23 (API de autenticação em JSON)

A API que sustenta o login do app **não tinha RF correspondente** no Documento 2: RF15/RF16
descrevem o comportamento do aplicativo, não a infraestrutura de servidor que o alimenta.
Acrescentar à tabela de RFs do Documento 2, **ao final, sem renumerar os existentes** (o
maior RF em uso até a Semana 4 era o RF22):

> **RF23 — Expor API de autenticação em JSON.** O sistema deverá expor endpoints em formato
> JSON para autenticação, encerramento de sessão e verificação de sessão ativa, destinados ao
> consumo pelo aplicativo Mobile, reutilizando o mesmo mecanismo de sessão e perfil da
> aplicação Web.

## 10.3 RF recomendado — RF24 (persistência de sessão no app)

A persistência de login entre aberturas do app é comportamento funcional, percebido e
testável pelo usuário (não é apenas um detalhe de implementação) — por isso recomenda-se
tratá-la como RF, e não apenas como RNF de usabilidade:

> **RF24 — Manter sessão no aplicativo.** O aplicativo deverá manter o usuário autenticado
> entre aberturas, enquanto a sessão permanecer válida no servidor, redirecionando-o à tela
> de login quando a sessão expirar ou for encerrada.

Evidência de conformidade: `TelaCarregamento` consulta `GET /api/auth/sessao` a cada
abertura do app e decide a navegação a partir da resposta real do servidor — nunca a partir
de um estado local que possa estar desatualizado. Testado manualmente nos cenários M6 (app
fechado e reaberto com sessão ainda válida → continua logado) e M8 (sessão invalidada no
servidor → app reaberto volta ao login, sem crash).

## 10.4 Plano de Ação — marcar semana como concluída

No `Plano_de_Acao_Individual_VAGAO.docx`, marcar como **Feito** na coluna correspondente:

- **Semana 5** — Mobile: login e navegação por perfil (esta entrega).

## 10.5 Observação para RNF05/RNF07

A API Mobile reutiliza a sessão e a checagem de perfil já validadas na Web, então os
mesmos RNFs continuam valendo, agora também no Mobile:

- **RNF05** (senha sempre em bcrypt, nunca trafegando em resposta): confirmado pelo teste A11
  — busca pela palavra `senha` e por hashes (`$2a$`/`$2b$`) em todas as respostas da API
  coletadas na bateria de testes, sem nenhuma ocorrência. `JsonUtil.usuarioParaJson` nunca
  inclui o campo `senha`.
- **RNF07** (navegação separada e coerente por perfil): confirmado pelos testes M10 (inspeção
  visual — nenhum elemento cruzado entre `TelaHomeAdmin` e `TelaHomeCliente`) e M11 (login
  admin → sair → login cliente não retém o perfil anterior).
