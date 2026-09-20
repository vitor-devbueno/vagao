<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="pt_BR" />
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>VAGÃO — <c:out value="${produto.nome}" /></title>
    <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { background: #111; color: #f2f2f2; font-family: Georgia, 'Times New Roman', serif; min-height: 100vh; }
    .topo { display: flex; flex-wrap: wrap; gap: 16px; justify-content: space-between; align-items: center;
            background: #a8192e; border-bottom: 3px solid #111; padding: 16px 32px; }
    .topo .marca { font-family: 'Courier New', monospace; letter-spacing: 6px; text-transform: uppercase; color: #111; font-weight: bold; }
    .topo nav a { font-family: 'Courier New', monospace; font-size: 12px; letter-spacing: 2px; text-transform: uppercase;
                  color: #111; text-decoration: none; margin-left: 18px; }
    .topo nav a:hover, .topo nav a.ativo { text-decoration: underline; }
    main { max-width: 900px; margin: 0 auto; padding: 40px 16px; }
    h1 { font-size: 32px; font-weight: 900; text-transform: uppercase; margin-bottom: 8px; }
    .label, label, th { font-family: 'Courier New', monospace; font-size: 11px; letter-spacing: 2px; text-transform: uppercase; }
    .voltar { display: inline-block; margin-bottom: 24px; font-family: 'Courier New', monospace; font-size: 12px; color: #ccc; text-decoration: none; }
    .flash { padding: 12px; margin-bottom: 20px; font-family: 'Courier New', monospace; font-size: 13px; background: #1a1a1a; }
    .flash.sucesso { color: #8fd98f; border-left: 4px solid #8fd98f; }
    .flash.erro { color: #ff6b6b; border-left: 4px solid #ff6b6b; }
    .detalhe { display: grid; grid-template-columns: 1fr 1fr; gap: 32px; }
    @media (max-width: 700px) { .detalhe { grid-template-columns: 1fr; } }
    .thumb { aspect-ratio: 1 / 1; background: #a8192e; color: #111;
             display: flex; align-items: center; justify-content: center;
             font-family: 'Courier New', monospace; font-size: 64px; font-weight: bold; letter-spacing: 6px;
             box-shadow: 8px 8px 0 #1a1a1a; }
    .categoria { font-family: 'Courier New', monospace; font-size: 12px;
                 letter-spacing: 2px; text-transform: uppercase; color: #a8192e; margin-bottom: 16px; }
    .preco { font-family: 'Courier New', monospace; font-size: 28px; margin-bottom: 16px; }
    .descricao { margin-bottom: 24px; line-height: 1.6; }
    .estoque { font-family: 'Courier New', monospace; font-size: 13px; margin-bottom: 16px; }
    .esgotado { font-family: 'Courier New', monospace; font-size: 13px; color: #ff6b6b;
                border-left: 4px solid #ff6b6b; padding: 8px 12px; background: #1a1a1a; }
    .form-compra { display: flex; align-items: center; flex-wrap: wrap; gap: 8px; margin-top: 8px; }
    .form-compra input[type="number"] { padding: 12px; background: #f2f2f2; color: #111; border: none;
                                         font-family: 'Courier New', monospace; font-size: 14px; width: 80px; }
    .btn { display: inline-block; font-family: 'Courier New', monospace; font-size: 12px; font-weight: bold; letter-spacing: 2px;
           text-transform: uppercase; text-decoration: none; border: none; cursor: pointer; padding: 10px 16px;
           background: #a8192e; color: #f2f2f2; box-shadow: 4px 4px 0 #f2f2f2; }
    .btn:hover { background: #8a1426; }
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
        <a class="voltar" href="${pageContext.request.contextPath}/cliente/catalogo">← Voltar ao catálogo</a>

        <c:if test="${not empty flashMsg}">
            <div class="flash ${flashTipo}"><c:out value="${flashMsg}" /></div>
        </c:if>

        <div class="detalhe">
            <div class="thumb"><c:out value="${fn:toUpperCase(fn:substring(produto.nome, 0, 2))}" /></div>
            <div>
                <h1><c:out value="${produto.nome}" /></h1>
                <div class="categoria"><c:out value="${produto.categoria.nome}" /></div>
                <div class="preco"><fmt:formatNumber value="${produto.preco}" type="currency" /></div>
                <p class="descricao">
                    <c:choose>
                        <c:when test="${empty produto.descricao}">Sem descrição cadastrada.</c:when>
                        <c:otherwise><c:out value="${produto.descricao}" /></c:otherwise>
                    </c:choose>
                </p>

                <c:choose>
                    <c:when test="${produto.estoque > 0}">
                        <p class="estoque"><span class="label">Estoque:</span> ${produto.estoque} unidade(s) disponível(is)</p>
                        <form method="post" action="${pageContext.request.contextPath}/cliente/pedidos/novo" class="form-compra">
                            <input type="hidden" name="idProduto" value="${produto.idProduto}">
                            <label for="quantidade">Quantidade:</label>
                            <input type="number" id="quantidade" name="quantidade" value="1" min="1" max="${produto.estoque}" required>
                            <button type="submit" class="btn">Comprar</button>
                        </form>
                    </c:when>
                    <c:otherwise>
                        <p class="esgotado">Produto esgotado</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</body>
</html>
