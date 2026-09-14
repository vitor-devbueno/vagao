package com.vagao.servlet;

import com.vagao.dao.ProdutoDAO;
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
 * CRUD administrativo de produtos.
 * Rotas: /admin/produtos, /admin/produtos/novo, /admin/produtos/editar,
 *        /admin/produtos/excluir (GET = confirmar, POST = executar),
 *        /admin/produtos/salvar (POST).
 */
@WebServlet("/admin/produtos/*")
public class ProdutoServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(ProdutoServlet.class.getName());

    private static final String VIEW_LISTA = "/WEB-INF/views/admin/produto/lista.jsp";

    private final ProdutoDAO produtoDAO = new ProdutoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Flash.expor(request);
        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                listar(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Erro ao acessar produtos", e);
            throw new ServletException(e);
        }
    }

    private void listar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        request.setAttribute("produtos", produtoDAO.listarTodos());
        request.getRequestDispatcher(VIEW_LISTA).forward(request, response);
    }
}
