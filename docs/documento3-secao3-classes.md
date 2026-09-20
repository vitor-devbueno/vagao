# Documento 3 — Seção 3: Aplicação OO (classes de entidade, DAO, Servlets e JSPs)

Estado do projeto ao final da **Semana 5** (Web inalterada desde a Semana 4 + API JSON de
autenticação para o Mobile + aplicativo Flutter com login e navegação por perfil). Pronto
para copiar/adaptar no Documento 3.

Pacote base: `com.vagao`, subpacotes `entidade`, `dao`, `servlet`, `filtro`, `util`, **`api`**.

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
| **`AutenticacaoApiServlet`** (`com.vagao.api`) | `/api/auth/*` | POST `/login`, POST `/logout`, GET `/sessao` — respostas sempre em JSON |

`AutenticacaoApiServlet` reutiliza o mesmo `UsuarioDAO.autenticar` e o mesmo atributo de
sessão `usuarioLogado` do `LoginServlet`, incluindo o mesmo mecanismo de anti session
fixation (`getSession(false)` → `invalidate()` → `getSession(true)`). É a única fonte de
dados do aplicativo Mobile — não há acesso direto do app ao banco.

## 3.4 Classes da API (`com.vagao.api`)

Pacote novo desta semana, separado de `com.vagao.servlet` para deixar explícito no código
o que é infraestrutura do aplicativo Mobile.

| Classe | Responsabilidade |
|---|---|
| `AutenticacaoApiServlet` | Ver tabela de servlets acima |
| `JsonUtil` | `escrever`, `erro`, `usuarioParaJson` (nunca inclui a senha), `lerCorpo` |

## 3.5 Filtros e utilitários

| Classe | Mapeamento | Regra |
|---|---|---|
| `AdminFilter` | `/admin/*` | Exige sessão com `usuarioLogado.isAdmin()`; senão 403 |
| `ClienteFilter` | `/cliente/*` | Exige sessão com `usuarioLogado.isCliente()`; senão 403 |
| **`ApiAuthFilter`** | `/api/*` | Exige sessão com `usuarioLogado`, exceto na rota pública `/api/auth/login`; senão **401 JSON** (nunca `sendRedirect` — o consumidor é o app, não um navegador) |
| `Flash` | — | Mensagens de sucesso/erro que sobrevivem a um redirect (padrão PRG) |
| `SenhaUtil` | — | Geração de hash bcrypt para os seeds de teste |

## 3.6 JSPs (18 arquivos)

| Grupo | Arquivos |
|---|---|
| Raiz | `index.jsp`, `login.jsp` |
| Erro | `WEB-INF/erro403.jsp`, `erro404.jsp`, `erro500.jsp` |
| Admin | `admin/painel.jsp`, `views/admin/confirmar-exclusao.jsp`, `views/admin/categoria/{lista,form}.jsp`, `views/admin/produto/{lista,form}.jsp`, `views/admin/pedido/{lista,detalhe}.jsp` |
| Cliente | `cliente/area.jsp`, **`views/cliente/catalogo/{lista,detalhe}.jsp`**, **`views/cliente/pedido/{lista,detalhe}.jsp`** |

## Seção 4 — Aplicação Mobile (Flutter/Dart)

Projeto `mobile/vagao_app/`, criado nesta semana. Sem gerenciador de estado (`setState`
puro) e sem acesso direto a banco de dados — todo dado vem da API Java descrita nas seções
3.3/3.4. Pastas em português (`lib/telas`, `lib/servicos`, `lib/modelos`, `lib/tema`,
`lib/config`), arquivos em `snake_case`, classes em `UpperCamelCase`, conforme convenção do
restante do projeto.

| Classe | Camada | Responsabilidade |
|---|---|---|
| `VagaoApp` | App | `MaterialApp` raiz: tema, rota inicial (`TelaCarregamento`) e rotas nomeadas (`/login`, `/admin`, `/cliente`) |
| `Ambiente` | Configuração | `baseUrl` da API (`http://10.0.2.2:8080/vagao-web` no emulador) |
| `TemaVagao` | Visual | Cores, tipografia e `sombraDura` (`BoxShadow`) traduzindo a identidade visual da Web |
| `TelaCarregamento` | Tela | Tela inicial: consulta `GET /api/auth/sessao` e decide a navegação (login/admin/cliente), com retry manual em caso de falha de rede |
| `TelaLogin` | Tela | Formulário de login com validação local, botão desabilitado durante a requisição, mensagem de erro sem crash |
| `TelaHomeAdmin` | Tela | Home estática do perfil admin (cards "Produtos"/"Categorias"/"Pedidos"), botão Sair |
| `TelaHomeCliente` | Tela | Home estática do perfil cliente (cards "Catálogo"/"Meus pedidos"), botão Sair |
| `Usuario` | Modelo | Espelha a entidade Java: `idUsuario`, `nome`, `email`, `perfil`, `telefone`, `isAdmin`/`isCliente` |
| `ClienteHttp` | Rede | `Dio` configurado com `PersistCookieJar(ignoreExpires: true)` — persiste o `JSESSIONID` em disco entre aberturas do app |
| `ServicoAutenticacao` | Rede | `entrar`, `sessaoAtual`, `sair` — consomem `AutenticacaoApiServlet` |
| `ErroApi` | Rede | Exceção com a mensagem de erro vinda da API ou de falha de conexão |

## Nota de arquitetura

O projeto segue **MVC**: Model = entidade + DAO, Controller = Servlet, View = JSP.
Todo acesso a dados passa por `PreparedStatement` (nunca concatenação de SQL). A proteção
de rotas é feita por `Filter` baseado em perfil (`AdminFilter` para `/admin/*`,
`ClienteFilter` para `/cliente/*`, `ApiAuthFilter` para `/api/*`), com separação estrita: um
admin autenticado recebe 403 em `/cliente/*` e um cliente recebe 403 em `/admin/*`.

A criação de pedido (`PedidoDAO.inserir`) é a **única operação transacional** do sistema:
insere o cabeçalho do pedido, baixa o estoque de cada produto de forma atômica
(`UPDATE ... WHERE estoque >= ?`) e insere os itens, tudo dentro de uma única `Connection`
com `commit`/`rollback` explícitos — qualquer falha (estoque insuficiente ou erro de SQL)
desfaz a operação inteira.

O aplicativo Mobile **não fala com o banco em nenhum momento**: fala exclusivamente com a
API Java (`com.vagao.api`), que reutiliza os mesmos DAOs e a mesma regra de autenticação e
perfil já validados pela Web — uma única fonte de verdade para regra de negócio e
autenticação, compartilhada pelos dois clientes (Web e Mobile).
