package com.vagao.filtro;

import com.vagao.api.JsonUtil;
import com.vagao.entidade.Usuario;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Protege tudo em /api/*: exige usuário autenticado, exceto a rota pública de login.
 * Diferente de AdminFilter/ClienteFilter, nunca redireciona — sempre responde JSON,
 * pois o consumidor é o aplicativo Mobile, não um navegador.
 */
@WebFilter("/api/*")
public class ApiAuthFilter implements Filter {

    private static final String ROTA_LOGIN_PUBLICA = "/api/auth/login";

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

        String caminho = request.getRequestURI().substring(request.getContextPath().length());

        if (ROTA_LOGIN_PUBLICA.equals(caminho)) {
            chain.doFilter(req, res);
            return;
        }

        HttpSession sessao = request.getSession(false);
        Usuario usuarioLogado = sessao != null ? (Usuario) sessao.getAttribute("usuarioLogado") : null;

        if (usuarioLogado == null) {
            JsonUtil.erro(response, HttpServletResponse.SC_UNAUTHORIZED, "Não autenticado.");
            return;
        }

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
    }
}
