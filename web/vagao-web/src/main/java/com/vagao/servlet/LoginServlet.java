package com.vagao.servlet;

import com.vagao.dao.UsuarioDAO;
import com.vagao.entidade.Usuario;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(LoginServlet.class.getName());
    private static final int TIMEOUT_SESSAO_SEGUNDOS = 30 * 60;

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sessao = request.getSession(false);
        Usuario usuarioLogado = sessao != null ? (Usuario) sessao.getAttribute("usuarioLogado") : null;

        if (usuarioLogado != null) {
            redirecionarPorPerfil(usuarioLogado, request, response);
            return;
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("/login.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String senha = request.getParameter("senha");

        if (email == null || email.trim().isEmpty() || senha == null || senha.isEmpty()) {
            request.setAttribute("erro", "Informe e-mail e senha.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        try {
            Usuario usuario = usuarioDAO.autenticar(email.trim(), senha);

            if (usuario == null) {
                request.setAttribute("erro", "E-mail ou senha inválidos.");
                request.setAttribute("email", email);
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            // Invalida qualquer sessão anterior e cria uma nova para evitar session fixation.
            HttpSession sessaoAntiga = request.getSession(false);
            if (sessaoAntiga != null) {
                sessaoAntiga.invalidate();
            }
            HttpSession sessao = request.getSession(true);
            sessao.setAttribute("usuarioLogado", usuario);
            sessao.setMaxInactiveInterval(TIMEOUT_SESSAO_SEGUNDOS);

            redirecionarPorPerfil(usuario, request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Erro ao autenticar usuário", e);
            request.setAttribute("erro", "Não foi possível autenticar agora. Tente novamente mais tarde.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }

    private void redirecionarPorPerfil(Usuario usuario, HttpServletRequest request,
                                        HttpServletResponse response) throws IOException {
        String contexto = request.getContextPath();
        if (usuario.isAdmin()) {
            response.sendRedirect(contexto + "/admin/painel.jsp");
        } else {
            response.sendRedirect(contexto + "/cliente/area.jsp");
        }
    }
}
