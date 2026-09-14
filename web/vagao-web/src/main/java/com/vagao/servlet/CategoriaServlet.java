package com.vagao.servlet;

import com.vagao.dao.CategoriaDAO;
import com.vagao.entidade.Categoria;
import com.vagao.util.Flash;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * CRUD administrativo de categorias.
 * Rotas: /admin/categorias, /admin/categorias/novo, /admin/categorias/editar,
 *        /admin/categorias/excluir (GET = confirmar, POST = executar),
 *        /admin/categorias/salvar (POST).
 */
@WebServlet("/admin/categorias/*")
public class CategoriaServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(CategoriaServlet.class.getName());

    private static final String VIEW_LISTA = "/WEB-INF/views/admin/categoria/lista.jsp";
    private static final String VIEW_FORM = "/WEB-INF/views/admin/categoria/form.jsp";
    private static final String VIEW_CONFIRMAR_EXCLUSAO = "/WEB-INF/views/admin/confirmar-exclusao.jsp";

    private final CategoriaDAO categoriaDAO = new CategoriaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Flash.expor(request);
        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                listar(request, response);
            } else if (pathInfo.equals("/novo")) {
                exibirFormularioNovo(request, response);
            } else if (pathInfo.equals("/editar")) {
                exibirFormularioEditar(request, response);
            } else if (pathInfo.equals("/excluir")) {
                exibirConfirmacaoExclusao(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Erro ao acessar categorias", e);
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String pathInfo = request.getPathInfo();

        try {
            if ("/salvar".equals(pathInfo)) {
                salvar(request, response);
            } else if ("/excluir".equals(pathInfo)) {
                excluir(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Erro ao gravar categoria", e);
            throw new ServletException(e);
        }
    }

    private void listar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        request.setAttribute("categorias", categoriaDAO.listarTodas());
        request.getRequestDispatcher(VIEW_LISTA).forward(request, response);
    }

    private void exibirFormularioNovo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("titulo", "Nova categoria");
        request.setAttribute("campos", new LinkedHashMap<String, String>());
        request.getRequestDispatcher(VIEW_FORM).forward(request, response);
    }

    private void exibirFormularioEditar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        Integer id = lerId(request.getParameter("id"));
        if (id == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Categoria categoria = categoriaDAO.buscarPorId(id);
        if (categoria == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Map<String, String> campos = new LinkedHashMap<>();
        campos.put("id", String.valueOf(categoria.getIdCategoria()));
        campos.put("nome", categoria.getNome());

        request.setAttribute("titulo", "Editar categoria");
        request.setAttribute("campos", campos);
        request.getRequestDispatcher(VIEW_FORM).forward(request, response);
    }

    private void exibirConfirmacaoExclusao(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        Integer id = lerId(request.getParameter("id"));
        if (id == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Categoria categoria = categoriaDAO.buscarPorId(id);
        if (categoria == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        request.setAttribute("tipo", "categoria");
        request.setAttribute("nomeItem", categoria.getNome());
        request.setAttribute("id", categoria.getIdCategoria());
        request.setAttribute("acaoUrl", request.getContextPath() + "/admin/categorias/excluir");
        request.setAttribute("voltarUrl", request.getContextPath() + "/admin/categorias");
        request.getRequestDispatcher(VIEW_CONFIRMAR_EXCLUSAO).forward(request, response);
    }

    private void salvar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        String idParam = request.getParameter("id");
        String nome = request.getParameter("nome");

        Map<String, String> campos = new LinkedHashMap<>();
        campos.put("id", idParam == null ? "" : idParam);
        campos.put("nome", nome == null ? "" : nome);

        int idAtual = (idParam == null || idParam.isEmpty()) ? 0 : Integer.parseInt(idParam);

        Map<String, String> erros = validar(nome, idAtual);

        if (!erros.isEmpty()) {
            request.setAttribute("titulo", idAtual == 0 ? "Nova categoria" : "Editar categoria");
            request.setAttribute("campos", campos);
            request.setAttribute("erros", erros);
            request.getRequestDispatcher(VIEW_FORM).forward(request, response);
            return;
        }

        Categoria categoria = new Categoria();
        categoria.setNome(nome.trim());

        if (idAtual == 0) {
            categoriaDAO.inserir(categoria);
            Flash.sucesso(request, "Categoria cadastrada com sucesso.");
        } else {
            categoria.setIdCategoria(idAtual);
            if (!categoriaDAO.atualizar(categoria)) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            Flash.sucesso(request, "Categoria atualizada com sucesso.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/categorias");
    }

    private void excluir(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        Integer id = lerId(request.getParameter("id"));
        if (id == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        int totalProdutos = categoriaDAO.contarProdutos(id);
        if (totalProdutos > 0) {
            Flash.erro(request, "Não é possível excluir: " + totalProdutos
                    + " produto(s) usam esta categoria.");
        } else {
            try {
                if (categoriaDAO.excluir(id)) {
                    Flash.sucesso(request, "Categoria excluída com sucesso.");
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Falha ao excluir categoria " + id, e);
                Flash.erro(request, "Não foi possível excluir esta categoria.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/categorias");
    }

    private Map<String, String> validar(String nome, int idAtual) throws SQLException {
        Map<String, String> erros = new LinkedHashMap<>();

        if (nome == null || nome.trim().isEmpty()) {
            erros.put("nome", "Informe o nome da categoria.");
        } else if (nome.trim().length() > 50) {
            erros.put("nome", "O nome deve ter no máximo 50 caracteres.");
        } else if (categoriaDAO.existeNome(nome.trim(), idAtual)) {
            erros.put("nome", "Já existe uma categoria com este nome.");
        }

        return erros;
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
