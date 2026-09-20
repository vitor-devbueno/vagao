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
 * Protege /api/admin/*: exige sessão com perfil admin. Responde sempre em
 * JSON, nunca redireciona (o consumidor é o aplicativo Mobile).
 *
 * Repete a checagem de autenticação que o ApiAuthFilter também faz de propósito:
 * filtros anotados com @WebFilter não têm ordem de execução garantida quando
 * casam a mesma URL, então este filtro precisa ser auto-suficiente e não pode
 * assumir que o ApiAuthFilter já rodou antes.
 */
@WebFilter("/api/admin/*")
public class ApiAdminFilter implements Filter {

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
            JsonUtil.erro(response, HttpServletResponse.SC_UNAUTHORIZED, "Não autenticado.");
            return;
        }

        if (!usuarioLogado.isAdmin()) {
            JsonUtil.erro(response, HttpServletResponse.SC_FORBIDDEN, "Acesso restrito a administradores.");
            return;
        }

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
    }
}
