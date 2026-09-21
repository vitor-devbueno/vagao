<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>VAGÃO — Login</title>

    <%-- Fontes usadas acima da dobra: pré-carrega para evitar o "pulo" de troca de fonte --%>
    <link rel="preload" href="${pageContext.request.contextPath}/fonts/big-shoulders-display-variable.woff2" as="font" type="font/woff2" crossorigin>
    <link rel="preload" href="${pageContext.request.contextPath}/fonts/libre-caslon-text-400.woff2" as="font" type="font/woff2" crossorigin>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/vagao.css">
</head>
<body class="pagina-login fundo-escuro">
    <%@ include file="/WEB-INF/fragmentos/faixa.jspf" %>

    <main class="login">
        <header class="login__marca">
            <p class="wordmark">VAGÃO //</p>
            <h1 class="impacto">Vista sua<br>identidade.</h1>
        </header>

        <section class="login__cartao cartao fundo-claro" aria-labelledby="titulo-login">
            <h2 class="placa" id="titulo-login">Acesso</h2>

            <c:if test="${not empty erro}">
                <div class="alerta alerta--erro" role="alert">
                    <strong class="alerta__prefixo">Erro:</strong> <c:out value="${erro}" />
                </div>
            </c:if>
            <c:if test="${empty erro and param.logout == '1'}">
                <div class="alerta alerta--sucesso" role="status">
                    <strong class="alerta__prefixo">OK:</strong> Sessão encerrada com sucesso.
                </div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/login">
                <div class="campo">
                    <label class="campo__rotulo" for="email">E-mail</label>
                    <input class="campo__entrada" type="email" id="email" name="email"
                           value="${fn:escapeXml(email)}" autocomplete="username" required autofocus>
                </div>

                <div class="campo">
                    <label class="campo__rotulo" for="senha">Senha</label>
                    <input class="campo__entrada" type="password" id="senha" name="senha"
                           autocomplete="current-password" required>
                </div>

                <button class="btn btn--primario btn--bloco" type="submit">Entrar</button>
            </form>
        </section>
    </main>

    <div class="trilho" aria-hidden="true"></div>
</body>
</html>
