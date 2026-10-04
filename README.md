# VAGÃO

Loja de streetwear autoral com identidade visual de sistema de transporte urbano. Trabalho
integrador acadêmico, composto por três partes no mesmo repositório: uma aplicação **Web**
(Java + JSP/Servlets, padrão MVC), um aplicativo **Mobile** (Flutter/Android) e um banco
**MySQL**.

---

## Estado atual

Tudo abaixo está implementado e funcionando ponta a ponta.

### Aplicação Web — área do cliente
- Login com senha em bcrypt e proteção contra *session fixation*
- Catálogo de produtos disponíveis (apenas com estoque > 0), com foto real ou placeholder
- Detalhe do produto com descrição, preço, estoque e compra
- Compra **transacional**: cria o pedido, baixa o estoque atomicamente e grava os itens — qualquer falha desfaz tudo
- "Meus pedidos" com checagem de propriedade no próprio SQL (um cliente nunca vê o pedido de outro)

### Aplicação Web — área administrativa
- CRUD de categorias
- CRUD de produtos, **com upload de foto** (JPEG, PNG ou WebP, até 2 MB)
- Consulta de todos os pedidos, detalhe e atualização de status
- Exclusão de produto bloqueada quando já existem pedidos vinculados

### API JSON (`/api/*`) — consumida pelo aplicativo
- Autenticação, encerramento e verificação de sessão (`/api/auth/*`)
- Catálogo e detalhe de produto (`/api/catalogo/*`)
- Pedidos do cliente: listar, detalhar e criar com carrinho de N itens (`/api/pedidos/*`)
- Rotas administrativas: contadores por status e consulta de pedidos (`/api/admin/*`)
- Proteção por perfil em filtros dedicados — respostas sempre em JSON, nunca redirect para HTML

### Aplicativo Mobile (Flutter/Android)
- Login reaproveitando a mesma sessão da Web, persistida em disco (continua logado ao reabrir)
- Navegação separada por perfil (cliente e administrador)
- Catálogo em grade, detalhe do produto, carrinho com vários itens e finalização de pedido
- "Meus pedidos" e detalhe do pedido
- Painel do administrador com contadores por status e consulta de pedidos recebidos

### Banco de dados
Seis tabelas: `usuario`, `categoria`, `produto`, `pedido`, `item_pedido` e `produto_imagem`
(a foto do produto é o único dado binário do sistema e vive em tabela própria, com
`ON DELETE CASCADE`).

### Em andamento
Redesign da camada visual da Web, com um *design system* próprio (`webapp/css/vagao.css` e
fontes locais). Já migrados: **login**, **área do cliente** e **catálogo (lista e detalhe)**.
Ainda com CSS embutido na própria página: telas **administrativas**, **meus pedidos** e
páginas de **erro**. Isso é só aparência — todas as telas funcionam normalmente.

---

## Estrutura do repositório

```
vagao/
├── database/            Scripts SQL (schema, seeds de teste e migração)
├── docs/                Documentos acadêmicos (requisitos e diagrama de classes)
├── mobile/vagao_app/    Aplicativo Flutter
├── web/vagao-web/       Aplicação Web Java (projeto Maven, empacota um .war)
├── PRODUCT.md           Briefing de marca e direção visual
└── README.md
```

Dentro de `web/vagao-web/src/main/java/com/vagao/`:

| Pacote | Responsabilidade |
|---|---|
| `entidade` | Classes de domínio (espelham as tabelas) |
| `dao` | Acesso a dados, sempre com `PreparedStatement` |
| `servlet` | Controladores da Web (JSP como view) |
| `api` | Endpoints JSON consumidos pelo aplicativo |
| `filtro` | Proteção de rotas por perfil |
| `util` | Apoio (mensagens flash, bcrypt, validação de upload) |

---

## Pré-requisitos

| Ferramenta | Versão | Observação |
|---|---|---|
| JDK | **17 ou superior** | O projeto compila com `release 17` |
| Apache Maven | 3.6+ | Para compilar e gerar o `.war` |
| MySQL | 8.x | |
| Apache Tomcat | **9.x — obrigatoriamente** | Ver o aviso logo abaixo |
| Flutter | 3.x (Dart ≥ 3.13.4) | Só para rodar o aplicativo |
| Android SDK + emulador | conforme o `flutter doctor` pedir | Só para rodar o aplicativo |

> ### ⚠️ Não use Tomcat 10 ou superior
> O projeto usa a API `javax.servlet` (Servlet 4.0). A partir do Tomcat 10, o pacote mudou
> para `jakarta.servlet`, e a aplicação **compila mas não sobe** — todas as rotas devolvem
> 404. Baixe a linha **9.x** em <https://tomcat.apache.org/download-90.cgi>.

---

## Como rodar

Os passos 1 a 3 são idênticos nos dois sistemas operacionais; só o passo 4 (implantar no
Tomcat) muda. Comandos são executados a partir da raiz do repositório.

### Passo 1 — Criar o banco e popular com dados de teste

Os scripts rodam **nesta ordem**. `schema.sql` cria o banco e as tabelas; os `seed_*`
inserem os dados de teste.

**Linux / macOS, ou Windows pelo `cmd.exe`:**

```bash
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed_usuarios.sql
mysql -u root -p < database/seed_catalogo.sql
mysql -u root -p < database/seed_pedidos.sql
mysql -u root -p < database/seed_cliente2.sql
```

**Windows pelo PowerShell** — o PowerShell não aceita o redirecionamento `<`, então use:

```powershell
Get-Content database\schema.sql        | mysql -u root -p
Get-Content database\seed_usuarios.sql | mysql -u root -p
Get-Content database\seed_catalogo.sql | mysql -u root -p
Get-Content database\seed_pedidos.sql  | mysql -u root -p
Get-Content database\seed_cliente2.sql | mysql -u root -p
```

Se o comando `mysql` não for reconhecido no Windows, use o caminho completo
(`"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"`) ou abra o **MySQL Command Line
Client** e rode `source C:/caminho/para/vagao/database/schema.sql;` em cada arquivo.

Em seguida, crie o usuário que a aplicação usa (conectado como `root`):

```sql
CREATE USER 'vagao_app'@'localhost' IDENTIFIED BY 'vagao123';
GRANT ALL PRIVILEGES ON vagao.* TO 'vagao_app'@'localhost';
FLUSH PRIVILEGES;
```

> `ALL PRIVILEGES` no schema `vagao` é proposital: além das operações do dia a dia, permite
> rodar scripts de migração (como `database/migracao_imagem_produto.sql`) sem precisar do
> `root`. Esse script de migração **só é necessário em um banco antigo**, criado antes da
> tabela `produto_imagem` — uma instalação nova já sai pronta pelo `schema.sql`.

### Passo 2 — Configurar as credenciais do banco

O arquivo real de configuração **não é versionado** (contém senha). Crie-o a partir do
exemplo:

```bash
# Linux / macOS
cp web/vagao-web/src/main/resources/db.properties.example \
   web/vagao-web/src/main/resources/db.properties
```

```powershell
# Windows
copy web\vagao-web\src\main\resources\db.properties.example web\vagao-web\src\main\resources\db.properties
```

Depois edite o arquivo criado e ajuste usuário e senha:

```properties
db.url=jdbc:mysql://localhost:3306/vagao?useSSL=false&serverTimezone=America/Sao_Paulo&allowPublicKeyRetrieval=true
db.user=vagao_app
db.password=vagao123
```

### Passo 3 — Compilar

```bash
cd web/vagao-web
mvn clean package
```

O resultado é `web/vagao-web/target/vagao-web.war`.

### Passo 4 — Implantar no Tomcat

O nome do arquivo define a URL: `vagao-web.war` responde em `/vagao-web`. **Não renomeie** —
o aplicativo Mobile e o cookie de sessão dependem desse caminho.

#### Linux — Tomcat instalado manualmente (ex.: `/opt/tomcat9`, rodando como serviço)

```bash
sudo cp web/vagao-web/target/vagao-web.war /opt/tomcat9/webapps/
sudo systemctl restart tomcat9
```

#### Linux — Tomcat instalado pelo gerenciador de pacotes

O diretório costuma ser `/var/lib/tomcat9/webapps/`:

```bash
sudo cp web/vagao-web/target/vagao-web.war /var/lib/tomcat9/webapps/
sudo systemctl restart tomcat9
```

#### Linux ou Windows — Tomcat extraído na pasta do usuário (sem privilégio de administrador)

Esta é a rota mais simples se você não quiser mexer em serviços do sistema. Baixe o pacote
do Tomcat 9, extraia em qualquer pasta e:

```bash
# Linux / macOS
cp web/vagao-web/target/vagao-web.war ~/apache-tomcat-9.0.x/webapps/
~/apache-tomcat-9.0.x/bin/shutdown.sh    # ignore o erro se ainda não estiver rodando
~/apache-tomcat-9.0.x/bin/startup.sh
```

```powershell
# Windows
copy web\vagao-web\target\vagao-web.war C:\apache-tomcat-9.0.x\webapps\
C:\apache-tomcat-9.0.x\bin\shutdown.bat
C:\apache-tomcat-9.0.x\bin\startup.bat
```

Na primeira execução no Linux pode ser necessário dar permissão de execução aos scripts:
`chmod +x ~/apache-tomcat-9.0.x/bin/*.sh`.

### Passo 5 — Acessar

Abra <http://localhost:8080/vagao-web/login>.

| Perfil | E-mail | Senha |
|---|---|---|
| Administrador | `admin@vagao.com` | `admin123` |
| Cliente | `cliente@vagao.com` | `cliente123` |
| Segundo cliente | `cliente2@vagao.com` | `cliente123` |

> O segundo cliente existe para demonstrar o isolamento entre contas: ele tem um pedido
> próprio que o primeiro cliente não consegue acessar.

**Verificação rápida de que a API também subiu** — deve responder `401` com um corpo JSON
(e não uma página HTML de erro):

```bash
curl -i http://localhost:8080/vagao-web/api/auth/sessao
```

---

## Rodando o aplicativo Mobile

Com o backend no ar (passos anteriores) e um emulador Android aberto:

```bash
cd mobile/vagao_app
flutter pub get
flutter devices     # confirme que o emulador aparece na lista
flutter run
```

As credenciais de teste são as mesmas da Web.

### Como o aplicativo encontra o backend

O endereço fica em `mobile/vagao_app/lib/config/ambiente.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:8080/vagao-web';
```

`10.0.2.2` é o apelido que o **emulador Android** usa para alcançar o `localhost` da máquina
hospedeira — funciona igual no Linux e no Windows, sem configuração extra.

**Para testar em um celular físico** na mesma rede Wi-Fi, troque pelo IP da máquina:

```dart
static const String baseUrl = 'http://192.168.1.11:8080/vagao-web';
```

Descubra o IP com `hostname -I` (Linux) ou `ipconfig` (Windows). No Windows, será preciso
liberar a porta 8080 no Firewall para que o celular alcance o servidor.

> O aplicativo trafega em HTTP puro (sem TLS), o que exige `usesCleartextTraffic` no
> `AndroidManifest.xml` — já configurado. É uma escolha deliberada de ambiente de
> desenvolvimento; em produção o backend serviria HTTPS.

---

## Armadilhas conhecidas

| Sintoma | Causa provável |
|---|---|
| Todas as rotas dão 404 depois do deploy | Tomcat 10 ou superior — o projeto exige a linha 9.x |
| `ERROR 1007: Can't create database 'vagao'` | O banco já existe. Rode `DROP DATABASE vagao;` antes, ou pule o `schema.sql` |
| `The '<' operator is reserved` no Windows | Você está no PowerShell — use a variante com `Get-Content` do passo 1 |
| Erro de conexão com o banco ao abrir a aplicação | `db.properties` não foi criado (passo 2) ou está com credenciais erradas |
| Porta 8080 ocupada | Outro serviço usando a porta; altere em `conf/server.xml` do Tomcat ou encerre o outro processo |
| O aplicativo não conecta no emulador | A `baseUrl` precisa ser `10.0.2.2`, não `localhost` — do emulador, `localhost` é o próprio aparelho |

---

## Documentação acadêmica

A pasta `docs/` reúne o texto pronto para os documentos entregues na disciplina — os
`.docx` oficiais ficam fora do repositório:

| Arquivo | Conteúdo |
|---|---|
| `documento2-semana4-rf-cliente-web.md` | Requisitos da área do cliente (Web) |
| `documento2-semana5-rf-mobile.md` | Requisitos de login e navegação no Mobile |
| `documento2-semana6-rf-mobile-dados.md` | Requisitos de catálogo e pedidos no Mobile |
| `documento2-semana7-rf-imagem-produto.md` | Requisitos de upload e exibição de imagem |
| `documento3-secao3-classes.md` | Estrutura de classes (Java e Dart), atualizada |

`PRODUCT.md` descreve a direção de marca e as decisões visuais que guiam o redesign.

---

## Convenções do projeto

- Commits em português, no formato `feat:` / `fix:` / `chore:` / `docs:`, em minúsculas e
  sem acento no prefixo.
- Código, nomes de classes e comentários em português, acompanhando o domínio do projeto.
- Todo acesso a dados passa por `PreparedStatement` — nunca concatenação de SQL.
- O aplicativo Mobile não fala com o banco: fala com a API Java, que reaproveita os mesmos
  DAOs da Web. Regra de negócio e autenticação têm uma única fonte de verdade.
