<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>VAGÃO — Página não encontrada</title>
    <style>
        body {
            margin: 0; min-height: 100vh; display: flex; flex-direction: column;
            align-items: center; justify-content: center; background: #111; color: #eee;
            font-family: Arial, Helvetica, sans-serif; text-align: center;
        }
        h1 { color: #e63946; }
        a { color: #ccc; }
    </style>
</head>
<body>
    <h1>404 — Página não encontrada</h1>
    <p>O endereço acessado não existe.</p>
    <p><a href="${pageContext.request.contextPath}/login">Voltar ao login</a></p>
</body>
</html>
