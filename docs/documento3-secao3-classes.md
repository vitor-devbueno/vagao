# Documento 3 — Seção 3: Aplicação OO (classes de entidade, DAO, Servlets e JSPs)

Estado do projeto ao final da **Semana 4** (área do cliente: catálogo, detalhe de produto,
consulta dos próprios pedidos e realização de pedido). Pronto para copiar/adaptar no Documento 3.

Pacote base: `com.vagao`, subpacotes `entidade`, `dao`, `servlet`, `filtro`, `util`.

## 3.1 Classes de entidade (`com.vagao.entidade`)

Todas `Serializable`, com construtor público vazio e getters/setters padrão JavaBean.

| Classe | Atributos | Observações |
|---|---|---|
| `Usuario` | `idUsuario`, `nome`, `email`, `senha`, `perfil`, `telefone` | `isAdmin()`, `isCliente()`; senha em bcrypt, anulada após autenticar |
| `Categoria` | `idCategoria`, `nome` | — |
| `Produto` | `idProduto`, `nome`, `descricao`, `preco` (`BigDecimal`), `estoque`, `categoria` (`Categoria`) | Associação N:1 com Categoria |
| `Pedido` | `idPedido`, `dataPedido`, `status`, `cliente` (`Usuario`), `total` (`BigDecimal`), `itens` (`List<ItemPedido>`) | `STATUS_VALIDOS`; total derivado por `SUM` no SQL, não é coluna |
| `ItemPedido` | `idItemPedido`, `quantidade`, `precoUnitario` (`BigDecimal`), `produto` (`Produto`) | `getSubtotal()`; preço é *snapshot* do momento da compra |

## 3.2 Classes DAO (`com.vagao.dao`)

| Classe | Métodos públicos |
|---|---|
| `ConexaoFactory` | `getConexao()` |
| `UsuarioDAO` | `buscarPorEmail(String)`, `autenticar(String, String)` |
| `CategoriaDAO` | `listarTodas()`, `buscarPorId(int)`, `inserir(Categoria)`, `atualizar(Categoria)`, `excluir(int)`, `existeNome(String, int)`, `contarProdutos(int)` |
| `ProdutoDAO` | `listarTodos()`, **`listarDisponiveis()`**, `buscarPorId(int)`, `inserir(Produto)`, `atualizar(Produto)`, `excluir(int)`, `possuiPedidos(int)` |
| `PedidoDAO` | `listarTodos()`, **`listarPorUsuario(int)`**, `buscarPorId(int)`, **`buscarPorIdEUsuario(int, int)`**, **`inserir(Pedido)`**, `atualizarStatus(int, String)` |
| `EstoqueInsuficienteException` | Exceção de negócio (checked), lançada quando o estoque acaba durante a confirmação de um pedido |

(Itens em **negrito** são novos desta semana.)

## 3.3 Servlets (`com.vagao.servlet`)

| Classe | Rota | Ações |
|---|---|---|
| `LoginServlet` | `/login` | GET formulário, POST autenticação + redirecionamento por perfil |
| `LogoutServlet` | `/logout` | GET invalida sessão |
| `CategoriaServlet` | `/admin/categorias/*` | `/`, `/novo`, `/editar`, `/excluir`, POST `/salvar`, `/excluir` |
| `ProdutoServlet` | `/admin/produtos/*` | `/`, `/novo`, `/editar`, `/excluir`, POST `/salvar`, `/excluir` |
| `PedidoServlet` | `/admin/pedidos/*` | `/`, `/detalhe`, POST `/status` |
| **`CatalogoServlet`** | `/cliente/catalogo/*` | `/`, `/detalhe` |
| **`MeusPedidosServlet`** | `/cliente/pedidos/*` | `/`, `/detalhe`, POST `/novo` |

## 3.4 Filtros e utilitários

| Classe | Mapeamento | Regra |
|---|---|---|
| `AdminFilter` | `/admin/*` | Exige sessão com `usuarioLogado.isAdmin()`; senão 403 |
| `ClienteFilter` | `/cliente/*` | Exige sessão com `usuarioLogado.isCliente()`; senão 403 |
| `Flash` | — | Mensagens de sucesso/erro que sobrevivem a um redirect (padrão PRG) |
| `SenhaUtil` | — | Geração de hash bcrypt para os seeds de teste |

## 3.5 JSPs (18 arquivos)

| Grupo | Arquivos |
|---|---|
| Raiz | `index.jsp`, `login.jsp` |
| Erro | `WEB-INF/erro403.jsp`, `erro404.jsp`, `erro500.jsp` |
| Admin | `admin/painel.jsp`, `views/admin/confirmar-exclusao.jsp`, `views/admin/categoria/{lista,form}.jsp`, `views/admin/produto/{lista,form}.jsp`, `views/admin/pedido/{lista,detalhe}.jsp` |
| Cliente | `cliente/area.jsp`, **`views/cliente/catalogo/{lista,detalhe}.jsp`**, **`views/cliente/pedido/{lista,detalhe}.jsp`** |

## Nota de arquitetura

O projeto segue **MVC**: Model = entidade + DAO, Controller = Servlet, View = JSP.
Todo acesso a dados passa por `PreparedStatement` (nunca concatenação de SQL). A proteção
de rotas é feita por `Filter` baseado em perfil (`AdminFilter` para `/admin/*`,
`ClienteFilter` para `/cliente/*`), com separação estrita: um admin autenticado recebe 403
em `/cliente/*` e um cliente recebe 403 em `/admin/*`.

A criação de pedido (`PedidoDAO.inserir`) é a **única operação transacional** do sistema:
insere o cabeçalho do pedido, baixa o estoque de cada produto de forma atômica
(`UPDATE ... WHERE estoque >= ?`) e insere os itens, tudo dentro de uma única `Connection`
com `commit`/`rollback` explícitos — qualquer falha (estoque insuficiente ou erro de SQL)
desfaz a operação inteira.
