<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="pt_BR" />
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>VAGÃO — Produtos</title>
    <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { background: #111; color: #f2f2f2; font-family: Georgia, 'Times New Roman', serif; min-height: 100vh; }
    .topo { display: flex; flex-wrap: wrap; gap: 16px; justify-content: space-between; align-items: center;
            background: #a8192e; border-bottom: 3px solid #111; padding: 16px 32px; }
    .topo .marca { font-family: 'Courier New', monospace; letter-spacing: 6px; text-transform: uppercase; color: #111; font-weight: bold; }
    .topo nav a { font-family: 'Courier New', monospace; font-size: 12px; letter-spacing: 2px; text-transform: uppercase;
                  color: #111; text-decoration: none; margin-left: 18px; }
    .topo nav a:hover, .topo nav a.ativo { text-decoration: underline; }
    main { max-width: 1000px; margin: 0 auto; padding: 40px 16px; }
    h1 { font-size: 32px; font-weight: 900; text-transform: uppercase; margin-bottom: 24px; }
    .label, label, th { font-family: 'Courier New', monospace; font-size: 11px; letter-spacing: 2px; text-transform: uppercase; }
    .painel { background: #1a1a1a; border: 3px solid #a8192e; box-shadow: 8px 8px 0 #a8192e; padding: 24px; }
    .tabela-wrap { overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; }
    th { text-align: left; color: #a8192e; padding: 10px 8px; border-bottom: 2px solid #a8192e; }
    td { padding: 10px 8px; border-bottom: 1px solid #2a2a2a; vertical-align: top; }
    .num { text-align: right; font-family: 'Courier New', monospace; }
    .btn { display: inline-block; font-family: 'Courier New', monospace; font-size: 12px; font-weight: bold; letter-spacing: 2px;
           text-transform: uppercase; text-decoration: none; border: none; cursor: pointer; padding: 10px 16px;
           background: #a8192e; color: #f2f2f2; box-shadow: 4px 4px 0 #f2f2f2; }
    .btn:hover { background: #8a1426; }
    .btn-sec { background: #f2f2f2; color: #111; box-shadow: 4px 4px 0 #a8192e; }
    .btn-perigo { background: #111; color: #ff6b6b; border: 2px solid #ff6b6b; box-shadow: none; }
    .flash { padding: 12px; margin-bottom: 20px; font-family: 'Courier New', monospace; font-size: 13px; background: #1a1a1a; }
    .flash.sucesso { color: #8fd98f; border-left: 4px solid #8fd98f; }
    .flash.erro { color: #ff6b6b; border-left: 4px solid #ff6b6b; }
    .cabecalho-lista { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px; margin-bottom: 24px; }
    .cabecalho-lista h1 { margin-bottom: 0; }
    </style>
</head>
<body>
    <header class="topo">
      <span class="marca">V A G Ã O // admin</span>
      <nav>
        <a href="${pageContext.request.contextPath}/admin/painel.jsp">Painel</a>
        <a href="${pageContext.request.contextPath}/admin/produtos" class="ativo">Produtos</a>
        <a href="${pageContext.request.contextPath}/admin/categorias">Categorias</a>
        <a href="${pageContext.request.contextPath}/admin/pedidos">Pedidos</a>
        <a href="${pageContext.request.contextPath}/logout">Sair</a>
      </nav>
    </header>
    <main>
        <div class="cabecalho-lista">
            <h1>Produtos</h1>
            <a class="btn" href="${pageContext.request.contextPath}/admin/produtos/novo">+ Novo produto</a>
        </div>

        <c:if test="${not empty flashMsg}">
            <div class="flash ${flashTipo}"><c:out value="${flashMsg}" /></div>
        </c:if>

        <div class="painel">
            <c:choose>
                <c:when test="${empty produtos}">
                    <p>Nenhum produto cadastrado.
                        <a href="${pageContext.request.contextPath}/admin/produtos/novo">Cadastrar o primeiro</a>.
                    </p>
                </c:when>
                <c:otherwise>
                    <div class="tabela-wrap">
                        <table>
                            <thead>
                                <tr>
                                    <th>Nome</th><th>Descrição</th><th>Categoria</th>
                                    <th>Preço</th><th>Estoque</th><th>Ações</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${produtos}">
                                    <tr>
                                        <td><c:out value="${p.nome}" /></td>
                                        <td><c:out value="${p.descricao}" /></td>
                                        <td><c:out value="${p.categoria.nome}" /></td>
                                        <td class="num"><fmt:formatNumber value="${p.preco}" type="currency" /></td>
                                        <td class="num">${p.estoque}</td>
                                        <td>
                                            <a class="btn btn-sec" href="${pageContext.request.contextPath}/admin/produtos/editar?id=${p.idProduto}">Editar</a>
                                            <a class="btn btn-perigo" href="${pageContext.request.contextPath}/admin/produtos/excluir?id=${p.idProduto}">Excluir</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</body>
</html>
