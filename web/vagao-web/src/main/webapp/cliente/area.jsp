<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>VAGÃO — Área do Cliente</title>
    <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { background: #111; color: #f2f2f2; font-family: Georgia, 'Times New Roman', serif; min-height: 100vh; }
    .topo { display: flex; flex-wrap: wrap; gap: 16px; justify-content: space-between; align-items: center;
            background: #a8192e; border-bottom: 3px solid #111; padding: 16px 32px; }
    .topo .marca { font-family: 'Courier New', monospace; letter-spacing: 6px; text-transform: uppercase; color: #111; font-weight: bold; }
    .topo nav a { font-family: 'Courier New', monospace; font-size: 12px; letter-spacing: 2px; text-transform: uppercase;
                  color: #111; text-decoration: none; margin-left: 18px; }
    .topo nav a:hover, .topo nav a.ativo { text-decoration: underline; }
    main { max-width: 1000px; margin: 0 auto; padding: 40px 16px; }
    h1 { font-size: 32px; font-weight: 900; text-transform: uppercase; margin-bottom: 8px; }
    .saudacao { font-family: 'Courier New', monospace; font-size: 13px; color: #ccc; margin-bottom: 32px; }
    ul { list-style: none; }
    li { margin-bottom: 12px; }
    li a {
        display: block; padding: 18px 20px; background: #1a1a1a; border: 3px solid #a8192e;
        box-shadow: 8px 8px 0 #a8192e; color: #f2f2f2; text-decoration: none;
        font-family: 'Courier New', monospace; letter-spacing: 2px; text-transform: uppercase; font-size: 13px;
    }
    li a:hover { background: #222; }
    </style>
</head>
<body>
    <header class="topo">
      <span class="marca">V A G Ã O // cliente</span>
      <nav>
        <a href="${pageContext.request.contextPath}/cliente/area.jsp" class="ativo">Início</a>
        <a href="${pageContext.request.contextPath}/cliente/catalogo">Catálogo</a>
        <a href="${pageContext.request.contextPath}/cliente/pedidos">Meus pedidos</a>
        <a href="${pageContext.request.contextPath}/logout">Sair</a>
      </nav>
    </header>
    <main>
        <h1>Área do cliente</h1>
        <p class="saudacao">Olá, <c:out value="${usuarioLogado.nome}" />. Bem-vindo(a) à sua área.</p>
        <ul>
            <li><a href="${pageContext.request.contextPath}/cliente/catalogo">Ver catálogo</a></li>
            <li><a href="${pageContext.request.contextPath}/cliente/pedidos">Meus pedidos</a></li>
        </ul>
    </main>
</body>
</html>
