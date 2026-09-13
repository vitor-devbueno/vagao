<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>VAGÃO — Área do Cliente</title>
    <style>
        body { margin: 0; background: #111; color: #eee; font-family: Arial, Helvetica, sans-serif; }
        header {
            display: flex; justify-content: space-between; align-items: center;
            padding: 16px 32px; background: #1c1c1c; border-bottom: 1px solid #333;
        }
        header h1 { font-size: 18px; letter-spacing: 1px; margin: 0; }
        header a { color: #e63946; text-decoration: none; font-size: 13px; }
        main { padding: 32px; max-width: 640px; margin: 0 auto; }
    </style>
</head>
<body>
    <header>
        <h1>VAGÃO</h1>
        <a href="${pageContext.request.contextPath}/logout">Sair</a>
    </header>
    <main>
        <p>Olá, <c:out value="${usuarioLogado.nome}" />. Bem-vindo(a) à sua área.</p>
        <p>Em breve: catálogo de produtos e histórico de pedidos.</p>
    </main>
</body>
</html>
