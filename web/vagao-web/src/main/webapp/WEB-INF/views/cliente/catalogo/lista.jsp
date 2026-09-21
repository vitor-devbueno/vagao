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
    <title>VAGÃO — Catálogo</title>
    <link rel="preload" href="${pageContext.request.contextPath}/fonts/big-shoulders-display-variable.woff2" as="font" type="font/woff2" crossorigin>
    <link rel="preload" href="${pageContext.request.contextPath}/fonts/libre-caslon-text-400.woff2" as="font" type="font/woff2" crossorigin>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/vagao.css">
</head>
<body class="pagina-cliente">
    <c:set var="paginaAtiva" value="catalogo" scope="request" />
    <%@ include file="/WEB-INF/fragmentos/cliente-topo.jspf" %>

    <main class="catalogo">
        <header class="catalogo__cabecalho">
            <h1 class="catalogo__titulo">Catálogo</h1>
            <c:if test="${not empty produtos}">
                <p class="catalogo__contagem">
                    <c:out value="${fn:length(produtos)}" /> <c:choose><c:when test="${fn:length(produtos) == 1}">peça</c:when><c:otherwise>peças</c:otherwise></c:choose>
                </p>
            </c:if>
        </header>

        <c:if test="${not empty flashMsg}">
            <div class="alerta alerta--${flashTipo}" role="${flashTipo == 'erro' ? 'alert' : 'status'}">
                <strong class="alerta__prefixo">${flashTipo == 'erro' ? 'Erro:' : 'OK:'}</strong> <c:out value="${flashMsg}" />
            </div>
        </c:if>

        <c:choose>
            <c:when test="${empty produtos}">
                <p class="vazio">Nenhum produto disponível no momento.</p>
            </c:when>
            <c:otherwise>
                <ul class="catalogo__grade">
                    <c:forEach var="p" items="${produtos}">
                        <li class="catalogo__item">
                            <a class="produto" href="${pageContext.request.contextPath}/cliente/catalogo/detalhe?id=${p.idProduto}">
                                <div class="produto__midia">
                                    <%-- Placeholder sempre presente atrás da foto: aparece se não houver foto, se ela falhar ou enquanto carrega --%>
                                    <span class="produto__inicial" aria-hidden="true"><c:out value="${fn:substring(p.nome, 0, 1)}" /></span>
                                    <c:if test="${p.temImagem}">
                                        <img class="produto__foto"
                                             src="${pageContext.request.contextPath}/imagens/produtos/${p.idProduto}?v=${p.imagemVersao}"
                                             alt="<c:out value='${p.nome}' />"
                                             loading="lazy" decoding="async"
                                             onerror="this.remove()">
                                    </c:if>
                                </div>
                                <div class="produto__corpo">
                                    <div class="produto__categoria"><c:out value="${p.categoria.nome}" /></div>
                                    <h2 class="produto__nome"><c:out value="${p.nome}" /></h2>
                                    <div class="produto__preco"><fmt:formatNumber value="${p.preco}" type="currency" /></div>
                                </div>
                                <span class="produto__acao">Ver detalhes</span>
                            </a>
                        </li>
                    </c:forEach>
                </ul>
            </c:otherwise>
        </c:choose>
    </main>

    <%@ include file="/WEB-INF/fragmentos/rodape.jspf" %>
</body>
</html>
