package com.vagao.api;

import com.vagao.dao.ProdutoDAO;
import com.vagao.entidade.Produto;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * API JSON de catálogo para o aplicativo Mobile (RF17/RF25).
 * Reaproveita ProdutoDAO.listarDisponiveis/buscarPorId — os mesmos usados pelo
 * CatalogoServlet da Web. Protegida por ApiAuthFilter (qualquer autenticado).
 * Rotas: GET /api/catalogo, GET /api/catalogo/detalhe.
 */
@WebServlet("/api/catalogo/*")
public class CatalogoApiServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(CatalogoApiServlet.class.getName());

    private final ProdutoDAO produtoDAO = new ProdutoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || "/".equals(pathInfo)) {
                listar(request, response);
            } else if ("/detalhe".equals(pathInfo)) {
                detalhar(request, response);
            } else {
                JsonUtil.erro(response, HttpServletResponse.SC_NOT_FOUND, "Recurso não encontrado.");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Erro ao acessar o catálogo via API", e);
            JsonUtil.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Erro interno. Tente novamente mais tarde.");
        }
    }

    private void listar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        List<Produto> produtos = produtoDAO.listarDisponiveis();

        JSONArray array = new JSONArray();
        for (Produto produto : produtos) {
            array.put(JsonUtil.produtoParaJson(produto));
        }

        JSONObject resposta = new JSONObject();
        resposta.put("produtos", array);
        JsonUtil.escrever(response, HttpServletResponse.SC_OK, resposta);
    }

    private void detalhar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        Integer id = lerId(request.getParameter("id"));
        if (id == null) {
            JsonUtil.erro(response, HttpServletResponse.SC_NOT_FOUND, "Produto não encontrado.");
            return;
        }

        Produto produto = produtoDAO.buscarPorId(id);
        if (produto == null) {
            JsonUtil.erro(response, HttpServletResponse.SC_NOT_FOUND, "Produto não encontrado.");
            return;
        }

        JSONObject resposta = new JSONObject();
        resposta.put("produto", JsonUtil.produtoParaJson(produto));
        JsonUtil.escrever(response, HttpServletResponse.SC_OK, resposta);
    }

    private Integer lerId(String valor) {
        if (valor == null || valor.isEmpty()) {
            return null;
        }
        try {
            return Integer.valueOf(valor);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
