<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="pt_BR" />
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>VAGÃO — Catálogo</title>
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
    .flash { padding: 12px; margin-bottom: 20px; font-family: 'Courier New', monospace; font-size: 13px; background: #1a1a1a; }
    .flash.sucesso { color: #8fd98f; border-left: 4px solid #8fd98f; }
    .flash.erro { color: #ff6b6b; border-left: 4px solid #ff6b6b; }
    .grade { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 24px; }
    .card { background: #1a1a1a; border: 3px solid #a8192e; box-shadow: 8px 8px 0 #a8192e;
            padding: 0 0 16px; text-decoration: none; color: inherit; display: block; }
    .thumb { aspect-ratio: 1 / 1; background: #a8192e; color: #111;
             display: flex; align-items: center; justify-content: center;
             font-family: 'Courier New', monospace; font-size: 40px; font-weight: bold; letter-spacing: 6px; }
    .card .corpo { padding: 16px; }
    .card h2 { font-size: 18px; text-transform: uppercase; margin-bottom: 8px; }
    .card .categoria { font-family: 'Courier New', monospace; font-size: 11px;
                       letter-spacing: 2px; text-transform: uppercase; color: #a8192e; }
    .card .preco { font-family: 'Courier New', monospace; font-size: 18px; margin-top: 8px; }
    </style>
</head>
<body>
    <header class="topo">
      <span class="marca">V A G Ã O // cliente</span>
      <nav>
        <a href="${pageContext.request.contextPath}/cliente/area.jsp">Início</a>
        <a href="${pageContext.request.contextPath}/cliente/catalogo" class="ativo">Catálogo</a>
        <a href="${pageContext.request.contextPath}/cliente/pedidos">Meus pedidos</a>
        <a href="${pageContext.request.contextPath}/logout">Sair</a>
      </nav>
    </header>
    <main>
        <h1>Catálogo</h1>

        <c:if test="${not empty flashMsg}">
            <div class="flash ${flashTipo}"><c:out value="${flashMsg}" /></div>
        </c:if>

        <c:choose>
            <c:when test="${empty produtos}">
                <p>Nenhum produto disponível no momento.</p>
            </c:when>
            <c:otherwise>
                <div class="grade">
                    <c:forEach var="p" items="${produtos}">
                        <a class="card" href="${pageContext.request.contextPath}/cliente/catalogo/detalhe?id=${p.idProduto}">
                            <div class="thumb"><c:out value="${fn:toUpperCase(fn:substring(p.nome, 0, 2))}" /></div>
                            <div class="corpo">
                                <h2><c:out value="${p.nome}" /></h2>
                                <div class="categoria"><c:out value="${p.categoria.nome}" /></div>
                                <div class="preco"><fmt:formatNumber value="${p.preco}" type="currency" /></div>
                            </div>
                        </a>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </main>
</body>
</html>
