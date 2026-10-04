<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="pt_BR" />
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>VAGÃO — <c:out value="${produto.nome}" /></title>
    <link rel="preload" href="${pageContext.request.contextPath}/fonts/libre-caslon-text-400.woff2" as="font" type="font/woff2" crossorigin>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/vagao.css">
</head>
<body class="pagina-cliente">
    <c:set var="paginaAtiva" value="catalogo" scope="request" />
    <%@ include file="/WEB-INF/fragmentos/cliente-topo.jspf" %>

    <main class="detalhe">
        <a class="voltar" href="${pageContext.request.contextPath}/cliente/catalogo">Voltar ao catálogo</a>

        <c:if test="${not empty flashMsg}">
            <div class="alerta alerta--${flashTipo}" role="${flashTipo == 'erro' ? 'alert' : 'status'}">
                <strong class="alerta__prefixo">${flashTipo == 'erro' ? 'Erro:' : 'OK:'}</strong> <c:out value="${flashMsg}" />
            </div>
        </c:if>

        <div class="detalhe__grade">
            <div class="detalhe__midia">
                <div class="produto__midia">
                    <%-- Placeholder sempre presente atrás da foto: aparece se não houver foto, se ela falhar ou enquanto carrega --%>
                    <span class="produto__inicial" aria-hidden="true"><c:out value="${fn:substring(produto.nome, 0, 1)}" /></span>
                    <c:if test="${produto.temImagem}">
                        <img class="produto__foto"
                             src="${pageContext.request.contextPath}/imagens/produtos/${produto.idProduto}?v=${produto.imagemVersao}"
                             alt="<c:out value='${produto.nome}' />"
                             decoding="async"
                             onerror="this.remove()">
                    </c:if>
                </div>
            </div>

            <div class="detalhe__info">
                <p class="detalhe__categoria"><c:out value="${produto.categoria.nome}" /></p>
                <h1 class="detalhe__nome"><c:out value="${produto.nome}" /></h1>
                <p class="detalhe__preco"><fmt:formatNumber value="${produto.preco}" type="currency" /></p>
                <p class="detalhe__descricao">
                    <c:choose>
                        <c:when test="${empty produto.descricao}">Sem descrição cadastrada.</c:when>
                        <c:otherwise><c:out value="${produto.descricao}" /></c:otherwise>
                    </c:choose>
                </p>

                <c:choose>
                    <c:when test="${produto.estoque > 0}">
                        <section class="detalhe__compra cartao" aria-labelledby="titulo-compra">
                            <h2 class="placa" id="titulo-compra">Comprar</h2>
                            <div class="detalhe__compra-corpo">
                                <p class="detalhe__estoque"><span class="detalhe__estoque-rotulo">Estoque:</span> ${produto.estoque} unidade(s) disponível(is)</p>
                                <form method="post" action="${pageContext.request.contextPath}/cliente/pedidos/novo" class="detalhe__form">
                                    <input type="hidden" name="idProduto" value="${produto.idProduto}">
                                    <div class="campo">
                                        <label class="campo__rotulo" for="quantidade">Quantidade</label>
                                        <input class="campo__entrada" type="number" id="quantidade" name="quantidade"
                                               value="1" min="1" max="${produto.estoque}" inputmode="numeric" required>
                                    </div>
                                    <button type="submit" class="btn btn--primario">Comprar</button>
                                </form>
                            </div>
                        </section>
                    </c:when>
                    <c:otherwise>
                        <p class="vazio">Produto esgotado</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>

    <%@ include file="/WEB-INF/fragmentos/rodape.jspf" %>
</body>
</html>
