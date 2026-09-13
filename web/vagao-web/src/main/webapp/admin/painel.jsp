<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>VAGÃO — Área Administrativa</title>
    <style>
        body { margin: 0; background: #111; color: #eee; font-family: Arial, Helvetica, sans-serif; }
        header {
            display: flex; justify-content: space-between; align-items: center;
            padding: 16px 32px; background: #1c1c1c; border-bottom: 1px solid #333;
        }
        header h1 { font-size: 18px; letter-spacing: 1px; margin: 0; }
        header a { color: #e63946; text-decoration: none; font-size: 13px; }
        main { padding: 32px; max-width: 640px; margin: 0 auto; }
        ul { list-style: none; padding: 0; }
        li { margin-bottom: 12px; }
        li a {
            display: block; padding: 14px 16px; background: #1c1c1c; border: 1px solid #333;
            border-radius: 6px; color: #ccc; text-decoration: none;
        }
        li a:hover { border-color: #e63946; }
    </style>
</head>
<body>
    <header>
        <h1>VAGÃO — Administração</h1>
        <a href="${pageContext.request.contextPath}/logout">Sair</a>
    </header>
    <main>
        <p>Olá, <c:out value="${usuarioLogado.nome}" />. Bem-vindo(a) à área administrativa.</p>
        <ul>
            <li><a href="#">Produtos (em breve)</a></li>
            <li><a href="#">Categorias (em breve)</a></li>
            <li><a href="#">Pedidos (em breve)</a></li>
        </ul>
    </main>
</body>
</html>
