<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>VAGÃO — Login</title>
    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #111;
            color: #eee;
            font-family: Arial, Helvetica, sans-serif;
        }
        .card {
            background: #1c1c1c;
            border: 1px solid #333;
            border-radius: 8px;
            padding: 32px;
            width: 100%;
            max-width: 360px;
        }
        h1 {
            margin: 0 0 4px;
            font-size: 24px;
            letter-spacing: 2px;
        }
        .subtitulo {
            margin: 0 0 24px;
            color: #999;
            font-size: 13px;
        }
        label {
            display: block;
            margin-bottom: 6px;
            font-size: 13px;
            color: #ccc;
        }
        input[type="email"], input[type="password"] {
            width: 100%;
            padding: 10px 12px;
            margin-bottom: 16px;
            background: #111;
            border: 1px solid #444;
            border-radius: 4px;
            color: #eee;
            font-size: 14px;
        }
        button {
            width: 100%;
            padding: 12px;
            background: #e63946;
            border: none;
            border-radius: 4px;
            color: #fff;
            font-weight: bold;
            letter-spacing: 1px;
            cursor: pointer;
        }
        button:hover { background: #d62839; }
        .erro {
            background: #4a1414;
            border: 1px solid #802020;
            color: #ffb3b3;
            padding: 10px 12px;
            border-radius: 4px;
            font-size: 13px;
            margin-bottom: 16px;
        }
        .aviso {
            background: #1a3a1a;
            border: 1px solid #2f6b2f;
            color: #b8f0b8;
            padding: 10px 12px;
            border-radius: 4px;
            font-size: 13px;
            margin-bottom: 16px;
        }
    </style>
</head>
<body>
    <div class="card">
        <h1>VAGÃO</h1>
        <p class="subtitulo">Streetwear</p>

        <c:if test="${not empty erro}">
            <div class="erro"><c:out value="${erro}" /></div>
        </c:if>
        <c:if test="${empty erro and param.logout == '1'}">
            <div class="aviso">Sessão encerrada com sucesso.</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/login">
            <label for="email">E-mail</label>
            <input type="email" id="email" name="email" value="${fn:escapeXml(email)}" required autofocus>

            <label for="senha">Senha</label>
            <input type="password" id="senha" name="senha" required>

            <button type="submit">Entrar</button>
        </form>
    </div>
</body>
</html>
