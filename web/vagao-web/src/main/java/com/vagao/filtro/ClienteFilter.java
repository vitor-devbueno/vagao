package com.vagao.filtro;

import com.vagao.entidade.Usuario;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Protege tudo em /cliente/*: exige usuário logado com perfil "cliente".
 * Um administrador logado recebe 403 ao tentar acessar a área do cliente.
 */
@WebFilter("/cliente/*")
public class ClienteFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");

        HttpSession sessao = request.getSession(false);
        Usuario usuarioLogado = sessao != null ? (Usuario) sessao.getAttribute("usuarioLogado") : null;

        if (usuarioLogado == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!usuarioLogado.isCliente()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Acesso restrito a clientes.");
            return;
        }

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
    }
}
