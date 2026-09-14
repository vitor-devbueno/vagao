<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="pt_BR" />
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>VAGÃO — Pedidos</title>
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
    th { text-align: left; color: #a8192e; padding: 10px 8px; border-bottom: 2px solid #a8192e;
         font-family: 'Courier New', monospace; font-size: 11px; letter-spacing: 2px; text-transform: uppercase; }
    .painel { background: #1a1a1a; border: 3px solid #a8192e; box-shadow: 8px 8px 0 #a8192e; padding: 24px; }
    .tabela-wrap { overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; }
    td { padding: 10px 8px; border-bottom: 1px solid #2a2a2a; vertical-align: top; }
    .num { text-align: right; font-family: 'Courier New', monospace; }
    .btn { display: inline-block; font-family: 'Courier New', monospace; font-size: 12px; font-weight: bold; letter-spacing: 2px;
           text-transform: uppercase; text-decoration: none; border: none; cursor: pointer; padding: 10px 16px;
           background: #a8192e; color: #f2f2f2; box-shadow: 4px 4px 0 #f2f2f2; }
    .btn:hover { background: #8a1426; }
    .btn-sec { background: #f2f2f2; color: #111; box-shadow: 4px 4px 0 #a8192e; }
    .status { font-family: 'Courier New', monospace; font-size: 11px; letter-spacing: 1px; text-transform: uppercase; }
    .cliente-email { display: block; color: #999; font-size: 12px; font-family: 'Courier New', monospace; }
    .flash { padding: 12px; margin-bottom: 20px; font-family: 'Courier New', monospace; font-size: 13px; background: #1a1a1a; }
    .flash.sucesso { color: #8fd98f; border-left: 4px solid #8fd98f; }
    .flash.erro { color: #ff6b6b; border-left: 4px solid #ff6b6b; }
    </style>
</head>
<body>
    <header class="topo">
      <span class="marca">V A G Ã O // admin</span>
      <nav>
        <a href="${pageContext.request.contextPath}/admin/painel.jsp">Painel</a>
        <a href="${pageContext.request.contextPath}/admin/produtos">Produtos</a>
        <a href="${pageContext.request.contextPath}/admin/categorias">Categorias</a>
        <a href="${pageContext.request.contextPath}/admin/pedidos" class="ativo">Pedidos</a>
        <a href="${pageContext.request.contextPath}/logout">Sair</a>
      </nav>
    </header>
    <main>
        <h1>Pedidos</h1>

        <c:if test="${not empty flashMsg}">
            <div class="flash ${flashTipo}"><c:out value="${flashMsg}" /></div>
        </c:if>

        <div class="painel">
            <c:choose>
                <c:when test="${empty pedidos}">
                    <p>Nenhum pedido registrado.</p>
                </c:when>
                <c:otherwise>
                    <div class="tabela-wrap">
                        <table>
                            <thead>
                                <tr><th>Nº</th><th>Data</th><th>Cliente</th><th>Total</th><th>Status</th><th></th></tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${pedidos}">
                                    <tr>
                                        <td>${p.idPedido}</td>
                                        <td><fmt:formatDate value="${p.dataPedido}" pattern="dd/MM/yyyy HH:mm" /></td>
                                        <td>
                                            <c:out value="${p.cliente.nome}" />
                                            <span class="cliente-email"><c:out value="${p.cliente.email}" /></span>
                                        </td>
                                        <td class="num"><fmt:formatNumber value="${p.total}" type="currency" /></td>
                                        <td class="status"><c:out value="${p.status}" /></td>
                                        <td><a class="btn btn-sec" href="${pageContext.request.contextPath}/admin/pedidos/detalhe?id=${p.idPedido}">Ver detalhes</a></td>
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
