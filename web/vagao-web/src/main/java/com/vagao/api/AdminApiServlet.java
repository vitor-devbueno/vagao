package com.vagao.api;

import com.vagao.dao.PedidoDAO;
import com.vagao.entidade.Pedido;
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
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * API JSON administrativa para o aplicativo Mobile (RF20).
 * Reaproveita PedidoDAO.listarTodos/buscarPorId/contarPorStatus. Protegida por
 * ApiAdminFilter (só administrador autenticado).
 * Rotas: GET /api/admin/resumo, GET /api/admin/pedidos, GET /api/admin/pedidos/detalhe.
 */
@WebServlet("/api/admin/*")
public class AdminApiServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(AdminApiServlet.class.getName());

    private final PedidoDAO pedidoDAO = new PedidoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        try {
            if ("/resumo".equals(pathInfo)) {
                exibirResumo(request, response);
            } else if ("/pedidos".equals(pathInfo)) {
                listarPedidos(request, response);
            } else if ("/pedidos/detalhe".equals(pathInfo)) {
                detalharPedido(request, response);
            } else {
                JsonUtil.erro(response, HttpServletResponse.SC_NOT_FOUND, "Recurso não encontrado.");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Erro ao acessar dados administrativos via API", e);
            JsonUtil.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Erro interno. Tente novamente mais tarde.");
        }
    }

    private void exibirResumo(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        Map<String, Integer> contagemBanco = pedidoDAO.contarPorStatus();

        JSONObject porStatus = new JSONObject();
        int total = 0;
        for (String status : Pedido.STATUS_VALIDOS) {
            int quantidade = contagemBanco.getOrDefault(status, 0);
            porStatus.put(status, quantidade);
            total += quantidade;
        }

        JSONObject resumo = new JSONObject();
        resumo.put("totalPedidos", total);
        resumo.put("porStatus", porStatus);

        JSONObject resposta = new JSONObject();
        resposta.put("resumo", resumo);
        JsonUtil.escrever(response, HttpServletResponse.SC_OK, resposta);
    }

    private void listarPedidos(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        List<Pedido> pedidos = pedidoDAO.listarTodos();

        JSONArray array = new JSONArray();
        for (Pedido pedido : pedidos) {
            array.put(JsonUtil.pedidoComClienteParaJson(pedido));
        }

        JSONObject resposta = new JSONObject();
        resposta.put("pedidos", array);
        JsonUtil.escrever(response, HttpServletResponse.SC_OK, resposta);
    }

    private void detalharPedido(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        Integer id = lerId(request.getParameter("id"));
        if (id == null) {
            JsonUtil.erro(response, HttpServletResponse.SC_NOT_FOUND, "Pedido não encontrado.");
            return;
        }

        Pedido pedido = pedidoDAO.buscarPorId(id);
        if (pedido == null) {
            JsonUtil.erro(response, HttpServletResponse.SC_NOT_FOUND, "Pedido não encontrado.");
            return;
        }

        JSONObject resposta = new JSONObject();
        resposta.put("pedido", JsonUtil.pedidoAdminDetalheParaJson(pedido));
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
