package com.vagao.servlet;

import com.vagao.dao.PedidoDAO;
import com.vagao.entidade.Pedido;
import com.vagao.util.Flash;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Consulta de pedidos e atualizacao de status pelo administrador.
 * Rotas: /admin/pedidos, /admin/pedidos/detalhe (GET), /admin/pedidos/status (POST).
 */
@WebServlet("/admin/pedidos/*")
public class PedidoServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(PedidoServlet.class.getName());

    private static final String VIEW_LISTA = "/WEB-INF/views/admin/pedido/lista.jsp";
    private static final String VIEW_DETALHE = "/WEB-INF/views/admin/pedido/detalhe.jsp";

    private final PedidoDAO pedidoDAO = new PedidoDAO();

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
            LOGGER.log(Level.SEVERE, "Erro ao acessar pedidos", e);
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String pathInfo = request.getPathInfo();

        try {
            if ("/status".equals(pathInfo)) {
                atualizarStatus(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Erro ao atualizar status do pedido", e);
            throw new ServletException(e);
        }
    }

    private void listar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        request.setAttribute("pedidos", pedidoDAO.listarTodos());
        request.getRequestDispatcher(VIEW_LISTA).forward(request, response);
    }

    private void exibirDetalhe(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        Integer id = lerId(request.getParameter("id"));
        if (id == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Pedido pedido = pedidoDAO.buscarPorId(id);
        if (pedido == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        request.setAttribute("pedido", pedido);
        request.setAttribute("statusValidos", Pedido.STATUS_VALIDOS);
        request.getRequestDispatcher(VIEW_DETALHE).forward(request, response);
    }

    private void atualizarStatus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        Integer id = lerId(request.getParameter("id"));
        if (id == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Pedido pedido = pedidoDAO.buscarPorId(id);
        if (pedido == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String status = request.getParameter("status");
        if (status == null || !Pedido.STATUS_VALIDOS.contains(status)) {
            Flash.erro(request, "Status inválido.");
        } else {
            pedidoDAO.atualizarStatus(id, status);
            Flash.sucesso(request, "Status do pedido atualizado com sucesso.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/pedidos/detalhe?id=" + id);
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
