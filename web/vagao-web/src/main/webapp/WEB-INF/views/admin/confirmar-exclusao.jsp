<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>VAGÃO — Confirmar exclusão</title>
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
    h1 { font-size: 32px; font-weight: 900; text-transform: uppercase; margin-bottom: 24px; }
    .painel { background: #1a1a1a; border: 3px solid #a8192e; box-shadow: 8px 8px 0 #a8192e; padding: 24px; max-width: 480px; }
    .nome-item { font-size: 20px; font-weight: bold; margin: 12px 0; }
    .aviso { font-family: 'Courier New', monospace; font-size: 12px; color: #ff6b6b; margin-bottom: 20px; }
    .btn { display: inline-block; font-family: 'Courier New', monospace; font-size: 12px; font-weight: bold; letter-spacing: 2px;
           text-transform: uppercase; text-decoration: none; border: none; cursor: pointer; padding: 10px 16px;
           background: #a8192e; color: #f2f2f2; box-shadow: 4px 4px 0 #f2f2f2; }
    .btn-sec { background: #f2f2f2; color: #111; box-shadow: 4px 4px 0 #a8192e; }
    .btn-perigo { background: #111; color: #ff6b6b; border: 2px solid #ff6b6b; box-shadow: none; }
    .acoes { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 24px; }
    </style>
</head>
<body>
    <header class="topo">
      <span class="marca">V A G Ã O // admin</span>
      <nav>
        <a href="${pageContext.request.contextPath}/admin/painel.jsp">Painel</a>
        <a href="${pageContext.request.contextPath}/admin/produtos">Produtos</a>
        <a href="${pageContext.request.contextPath}/admin/categorias">Categorias</a>
        <a href="${pageContext.request.contextPath}/admin/pedidos">Pedidos</a>
        <a href="${pageContext.request.contextPath}/logout">Sair</a>
      </nav>
    </header>
    <main>
        <h1>Excluir <c:out value="${tipo}" />?</h1>

        <div class="painel">
            <p>Você está prestes a excluir:</p>
            <p class="nome-item"><c:out value="${nomeItem}" /></p>
            <p class="aviso">Esta ação não pode ser desfeita.</p>

            <form method="post" action="${acaoUrl}">
                <input type="hidden" name="id" value="${id}">
                <div class="acoes">
                    <button type="submit" class="btn btn-perigo">Confirmar exclusão</button>
                    <a class="btn btn-sec" href="${voltarUrl}">Cancelar</a>
                </div>
            </form>
        </div>
    </main>
</body>
</html>
