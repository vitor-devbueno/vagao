<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>VAGÃO — Área do Cliente</title>
    <link rel="preload" href="${pageContext.request.contextPath}/fonts/big-shoulders-display-variable.woff2" as="font" type="font/woff2" crossorigin>
    <link rel="preload" href="${pageContext.request.contextPath}/fonts/libre-caslon-text-400.woff2" as="font" type="font/woff2" crossorigin>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/vagao.css">
</head>
<body class="pagina-cliente">
    <c:set var="paginaAtiva" value="area" scope="request" />
    <%@ include file="/WEB-INF/fragmentos/cliente-topo.jspf" %>

    <main>
        <section class="area__hero fundo-escuro">
            <div class="area__interno">
                <h1 class="impacto">Área do cliente</h1>
                <p class="area__saudacao">Olá, <c:out value="${usuarioLogado.nome}" />. Bem-vindo(a) à sua área.</p>
            </div>
        </section>

        <section class="area__atalhos">
            <div class="area__interno area__grade">
                <article class="cartao area__cartao">
                    <h2 class="placa">Catálogo</h2>
                    <div class="area__cartao-corpo">
                        <p>Roupas e acessórios do drop.</p>
                        <a class="btn btn--primario" href="${pageContext.request.contextPath}/cliente/catalogo">Ver catálogo</a>
                    </div>
                </article>

                <article class="cartao area__cartao">
                    <h2 class="placa">Meus pedidos</h2>
                    <div class="area__cartao-corpo">
                        <p>Acompanhe cada pedido, do preparo à entrega.</p>
                        <a class="btn btn--primario" href="${pageContext.request.contextPath}/cliente/pedidos">Meus pedidos</a>
                    </div>
                </article>
            </div>
        </section>
    </main>

    <%@ include file="/WEB-INF/fragmentos/rodape.jspf" %>
</body>
</html>
