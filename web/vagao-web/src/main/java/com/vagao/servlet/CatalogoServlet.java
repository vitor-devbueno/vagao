package com.vagao.servlet;

import com.vagao.dao.ProdutoDAO;
import com.vagao.entidade.Produto;
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
 * Catálogo de produtos disponíveis para o cliente.
 * Rotas: /cliente/catalogo (GET).
 */
@WebServlet("/cliente/catalogo/*")
public class CatalogoServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(CatalogoServlet.class.getName());

    private static final String VIEW_LISTA = "/WEB-INF/views/cliente/catalogo/lista.jsp";
    private static final String VIEW_DETALHE = "/WEB-INF/views/cliente/catalogo/detalhe.jsp";

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
            LOGGER.log(Level.SEVERE, "Erro ao acessar o catálogo", e);
            throw new ServletException(e);
        }
    }

    private void listar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        request.setAttribute("produtos", produtoDAO.listarDisponiveis());
        request.getRequestDispatcher(VIEW_LISTA).forward(request, response);
    }

    private void exibirDetalhe(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        Integer id = lerId(request.getParameter("id"));
        if (id == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Produto produto = produtoDAO.buscarPorId(id);
        if (produto == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        request.setAttribute("produto", produto);
        request.getRequestDispatcher(VIEW_DETALHE).forward(request, response);
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
