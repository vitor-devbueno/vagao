# Documento 2 — Requisitos Funcionais de dados reais no Mobile (catálogo e pedidos) — Semana 6

Os arquivos reais (`Documento2_Especificacao_de_Requisitos_VAGAO.docx` e
`Plano_de_Acao_Individual_VAGAO.docx`) estão fora do repositório, em `~/Downloads`, e são
`.docx` binários — este arquivo reúne o texto pronto para copiar neles manualmente.

## 11.1 🔴 Pendência das semanas anteriores — resolver antes de prosseguir

O `.docx` real ainda **termina no RF21**: os RF22 (Semana 4), RF23 e RF24 (Semana 5) foram
redigidos nos respectivos `docs/documento2-semana*.md`, mas **nunca copiados para o
documento oficial**. Antes de acrescentar os RFs desta semana, copiar os três pendentes —
senão a numeração RF25/RF26 abaixo fica órfã, sem RF22–24 antecedendo-a no documento real.

## 11.2 Conferência dos RFs existentes

Os RFs já previstos para dados reais no Mobile batem exatamente com o que foi implementado
nesta semana — **nenhum ajuste de texto é necessário**:

| RF | Texto do Documento 2 | Entregue por | Veredicto |
|---|---|---|---|
| RF17 | "O aplicativo deverá exibir ao cliente o catálogo de produtos conectado ao banco de dados." | `TelaCatalogo` + `ServicoCatalogo` + `CatalogoApiServlet` sobre `ProdutoDAO.listarDisponiveis()` | ✅ |
| RF18 | "O aplicativo deverá permitir que o cliente realize um pedido pelo app." | `TelaCarrinho` + `ServicoPedidos.realizar` + `PedidoApiServlet` sobre `PedidoDAO.inserir` (transacional, N itens) | ✅ — o carrinho é o *meio* de compor o pedido, não um requisito à parte |
| RF19 | "O aplicativo deverá permitir que o cliente acompanhe o status do seu pedido." | `TelaMeusPedidos` + `TelaDetalhePedido` sobre `PedidoDAO.buscarPorIdEUsuario` (checagem de propriedade) | ✅ |
| RF20 | "O aplicativo deverá permitir que o administrador consulte os pedidos recebidos e o status geral da loja." | `TelaHomeAdmin` (contadores por status via `/api/admin/resumo`) + `TelaPedidosAdmin` + `TelaDetalhePedidoAdmin` | ✅ — "status geral da loja" materializado como contagem de pedidos por status (`PedidoDAO.contarPorStatus`) |

## 11.3 RF novo — RF25 (detalhe de produto no Mobile)

O RF13 cobre o detalhe do produto **explicitamente na Web**; não havia RF equivalente para
o Mobile, e a tela `TelaDetalheProduto` (com descrição, preço e formulário de compra) não
tinha cobertura textual. Acrescentar à tabela de RFs do Documento 2, **ao final, sem
renumerar os existentes** (o maior em uso até a Semana 5 é o RF24):

> **RF25 — Detalhar produto (Mobile).** O aplicativo deverá exibir os detalhes de um
> produto selecionado pelo cliente, incluindo descrição, preço e disponibilidade em
> estoque.

## 11.4 RF novo — RF26 (API de dados em JSON)

O RF23 (Semana 5) cobre **apenas** autenticação, logout e verificação de sessão. Os
endpoints de catálogo e pedidos criados nesta semana (`/api/catalogo/*`, `/api/pedidos/*`,
`/api/admin/*`) não têm cobertura em nenhum RF existente — nem no RF23, nem nos RF17–RF20,
que descrevem o comportamento do aplicativo, não a infraestrutura de servidor que o
sustenta.

> **RF26 — Expor API de dados em JSON.** O sistema deverá expor endpoints em formato JSON
> para consulta do catálogo, consulta e criação de pedidos do cliente, e consulta
> administrativa de pedidos e do status geral da loja, destinados ao consumo pelo
> aplicativo Mobile, reutilizando as mesmas regras de acesso por perfil da aplicação Web.

## 11.5 Plano de Ação — marcar semana como concluída

No `Plano_de_Acao_Individual_VAGAO.docx`, marcar como **Feito** na coluna correspondente:

- **Semana 6** — Mobile: catálogo, pedidos do cliente e painel do admin com dados reais
  (esta entrega).

## 11.6 Observação para RNF05/RNF06/RNF07

- **RNF05** (senha sempre em bcrypt, nunca em resposta): teste B24 buscou a palavra `senha`
  e hashes (`$2a$`/`$2b$`) em todas as respostas coletadas da bateria B1–B28, sem nenhuma
  ocorrência.
- **RNF06** (desempenho aceitável): o catálogo e a listagem de pedidos reaproveitam os
  mesmos `SELECT` já validados nas Semanas 3–4; `contarPorStatus` é uma única consulta
  agregada (`GROUP BY`), não uma varredura de todos os pedidos em memória.
- **RNF07** (navegação separada por perfil): confirmado pelos testes B19/B23 (403 cruzado
  entre `/api/admin/*` e `/api/pedidos/*` na API) e M16 (nenhum elemento de um perfil visível
  na navegação do outro, reconfirmado após login sequencial admin→cliente).

## 11.7 Nota de segurança adicional (IDOR e integridade de preço)

Dois testes desta semana são o equivalente Mobile de proteções já validadas na Web:

- **B8** — um cliente autenticado que tenta acessar `/api/pedidos/detalhe?id=<pedido de
  outro cliente>` recebe **404** (não 403, para não revelar que o pedido existe). Mesma
  defesa de `buscarPorIdEUsuario` já testada na Web (R3, Semana 4).
- **B18** — um valor de `preco` forjado no corpo de `POST /api/pedidos/novo` é **ignorado**:
  o preço gravado vem sempre de `produtoDAO.buscarPorId(id).getPreco()`, nunca do request
  (reafirma a decisão D6 da Semana 4, agora também no Mobile).
