# Documento 3 — Seção 3: Aplicação OO (classes de entidade, DAO, Servlets e JSPs)

Estado do projeto ao final da **Semana 7** (Web e Mobile completos desde a Semana 6 + upload
de imagem de produto pelo admin, exibida no catálogo e no detalhe de ambos os clientes).
Pronto para copiar/adaptar no Documento 3.

Pacote base: `com.vagao`, subpacotes `entidade`, `dao`, `servlet`, `filtro`, `util`, **`api`**.

## 3.1 Classes de entidade (`com.vagao.entidade`)

Todas `Serializable`, com construtor público vazio e getters/setters padrão JavaBean.

| Classe | Atributos | Observações |
|---|---|---|
| `Usuario` | `idUsuario`, `nome`, `email`, `senha`, `perfil`, `telefone` | `isAdmin()`, `isCliente()`; senha em bcrypt, anulada após autenticar |
| `Categoria` | `idCategoria`, `nome` | — |
| `Produto` | `idProduto`, `nome`, `descricao`, `preco` (`BigDecimal`), `estoque`, `categoria` (`Categoria`), **`temImagem`** (`boolean`), **`imagemVersao`** (`Long`) | Associação N:1 com Categoria; `temImagem`/`imagemVersao` são derivados por `LEFT JOIN` com `produto_imagem` — não são coluna de `produto` |
| `Pedido` | `idPedido`, `dataPedido`, `status`, `cliente` (`Usuario`), `total` (`BigDecimal`), `itens` (`List<ItemPedido>`) | `STATUS_VALIDOS`; total derivado por `SUM` no SQL, não é coluna |
| `ItemPedido` | `idItemPedido`, `quantidade`, `precoUnitario` (`BigDecimal`), `produto` (`Produto`) | `getSubtotal()`; preço é *snapshot* do momento da compra |
| **`ProdutoImagem`** | `idProduto`, `mime`, `conteudo` (`byte[]`), `atualizadoEm` | Espelha a tabela `produto_imagem`; relação 1:1 com `Produto`, em tabela própria para o binário nunca ser carregado em listagens |

(Itens em **negrito** são novos da Semana 7.)

## 3.2 Classes DAO (`com.vagao.dao`)

| Classe | Métodos públicos |
|---|---|
| `ConexaoFactory` | `getConexao()` |
| `UsuarioDAO` | `buscarPorEmail(String)`, `autenticar(String, String)` |
| `CategoriaDAO` | `listarTodas()`, `buscarPorId(int)`, `inserir(Categoria)`, `atualizar(Categoria)`, `excluir(int)`, `existeNome(String, int)`, `contarProdutos(int)` |
| `ProdutoDAO` | `listarTodos()`, `listarDisponiveis()`, `buscarPorId(int)`, `inserir(Produto)`, `atualizar(Produto)`, `excluir(int)`, `possuiPedidos(int)` |
| `PedidoDAO` | `listarTodos()`, `listarPorUsuario(int)`, `buscarPorId(int)`, `buscarPorIdEUsuario(int, int)`, `inserir(Pedido)`, `atualizarStatus(int, String)`, `contarPorStatus()` |
| `EstoqueInsuficienteException` | Exceção de negócio (checked), lançada quando o estoque acaba durante a confirmação de um pedido |
| **`ProdutoImagemDAO`** | `salvar(int, String, byte[])` (insere ou substitui), `buscar(int)` (`null` se não houver), `excluir(int)` |

(Item em **negrito** é novo da Semana 7. `ProdutoDAO.SELECT_BASE` passou a trazer, via
`LEFT JOIN` com `produto_imagem`, os campos `tem_imagem` e `imagem_atualizada_em` que
alimentam `Produto.temImagem`/`imagemVersao` — o binário em si nunca é lido por esse SELECT,
só por `ProdutoImagemDAO.buscar`.)

## 3.3 Servlets (`com.vagao.servlet`)

| Classe | Rota | Ações |
|---|---|---|
| `LoginServlet` | `/login` | GET formulário, POST autenticação + redirecionamento por perfil |
| `LogoutServlet` | `/logout` | GET invalida sessão |
| `CategoriaServlet` | `/admin/categorias/*` | `/`, `/novo`, `/editar`, `/excluir`, POST `/salvar`, `/excluir` |
| `ProdutoServlet` | `/admin/produtos/*` | `/`, `/novo`, `/editar`, `/excluir`, POST `/salvar`, `/excluir` |
| `PedidoServlet` | `/admin/pedidos/*` | `/`, `/detalhe`, POST `/status` |
| `CatalogoServlet` | `/cliente/catalogo/*` | `/`, `/detalhe` |
| `MeusPedidosServlet` | `/cliente/pedidos/*` | `/`, `/detalhe`, POST `/novo` |
| `AutenticacaoApiServlet` (`com.vagao.api`) | `/api/auth/*` | POST `/login`, POST `/logout`, GET `/sessao` — respostas sempre em JSON |
| `CatalogoApiServlet` (`com.vagao.api`) | `/api/catalogo/*` | GET `/`, GET `/detalhe` |
| `PedidoApiServlet` (`com.vagao.api`) | `/api/pedidos/*` | GET `/`, GET `/detalhe`, POST `/novo` (carrinho com N itens; 409 em estoque insuficiente) |
| `AdminApiServlet` (`com.vagao.api`) | `/api/admin/*` | GET `/resumo` (contagem por status), GET `/pedidos`, GET `/pedidos/detalhe` |
| **`ImagemServlet`** | `/imagens/produtos/*` | GET streama a foto do produto (id no path); 404 se não houver foto, id inválido ou path malformado |

(Item em **negrito** é novo da Semana 7.) `AutenticacaoApiServlet` reutiliza o mesmo
`UsuarioDAO.autenticar` e o mesmo atributo de sessão `usuarioLogado` do `LoginServlet`,
incluindo o mesmo mecanismo de anti session fixation (`getSession(false)` → `invalidate()` →
`getSession(true)`). Os servlets de API reutilizam, sem duplicar lógica,
`ProdutoDAO.listarDisponiveis`/`buscarPorId` e `PedidoDAO.listarPorUsuario`/
`buscarPorIdEUsuario`/`inserir`/`listarTodos`/`buscarPorId`/`contarPorStatus` — os mesmos
métodos já validados pelos servlets Web. `ImagemServlet` é a única rota **pública** do
sistema (sem filtro): o `Image.network` do app Mobile não compartilha o cookie de sessão do
Dio, e o id no path é sempre validado por `Integer.parseInt`, o que elimina path traversal
como superfície de ataque. Nenhum desses servlets fala diretamente com o banco.

## 3.4 Classes da API (`com.vagao.api`)

Pacote criado na Semana 5, separado de `com.vagao.servlet` para deixar explícito no código
o que é infraestrutura do aplicativo Mobile.

| Classe | Responsabilidade |
|---|---|
| `AutenticacaoApiServlet` | Ver tabela de servlets acima |
| `CatalogoApiServlet` | Ver tabela de servlets acima |
| `PedidoApiServlet` | Ver tabela de servlets acima. O preço de cada item vem sempre de `Produto.getPreco()` lido do banco no momento da compra — nunca do corpo da requisição |
| `AdminApiServlet` | Ver tabela de servlets acima |
| `JsonUtil` | `escrever`, `erro`, `lerCorpo`, `usuarioParaJson` (nunca inclui a senha), `dinheiro` (formata `BigDecimal` como `String` com 2 casas — evita que o `org.json` corte zeros à direita, ex. `90.00` viraria `90`), `dataIso` (data/hora em ISO-8601), `categoriaParaJson`, `produtoParaJson`, `produtoResumoParaJson`, `itemPedidoParaJson`, `pedidoResumoParaJson`, `pedidoComItensParaJson`, `pedidoComClienteParaJson`, `pedidoAdminDetalheParaJson` |

Os quatro serializadores de pedido compõem uns sobre os outros para nunca vazar mais dado do
que cada perfil deve ver: o cliente nunca recebe dados de outro cliente
(`pedidoComItensParaJson`, sem `cliente`), e o admin recebe nome/e-mail do comprador
(`pedidoComClienteParaJson`/`pedidoAdminDetalheParaJson`).

**Novidade da Semana 7:** `produtoParaJson` passou a incluir o campo `"imagemUrl"` — caminho
relativo já versionado (`/imagens/produtos/{id}?v={imagemVersao}`) quando o produto tem foto,
ou `JSONObject.NULL` quando não tem, na mesma convenção de nulo explícito já usada para
`descricao`. `produtoResumoParaJson` (usado dentro de item de pedido) **não** ganhou o campo
— não há tela que exiba thumb de produto dentro de um pedido.

## 3.5 Filtros e utilitários

| Classe | Mapeamento | Regra |
|---|---|---|
| `AdminFilter` | `/admin/*` | Exige sessão com `usuarioLogado.isAdmin()`; senão 403 |
| `ClienteFilter` | `/cliente/*` | Exige sessão com `usuarioLogado.isCliente()`; senão 403 |
| `ApiAuthFilter` | `/api/*` | Exige sessão com `usuarioLogado`, exceto na rota pública `/api/auth/login`; senão 401 JSON (nunca `sendRedirect` — o consumidor é o app, não um navegador) |
| `ApiClienteFilter` | `/api/pedidos/*` | Exige sessão com `usuarioLogado.isCliente()`; sem sessão → 401 JSON, perfil errado → 403 JSON |
| `ApiAdminFilter` | `/api/admin/*` | Exige sessão com `usuarioLogado.isAdmin()`; sem sessão → 401 JSON, perfil errado → 403 JSON |
| `Flash` | — | Mensagens de sucesso/erro que sobrevivem a um redirect (padrão PRG) |
| `SenhaUtil` | — | Geração de hash bcrypt para os seeds de teste |
| **`ImagemUpload`** | — | `detectarMime(byte[])` — decide o tipo do arquivo pelos *magic bytes* do conteúdo (JPEG/PNG/WebP), nunca pela extensão do nome nem pelo `Content-Type` enviado pelo cliente; `TAMANHO_MAXIMO` (2 MB) |

(Item em **negrito** é novo da Semana 7.) `ApiClienteFilter` e `ApiAdminFilter` repetem a
própria checagem de autenticação (não delegam ao `ApiAuthFilter`) de propósito: filtros
mapeados por `@WebFilter` não têm ordem de execução garantida quando casam a mesma URL
(`/api/pedidos/*`/`/api/admin/*` estão dentro de `/api/*`), então cada um precisa ser
auto-suficiente e responder corretamente independentemente de qual filtro rodou primeiro.
`ImagemServlet` segue o mesmo raciocínio de auto-suficiência, mas na direção oposta: em vez
de exigir autenticação, ela deliberadamente **não tem filtro algum** — ver seção 3.3.

## 3.6 JSPs (18 arquivos)

| Grupo | Arquivos |
|---|---|
| Raiz | `index.jsp`, `login.jsp` |
| Erro | `WEB-INF/erro403.jsp`, `erro404.jsp`, `erro500.jsp` |
| Admin | `admin/painel.jsp`, `views/admin/confirmar-exclusao.jsp`, `views/admin/categoria/{lista,form}.jsp`, `views/admin/produto/{lista,form}.jsp`, `views/admin/pedido/{lista,detalhe}.jsp` |
| Cliente | `cliente/area.jsp`, **`views/cliente/catalogo/{lista,detalhe}.jsp`**, **`views/cliente/pedido/{lista,detalhe}.jsp`** |

## Seção 4 — Aplicação Mobile (Flutter/Dart)

Projeto `mobile/vagao_app/`, iniciado na Semana 5 e completado nesta semana com dados reais
de catálogo e pedidos. Sem gerenciador de estado externo — `setState` puro nas telas e
`ChangeNotifier`/`ListenableBuilder` (nativos do Flutter) só no carrinho, que é o único
estado compartilhado entre telas. Sem acesso direto a banco de dados — todo dado vem da API
Java descrita nas seções 3.3/3.4. Pastas em português (`lib/telas`, `lib/servicos`,
`lib/modelos`, `lib/tema`, `lib/config`, `lib/utils`, `lib/widgets`), arquivos em
`snake_case`, classes em `UpperCamelCase`, conforme convenção do restante do projeto.

| Classe | Camada | Responsabilidade |
|---|---|---|
| `VagaoApp` | App | `MaterialApp` raiz: tema, rota inicial (`TelaCarregamento`) e rotas nomeadas (`/login`, `/admin`, `/cliente`) |
| `Ambiente` | Configuração | `baseUrl` da API (`http://10.0.2.2:8080/vagao-web` no emulador) |
| `TemaVagao` | Visual | Cores, tipografia e `sombraDura` (`BoxShadow`) traduzindo a identidade visual da Web |
| `Formato` | Utilitário | `moeda` (`R$ 89,90`) e `dataHora` (`dd/MM/yyyy HH:mm`), formatação manual sem depender do pacote `intl` |
| `CardVagao` | Widget | Card compartilhado (painel + borda vermelha + `sombraDura`); promovido do `_CardEstatico` antes duplicado nas duas homes |
| `ThumbProduto` | Widget | Foto do produto quando cadastrada (`Image.network`), com placeholder de iniciais como fallback duplo — URL nula **ou** falha de carregamento (`errorBuilder`/`loadingBuilder`) |
| `PainelErro` | Widget | Mensagem de erro + botão "Tentar novamente", padrão único de falha de rede em todas as telas de lista |
| `TelaCarregamento` | Tela | Tela inicial: consulta `GET /api/auth/sessao` e decide a navegação (login/admin/cliente), com retry manual em caso de falha de rede |
| `TelaLogin` | Tela | Formulário de login com validação local, botão desabilitado durante a requisição, mensagem de erro sem crash |
| `TelaHomeCliente` | Tela | Home do cliente: navega para `TelaCatalogo` e `TelaMeusPedidos` (RF17/RF19) |
| `TelaCatalogo` | Tela | Grid de produtos disponíveis (RF17), badge do carrinho, GET `/api/catalogo` |
| `TelaDetalheProduto` | Tela | Detalhe do produto com seletor de quantidade e "Adicionar ao carrinho" (RF25) |
| `TelaCarrinho` | Tela | Lista de itens do carrinho, alteração de quantidade/remoção, POST `/api/pedidos/novo` (RF18) |
| `TelaMeusPedidos` | Tela | Lista dos próprios pedidos, GET `/api/pedidos` (RF19) |
| `TelaDetalhePedido` | Tela | Detalhe do pedido do cliente com itens e total, GET `/api/pedidos/detalhe` |
| `TelaHomeAdmin` | Tela | Painel "Status geral da loja": contadores por status (RF20) via GET `/api/admin/resumo`, mais atalho para `TelaPedidosAdmin` |
| `TelaPedidosAdmin` | Tela | Lista de todos os pedidos com dados do comprador, GET `/api/admin/pedidos` (RF20) |
| `TelaDetalhePedidoAdmin` | Tela | Detalhe do pedido para o admin (itens + comprador); não altera status — isso é exclusivo da Web (RF11) |
| `Usuario` | Modelo | Espelha a entidade Java: `idUsuario`, `nome`, `email`, `perfil`, `telefone`, `isAdmin`/`isCliente` |
| `Categoria` | Modelo | `idCategoria`, `nome` |
| `Produto` | Modelo | `idProduto`, `nome`, `descricao?`, `preco` (`double`, parseado de `String`), `estoque`, `categoria?`, **`imagemUrl?`** (`String?`, caminho relativo já versionado ou `null`); `disponivel`, `iniciais` |
| `ItemPedido` | Modelo | `idItemPedido`, `quantidade`, `precoUnitario`, `subtotal`, `idProduto`, `nomeProduto` |
| `Pedido` | Modelo | `idPedido`, `dataPedido` (`DateTime`), `status`, `total`, `itens` (default vazio), `nomeCliente?`, `emailCliente?` |
| `ResumoLoja` | Modelo | `totalPedidos`, `porStatus` (`Map<String,int>`) — espelha `GET /api/admin/resumo` |
| `ItemCarrinho` | Modelo | `produto`, `quantidade` (mutável), `subtotal` — existe só em memória, não tem equivalente no backend |
| `Carrinho` | Rede/Estado | `ChangeNotifier` singleton (`Carrinho.instancia`): `adicionar`, `alterarQuantidade`, `remover`, `limpar`, `totalItens`, `valorTotal` |
| `ClienteHttp` | Rede | `Dio` configurado com `PersistCookieJar(ignoreExpires: true)` — persiste o `JSESSIONID` em disco entre aberturas do app |
| `ServicoAutenticacao` | Rede | `entrar`, `sessaoAtual`, `sair` — consomem `AutenticacaoApiServlet` |
| `ServicoCatalogo` | Rede | `listar`, `buscar` — consomem `CatalogoApiServlet` |
| `ServicoPedidos` | Rede | `meusPedidos`, `buscar`, `realizar` — consomem `PedidoApiServlet`; `realizar` lança `ErroEstoque` em 409 |
| `ServicoAdmin` | Rede | `resumo`, `listarPedidos`, `buscarPedido` — consomem `AdminApiServlet` |
| `ErroApi` | Rede | Exceção com a mensagem de erro vinda da API ou de falha de conexão |
| `ErroEstoque` | Rede | Subclasse de `ErroApi` para o caso específico de estoque insuficiente (HTTP 409) — permite à `TelaCarrinho` manter os itens e convidar a reduzir a quantidade |

(Item em **negrito** é novo da Semana 7 — nenhuma classe nova, só o campo `imagemUrl` em
`Produto`. `ThumbProduto` também mudou de comportamento nesta semana, descrito acima.)

## Nota de arquitetura

O projeto segue **MVC**: Model = entidade + DAO, Controller = Servlet, View = JSP.
Todo acesso a dados passa por `PreparedStatement` (nunca concatenação de SQL). A proteção
de rotas é feita por `Filter` baseado em perfil (`AdminFilter` para `/admin/*`,
`ClienteFilter` para `/cliente/*`, `ApiAuthFilter` para `/api/*`, `ApiClienteFilter` para
`/api/pedidos/*`, `ApiAdminFilter` para `/api/admin/*`), com separação estrita: um admin
autenticado recebe 403 em `/cliente/*` e um cliente recebe 403 em `/admin/*` — e o mesmo
vale, ponta a ponta, entre `/api/pedidos/*` e `/api/admin/*` (testes B19/B23).

A criação de pedido (`PedidoDAO.inserir`) é a **única operação transacional** do sistema:
insere o cabeçalho do pedido, baixa o estoque de cada produto de forma atômica
(`UPDATE ... WHERE estoque >= ?`) e insere os itens, tudo dentro de uma única `Connection`
com `commit`/`rollback` explícitos — qualquer falha (estoque insuficiente ou erro de SQL)
desfaz a operação inteira.

O aplicativo Mobile **não fala com o banco em nenhum momento**: fala exclusivamente com a
API Java (`com.vagao.api`), que reutiliza os mesmos DAOs e a mesma regra de autenticação e
perfil já validados pela Web — uma única fonte de verdade para regra de negócio e
autenticação, compartilhada pelos dois clientes (Web e Mobile).

A foto do produto é o **único dado binário do sistema**. Vive em tabela própria
(`produto_imagem`, `LONGBLOB`) com `FOREIGN KEY ... ON DELETE CASCADE`, nunca em coluna de
`produto` nem em arquivo no disco do servidor — decisão tomada para não exigir diretório
externo ao `.war` (que é sobrescrito a cada novo deploy) nem comando `sudo` de configuração
de ambiente. É servida por `ImagemServlet`, a única rota **pública** do sistema (sem
`Filter`), porque o `Image.network` do Flutter não compartilha o cookie de sessão do `Dio` —
e toda URL de imagem é versionada (`?v=<atualizado_em>`) para que trocar a foto de um produto
invalide o cache do navegador e do app automaticamente, sem exigir reinício.
