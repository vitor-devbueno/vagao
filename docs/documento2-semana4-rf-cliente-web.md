# Documento 2 — Requisitos Funcionais da área do cliente (Web) — Semana 4

Os arquivos reais (`Documento2_Especificacao_de_Requisitos_VAGAO.docx` e
`Plano_de_Acao_Individual_VAGAO.docx`) estão fora do repositório, em `~/Downloads`, e são
`.docx` binários — este arquivo reúne o texto pronto para copiar neles manualmente.

## 9.1 Conferência dos RFs existentes

Os três RFs já previstos para o cliente Web batem exatamente com o que foi implementado
nesta semana — **nenhum ajuste de texto é necessário**:

| RF | Texto do Documento 2 | Entregue por | Veredicto |
|---|---|---|---|
| RF12 | "O sistema deverá exibir ao cliente a listagem de produtos disponíveis para compra." | `ProdutoDAO.listarDisponiveis()` (`estoque > 0`) + `CatalogoServlet` + `views/cliente/catalogo/lista.jsp` | ✅ |
| RF13 | "O sistema deverá exibir os detalhes de um produto selecionado pelo cliente." | `CatalogoServlet` (`/detalhe`) + `views/cliente/catalogo/detalhe.jsp` (descrição, preço, estoque) | ✅ |
| RF14 | "O sistema deverá permitir que o cliente consulte o histórico e o status dos seus próprios pedidos." | `PedidoDAO.listarPorUsuario` / `buscarPorIdEUsuario` + `MeusPedidosServlet` | ✅ ("seus próprios" = checagem de propriedade por `id_usuario` da sessão) |

## 9.2 RF novo — RF22 (realizar pedido pelo cliente Web)

O botão "Comprar" no detalhe do produto **não tinha RF correspondente** no Documento 2: o
único RF de realizar pedido existente é o **RF18**, explicitamente da aplicação **Mobile**.
Acrescentar à tabela de RFs do Documento 2, **ao final, sem renumerar os existentes**:

> **RF22 — Realizar pedido (cliente Web).** O sistema deverá permitir que o cliente realize
> um pedido a partir da tela de detalhes do produto, informando a quantidade desejada,
> registrando o pedido com status inicial "pendente" e baixando o estoque do produto de
> forma atômica.

## 9.3 Plano de Ação — marcar semanas como concluídas

No `Plano_de_Acao_Individual_VAGAO.docx`, marcar como **Feito** na coluna correspondente:

- **Semana 3** — CRUD administrativo (coluna estava em branco, apesar do código já commitado
  desde `78c6bb3`..`317898f`).
- **Semana 4** — Área do cliente (esta entrega).

## 9.4 Observação para RNF05/RNF07

Evidência a registrar no Documento 2 junto aos RNFs: o `ClienteFilter` passou a exigir
`usuarioLogado.isCliente()` (antes exigia apenas sessão autenticada, permitindo que um admin
também acessasse a área do cliente) e nenhuma view da área do cliente contém link para rotas
administrativas, e vice-versa (conferido por grep, sem ocorrências). Isso é evidência direta
do **RNF07** ("navegação separada e coerente por perfil").
