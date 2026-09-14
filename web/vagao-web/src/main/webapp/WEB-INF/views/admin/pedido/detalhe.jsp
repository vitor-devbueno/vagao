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
    select { padding: 12px; background: #f2f2f2; color: #111; border: none; font-family: 'Courier New', monospace; font-size: 14px; }
    .btn { display: inline-block; font-family: 'Courier New', monospace; font-size: 12px; font-weight: bold; letter-spacing: 2px;
           text-transform: uppercase; text-decoration: none; border: none; cursor: pointer; padding: 10px 16px;
           background: #a8192e; color: #f2f2f2; box-shadow: 4px 4px 0 #f2f2f2; margin-left: 12px; }
    .form-status { display: flex; align-items: center; flex-wrap: wrap; gap: 8px; margin-top: 8px; }
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
        <h1>Pedido #${pedido.idPedido}</h1>
        <a class="voltar" href="${pageContext.request.contextPath}/admin/pedidos">← Voltar aos pedidos</a>

        <c:if test="${not empty flashMsg}">
            <div class="flash ${flashTipo}"><c:out value="${flashMsg}" /></div>
        </c:if>

        <div class="painel cabecalho-pedido">
            <p><span class="label">Data:</span> <fmt:formatDate value="${pedido.dataPedido}" pattern="dd/MM/yyyy HH:mm" /></p>
            <p><span class="label">Cliente:</span> <c:out value="${pedido.cliente.nome}" /> (<c:out value="${pedido.cliente.email}" />)</p>
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

        <div class="painel">
            <form method="post" action="${pageContext.request.contextPath}/admin/pedidos/status" class="form-status">
                <input type="hidden" name="id" value="${pedido.idPedido}">
                <label for="status">Atualizar status:</label>
                <select id="status" name="status">
                    <c:forEach var="s" items="${statusValidos}">
                        <option value="${s}" ${s == pedido.status ? 'selected' : ''}><c:out value="${s}" /></option>
                    </c:forEach>
                </select>
                <button type="submit" class="btn">Atualizar status</button>
            </form>
        </div>
    </main>
</body>
</html>
