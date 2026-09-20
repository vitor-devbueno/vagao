package com.vagao.servlet;

import com.vagao.dao.PedidoDAO;
import com.vagao.dao.ProdutoDAO;
import com.vagao.entidade.Pedido;
import com.vagao.entidade.Usuario;
import com.vagao.util.Flash;

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
 * Consulta dos pedidos do próprio cliente logado.
 * Rotas: /cliente/pedidos (GET), /cliente/pedidos/detalhe (GET).
 */
@WebServlet("/cliente/pedidos/*")
public class MeusPedidosServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(MeusPedidosServlet.class.getName());

    private static final String VIEW_LISTA = "/WEB-INF/views/cliente/pedido/lista.jsp";
    private static final String VIEW_DETALHE = "/WEB-INF/views/cliente/pedido/detalhe.jsp";

    private final PedidoDAO pedidoDAO = new PedidoDAO();
    private final ProdutoDAO produtoDAO = new ProdutoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Flash.expor(request);
        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                listar(request, response);
            } else if (pathInfo.equals("/detalhe")) {
                exibirDetalhe(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Erro ao acessar os pedidos do cliente", e);
            throw new ServletException(e);
        }
    }

    private void listar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        Usuario cliente = clienteLogado(request);
        if (cliente == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        request.setAttribute("pedidos", pedidoDAO.listarPorUsuario(cliente.getIdUsuario()));
        request.getRequestDispatcher(VIEW_LISTA).forward(request, response);
    }

    private void exibirDetalhe(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        Usuario cliente = clienteLogado(request);
        if (cliente == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        Integer id = lerId(request.getParameter("id"));
        if (id == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Pedido pedido = pedidoDAO.buscarPorIdEUsuario(id, cliente.getIdUsuario());
        if (pedido == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Defesa em profundidade: o SQL já filtrou por dono.
        if (pedido.getCliente().getIdUsuario() != cliente.getIdUsuario()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        request.setAttribute("pedido", pedido);
        request.getRequestDispatcher(VIEW_DETALHE).forward(request, response);
    }

    private Usuario clienteLogado(HttpServletRequest request) {
        HttpSession sessao = request.getSession(false);
        return sessao != null ? (Usuario) sessao.getAttribute("usuarioLogado") : null;
    }

    private Integer lerId(String valor) {
        if (valor == null || valor.isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(valor);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
