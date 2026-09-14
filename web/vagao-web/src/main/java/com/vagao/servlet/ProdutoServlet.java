package com.vagao.servlet;

import com.vagao.dao.CategoriaDAO;
import com.vagao.dao.ProdutoDAO;
import com.vagao.entidade.Categoria;
import com.vagao.entidade.Produto;
import com.vagao.util.Flash;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
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
    private static final String VIEW_FORM = "/WEB-INF/views/admin/produto/form.jsp";

    private final ProdutoDAO produtoDAO = new ProdutoDAO();
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
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Erro ao acessar produtos", e);
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
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Erro ao gravar produto", e);
            throw new ServletException(e);
        }
    }

    private void listar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        request.setAttribute("produtos", produtoDAO.listarTodos());
        request.getRequestDispatcher(VIEW_LISTA).forward(request, response);
    }

    private void exibirFormularioNovo(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        request.setAttribute("titulo", "Novo produto");
        request.setAttribute("campos", new LinkedHashMap<String, String>());
        request.setAttribute("categorias", categoriaDAO.listarTodas());
        request.getRequestDispatcher(VIEW_FORM).forward(request, response);
    }

    private void exibirFormularioEditar(HttpServletRequest request, HttpServletResponse response)
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

        Map<String, String> campos = new LinkedHashMap<>();
        campos.put("id", String.valueOf(produto.getIdProduto()));
        campos.put("nome", produto.getNome());
        campos.put("descricao", produto.getDescricao() == null ? "" : produto.getDescricao());
        campos.put("preco", produto.getPreco().toPlainString());
        campos.put("estoque", String.valueOf(produto.getEstoque()));
        campos.put("idCategoria", String.valueOf(produto.getCategoria().getIdCategoria()));

        request.setAttribute("titulo", "Editar produto");
        request.setAttribute("campos", campos);
        request.setAttribute("categorias", categoriaDAO.listarTodas());
        request.getRequestDispatcher(VIEW_FORM).forward(request, response);
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

    private void salvar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        String idParam = request.getParameter("id");
        String nome = request.getParameter("nome");
        String descricao = request.getParameter("descricao");
        String precoParam = request.getParameter("preco");
        String estoqueParam = request.getParameter("estoque");
        String idCategoriaParam = request.getParameter("idCategoria");

        Map<String, String> campos = new LinkedHashMap<>();
        campos.put("id", idParam == null ? "" : idParam);
        campos.put("nome", nome == null ? "" : nome);
        campos.put("descricao", descricao == null ? "" : descricao);
        campos.put("preco", precoParam == null ? "" : precoParam);
        campos.put("estoque", estoqueParam == null ? "" : estoqueParam);
        campos.put("idCategoria", idCategoriaParam == null ? "" : idCategoriaParam);

        int idAtual = (idParam == null || idParam.isEmpty()) ? 0 : Integer.parseInt(idParam);

        Map<String, String> erros = new LinkedHashMap<>();
        BigDecimal preco = validarNomeDescricaoPreco(nome, descricao, precoParam, erros);
        Integer estoque = validarEstoque(estoqueParam, erros);
        Categoria categoria = validarCategoria(idCategoriaParam, erros);

        if (!erros.isEmpty()) {
            request.setAttribute("titulo", idAtual == 0 ? "Novo produto" : "Editar produto");
            request.setAttribute("campos", campos);
            request.setAttribute("erros", erros);
            request.setAttribute("categorias", categoriaDAO.listarTodas());
            request.getRequestDispatcher(VIEW_FORM).forward(request, response);
            return;
        }

        Produto produto = new Produto();
        produto.setNome(nome.trim());
        produto.setDescricao(descricao == null ? null : descricao.trim());
        produto.setPreco(preco);
        produto.setEstoque(estoque);
        produto.setCategoria(categoria);

        if (idAtual == 0) {
            produtoDAO.inserir(produto);
            Flash.sucesso(request, "Produto cadastrado com sucesso.");
        } else {
            produto.setIdProduto(idAtual);
            if (!produtoDAO.atualizar(produto)) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            Flash.sucesso(request, "Produto atualizado com sucesso.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/produtos");
    }

    private BigDecimal validarNomeDescricaoPreco(String nome, String descricao, String precoParam,
                                                  Map<String, String> erros) {
        if (nome == null || nome.trim().isEmpty()) {
            erros.put("nome", "Informe o nome do produto.");
        } else if (nome.trim().length() > 100) {
            erros.put("nome", "O nome deve ter no máximo 100 caracteres.");
        }

        if (descricao != null && descricao.length() > 255) {
            erros.put("descricao", "A descrição deve ter no máximo 255 caracteres.");
        }

        BigDecimal preco = null;
        if (precoParam == null || precoParam.trim().isEmpty()) {
            erros.put("preco", "Informe o preço.");
        } else {
            try {
                BigDecimal valorDigitado = new BigDecimal(precoParam.trim().replace(",", "."));
                if (valorDigitado.scale() > 2) {
                    erros.put("preco", "O preço deve ter no máximo 2 casas decimais.");
                } else {
                    preco = valorDigitado.setScale(2, RoundingMode.HALF_UP);
                    if (preco.compareTo(BigDecimal.ZERO) <= 0) {
                        erros.put("preco", "O preço deve ser maior que zero.");
                        preco = null;
                    } else if (preco.compareTo(new BigDecimal("100000000")) >= 0) {
                        erros.put("preco", "O preço informado é grande demais.");
                        preco = null;
                    }
                }
            } catch (NumberFormatException e) {
                erros.put("preco", "Preço inválido.");
            }
        }
        return preco;
    }

    private Integer validarEstoque(String estoqueParam, Map<String, String> erros) {
        if (estoqueParam == null || estoqueParam.trim().isEmpty()) {
            erros.put("estoque", "Informe o estoque.");
            return null;
        }
        try {
            int estoque = Integer.parseInt(estoqueParam.trim());
            if (estoque < 0) {
                erros.put("estoque", "O estoque não pode ser negativo.");
                return null;
            }
            return estoque;
        } catch (NumberFormatException e) {
            erros.put("estoque", "Estoque inválido.");
            return null;
        }
    }

    private Categoria validarCategoria(String idCategoriaParam, Map<String, String> erros) throws SQLException {
        if (idCategoriaParam == null || idCategoriaParam.trim().isEmpty()) {
            erros.put("idCategoria", "Selecione uma categoria válida.");
            return null;
        }
        try {
            int idCategoria = Integer.parseInt(idCategoriaParam.trim());
            Categoria categoria = categoriaDAO.buscarPorId(idCategoria);
            if (categoria == null) {
                erros.put("idCategoria", "Selecione uma categoria válida.");
            }
            return categoria;
        } catch (NumberFormatException e) {
            erros.put("idCategoria", "Selecione uma categoria válida.");
            return null;
        }
    }
}
