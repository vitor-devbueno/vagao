package com.vagao.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * Mensagens "flash": sobrevivem a um redirect (padrão Post-Redirect-Get)
 * guardando-se por uma requisição na sessão, e são expostas como atributos
 * de request para as JSPs de listagem.
 */
public class Flash {

    private static final String ATTR_TIPO = "flashTipo";
    private static final String ATTR_MSG = "flashMsg";

    private Flash() {
    }

    public static void sucesso(HttpServletRequest request, String mensagem) {
        guardar(request, "sucesso", mensagem);
    }

    public static void erro(HttpServletRequest request, String mensagem) {
        guardar(request, "erro", mensagem);
    }

    private static void guardar(HttpServletRequest request, String tipo, String mensagem) {
        HttpSession sessao = request.getSession();
        sessao.setAttribute(ATTR_TIPO, tipo);
        sessao.setAttribute(ATTR_MSG, mensagem);
    }

    /**
     * Move a mensagem flash (se houver) da sessão para atributos de request,
     * removendo-a da sessão em seguida. Deve ser chamado no início de todo
     * doGet que renderiza uma página que pode exibir flash.
     */
    public static void expor(HttpServletRequest request) {
        HttpSession sessao = request.getSession(false);
        if (sessao == null) {
            return;
        }
        Object tipo = sessao.getAttribute(ATTR_TIPO);
        Object msg = sessao.getAttribute(ATTR_MSG);
        if (msg != null) {
            request.setAttribute(ATTR_TIPO, tipo);
            request.setAttribute(ATTR_MSG, msg);
            sessao.removeAttribute(ATTR_TIPO);
            sessao.removeAttribute(ATTR_MSG);
        }
    }
}
