package com.vagao.api;

import com.vagao.dao.UsuarioDAO;
import com.vagao.entidade.Usuario;
import org.json.JSONObject;

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

/**
 * API JSON de autenticação para o aplicativo Mobile.
 * Reaproveita UsuarioDAO.autenticar (bcrypt) e a mesma HttpSession/atributo
 * "usuarioLogado" usados pela Web — nenhuma infraestrutura nova de sessão.
 * Rotas: POST /api/auth/login, POST /api/auth/logout, GET /api/auth/sessao.
 */
@WebServlet("/api/auth/*")
public class AutenticacaoApiServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(AutenticacaoApiServlet.class.getName());
    private static final int TIMEOUT_SESSAO_SEGUNDOS = 30 * 60;

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        if ("/sessao".equals(pathInfo)) {
            exibirSessao(request, response);
        } else {
            JsonUtil.erro(response, HttpServletResponse.SC_NOT_FOUND, "Recurso não encontrado.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String pathInfo = request.getPathInfo();

        if ("/login".equals(pathInfo)) {
            login(request, response);
        } else if ("/logout".equals(pathInfo)) {
            logout(request, response);
        } else {
            JsonUtil.erro(response, HttpServletResponse.SC_NOT_FOUND, "Recurso não encontrado.");
        }
    }

    private void login(HttpServletRequest request, HttpServletResponse response) throws IOException {
        JSONObject corpo = JsonUtil.lerCorpo(request);
        if (corpo == null) {
            JsonUtil.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Corpo da requisição inválido.");
            return;
        }

        String email = corpo.optString("email", "").trim();
        String senha = corpo.optString("senha", "");

        if (email.isEmpty() || senha.isEmpty()) {
            JsonUtil.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Informe e-mail e senha.");
            return;
        }

        try {
            Usuario usuario = usuarioDAO.autenticar(email, senha);

            if (usuario == null) {
                JsonUtil.erro(response, HttpServletResponse.SC_UNAUTHORIZED, "E-mail ou senha inválidos.");
                return;
            }

            // Invalida qualquer sessão anterior e cria uma nova para evitar session fixation
            // (mesmo mecanismo do LoginServlet).
            HttpSession sessaoAntiga = request.getSession(false);
            if (sessaoAntiga != null) {
                sessaoAntiga.invalidate();
            }
            HttpSession sessao = request.getSession(true);
            sessao.setAttribute("usuarioLogado", usuario);
            sessao.setMaxInactiveInterval(TIMEOUT_SESSAO_SEGUNDOS);

            JSONObject resposta = new JSONObject();
            resposta.put("usuario", JsonUtil.usuarioParaJson(usuario));
            JsonUtil.escrever(response, HttpServletResponse.SC_OK, resposta);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Erro ao autenticar via API", e);
            JsonUtil.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Erro interno. Tente novamente mais tarde.");
        }
    }

    private void logout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession sessao = request.getSession(false);
        if (sessao != null) {
            sessao.invalidate();
        }

        JSONObject resposta = new JSONObject();
        resposta.put("mensagem", "Sessão encerrada.");
        JsonUtil.escrever(response, HttpServletResponse.SC_OK, resposta);
    }

    private void exibirSessao(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // ApiAuthFilter já garantiu que há sessão com usuarioLogado antes de chegar aqui.
        HttpSession sessao = request.getSession(false);
        Usuario usuario = (Usuario) sessao.getAttribute("usuarioLogado");

        JSONObject resposta = new JSONObject();
        resposta.put("usuario", JsonUtil.usuarioParaJson(usuario));
        JsonUtil.escrever(response, HttpServletResponse.SC_OK, resposta);
    }
}
