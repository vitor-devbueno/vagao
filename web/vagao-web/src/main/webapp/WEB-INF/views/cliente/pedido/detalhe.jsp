<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="pt_BR" />
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>VAGÃO — Pedido #${pedido.idPedido}</title>
    <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { background: #111; color: #f2f2f2; font-family: Georgia, 'Times New Roman', serif; min-height: 100vh; }
    .topo { display: flex; flex-wrap: wrap; gap: 16px; justify-content: space-between; align-items: center;
            background: #a8192e; border-bottom: 3px solid #111; padding: 16px 32px; }
    .topo .marca { font-family: 'Courier New', monospace; letter-spacing: 6px; text-transform: uppercase; color: #111; font-weight: bold; }
    .topo nav a { font-family: 'Courier New', monospace; font-size: 12px; letter-spacing: 2px; text-transform: uppercase;
                  color: #111; text-decoration: none; margin-left: 18px; }
    .topo nav a:hover, .topo nav a.ativo { text-decoration: underline; }
    main { max-width: 800px; margin: 0 auto; padding: 40px 16px; }
    h1 { font-size: 32px; font-weight: 900; text-transform: uppercase; margin-bottom: 8px; }
    .voltar { display: inline-block; margin-bottom: 24px; font-family: 'Courier New', monospace; font-size: 12px; color: #ccc; text-decoration: none; }
    .painel { background: #1a1a1a; border: 3px solid #a8192e; box-shadow: 8px 8px 0 #a8192e; padding: 24px; margin-bottom: 24px; }
    .cabecalho-pedido p { font-family: 'Courier New', monospace; font-size: 13px; margin-bottom: 6px; }
    .cabecalho-pedido .label { color: #a8192e; text-transform: uppercase; letter-spacing: 1px; }
    table { width: 100%; border-collapse: collapse; margin-top: 12px; }
    th { text-align: left; color: #a8192e; padding: 10px 8px; border-bottom: 2px solid #a8192e;
         font-family: 'Courier New', monospace; font-size: 11px; letter-spacing: 2px; text-transform: uppercase; }
    td { padding: 10px 8px; border-bottom: 1px solid #2a2a2a; }
    .num { text-align: right; font-family: 'Courier New', monospace; }
    .total-linha { text-align: right; font-family: 'Courier New', monospace; font-size: 16px; font-weight: bold; margin-top: 16px; }
    .flash { padding: 12px; margin-bottom: 20px; font-family: 'Courier New', monospace; font-size: 13px; background: #1a1a1a; }
    .flash.sucesso { color: #8fd98f; border-left: 4px solid #8fd98f; }
    .flash.erro { color: #ff6b6b; border-left: 4px solid #ff6b6b; }
    </style>
</head>
<body>
    <header class="topo">
      <span class="marca">V A G Ã O // cliente</span>
      <nav>
        <a href="${pageContext.request.contextPath}/cliente/area.jsp">Início</a>
        <a href="${pageContext.request.contextPath}/cliente/catalogo">Catálogo</a>
        <a href="${pageContext.request.contextPath}/cliente/pedidos" class="ativo">Meus pedidos</a>
        <a href="${pageContext.request.contextPath}/logout">Sair</a>
      </nav>
    </header>
    <main>
        <h1>Pedido #${pedido.idPedido}</h1>
        <a class="voltar" href="${pageContext.request.contextPath}/cliente/pedidos">← Voltar aos meus pedidos</a>

        <c:if test="${not empty flashMsg}">
            <div class="flash ${flashTipo}"><c:out value="${flashMsg}" /></div>
        </c:if>

        <div class="painel cabecalho-pedido">
            <p><span class="label">Data:</span> <fmt:formatDate value="${pedido.dataPedido}" pattern="dd/MM/yyyy HH:mm" /></p>
            <p><span class="label">Status atual:</span> <c:out value="${pedido.status}" /></p>
        </div>

        <div class="painel">
            <table>
                <thead>
                    <tr><th>Produto</th><th>Qtd</th><th>Preço unit.</th><th>Subtotal</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="item" items="${pedido.itens}">
                        <tr>
                            <td><c:out value="${item.produto.nome}" /></td>
                            <td class="num">${item.quantidade}</td>
                            <td class="num"><fmt:formatNumber value="${item.precoUnitario}" type="currency" /></td>
                            <td class="num"><fmt:formatNumber value="${item.subtotal}" type="currency" /></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
            <p class="total-linha">Total: <fmt:formatNumber value="${pedido.total}" type="currency" /></p>
        </div>
    </main>
</body>
</html>
