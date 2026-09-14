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
    </style<style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #111;
        color: #f2f2f2;
        font-family: Georgia, 'Times New Roman', serif;
    }
    .card {
        background: #a8192e;
        border: 3px solid #111;
        box-shadow: 8px 8px 0 #111;
        padding: 48px 40px;
        width: 100%;
        max-width: 380px;
    }
    .marca {
        font-family: 'Courier New', monospace;
        font-size: 14px;
        letter-spacing: 6px;
        text-transform: uppercase;
        color: #111;
        margin-bottom: 4px;
    }
    h1 {
        font-size: 34px;
        font-weight: 900;
        text-transform: uppercase;
        line-height: 1.05;
        color: #111;
        margin-bottom: 28px;
    }
    label {
        display: block;
        font-family: 'Courier New', monospace;
        font-size: 11px;
        letter-spacing: 2px;
        text-transform: uppercase;
        color: #111;
        margin-top: 18px;
        margin-bottom: 6px;
    }
    input[type="email"], input[type="password"] {
        width: 100%;
        padding: 12px;
        background: #f2f2f2;
        border: none;
        font-family: 'Courier New', monospace;
        font-size: 14px;
        color: #111;
        margin-bottom: 0;
    }
    button {
        margin-top: 28px;
        width: 100%;
        padding: 14px;
        background: #111;
        color: #f2f2f2;
        border: none;
        font-family: 'Courier New', monospace;
        font-weight: bold;
        text-transform: uppercase;
        letter-spacing: 3px;
        cursor: pointer;
    }
    button:hover { background: #000; }
    .erro {
        background: #111;
        color: #ff6b6b;
        padding: 12px;
        margin-bottom: 16px;
        font-family: 'Courier New', monospace;
        font-size: 12px;
        border-left: 4px solid #ff6b6b;
    }
    .aviso {
        background: #111;
        color: #8fd98f;
        padding: 12px;
        margin-bottom: 16px;
        font-family: 'Courier New', monospace;
        font-size: 12px;
        border-left: 4px solid #8fd98f;
    }
</style>>
</head>
<body>
    <div class="card">
       <p class="marca">V A G Ã O //</p>
	<h1>Vista sua<br>Identidade.</h1>

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

