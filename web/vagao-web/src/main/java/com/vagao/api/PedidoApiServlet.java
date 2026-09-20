package com.vagao.api;

import com.vagao.dao.EstoqueInsuficienteException;
import com.vagao.dao.PedidoDAO;
import com.vagao.dao.ProdutoDAO;
import com.vagao.entidade.ItemPedido;
import com.vagao.entidade.Pedido;
import com.vagao.entidade.Produto;
import com.vagao.entidade.Usuario;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * API JSON de pedidos do cliente para o aplicativo Mobile (RF18/RF19).
 * Reaproveita PedidoDAO/ProdutoDAO — os mesmos usados pelo MeusPedidosServlet
 * da Web, incluindo a checagem de propriedade de buscarPorIdEUsuario (defesa
 * de IDOR) e a regra de que o preço vem sempre do banco, nunca do request.
 * Protegida por ApiClienteFilter (só cliente autenticado).
 * Rotas: GET /api/pedidos, GET /api/pedidos/detalhe, POST /api/pedidos/novo.
 */
@WebServlet("/api/pedidos/*")
public class PedidoApiServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(PedidoApiServlet.class.getName());
    private static final int MAXIMO_ITENS_POR_PEDIDO = 20;

    private final PedidoDAO pedidoDAO = new PedidoDAO();
    private final ProdutoDAO produtoDAO = new ProdutoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || "/".equals(pathInfo)) {
                listarMeus(request, response);
            } else if ("/detalhe".equals(pathInfo)) {
                detalharMeu(request, response);
            } else {
                JsonUtil.erro(response, HttpServletResponse.SC_NOT_FOUND, "Recurso não encontrado.");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Erro ao acessar pedidos via API", e);
            JsonUtil.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Erro interno. Tente novamente mais tarde.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String pathInfo = request.getPathInfo();

        if (!"/novo".equals(pathInfo)) {
            JsonUtil.erro(response, HttpServletResponse.SC_NOT_FOUND, "Recurso não encontrado.");
            return;
        }

        try {
            comprar(request, response);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Erro ao registrar pedido via API", e);
            JsonUtil.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Erro interno. Tente novamente mais tarde.");
        } catch (EstoqueInsuficienteException e) {
            JSONObject corpo = new JSONObject();
            corpo.put("erro", "Estoque insuficiente para concluir a compra.");
            corpo.put("codigo", "ESTOQUE_INSUFICIENTE");
            JsonUtil.escrever(response, HttpServletResponse.SC_CONFLICT, corpo);
        }
    }

    private void listarMeus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        Usuario cliente = clienteLogado(request);
        List<Pedido> pedidos = pedidoDAO.listarPorUsuario(cliente.getIdUsuario());

        JSONArray array = new JSONArray();
        for (Pedido pedido : pedidos) {
            array.put(JsonUtil.pedidoResumoParaJson(pedido));
        }

        JSONObject resposta = new JSONObject();
        resposta.put("pedidos", array);
        JsonUtil.escrever(response, HttpServletResponse.SC_OK, resposta);
    }

    private void detalharMeu(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        Usuario cliente = clienteLogado(request);

        Integer id = lerId(request.getParameter("id"));
        if (id == null) {
            JsonUtil.erro(response, HttpServletResponse.SC_NOT_FOUND, "Pedido não encontrado.");
            return;
        }

        // buscarPorIdEUsuario filtra o dono no próprio SQL: jamais usar buscarPorId
        // aqui, senão um cliente conseguiria ver o pedido de outro (IDOR).
        Pedido pedido = pedidoDAO.buscarPorIdEUsuario(id, cliente.getIdUsuario());
        if (pedido == null) {
            JsonUtil.erro(response, HttpServletResponse.SC_NOT_FOUND, "Pedido não encontrado.");
            return;
        }

        JSONObject resposta = new JSONObject();
        resposta.put("pedido", JsonUtil.pedidoComItensParaJson(pedido));
        JsonUtil.escrever(response, HttpServletResponse.SC_OK, resposta);
    }

    private void comprar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, EstoqueInsuficienteException, IOException {

        Usuario cliente = clienteLogado(request);

        JSONObject corpo = JsonUtil.lerCorpo(request);
        if (corpo == null) {
            JsonUtil.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Corpo da requisição inválido.");
            return;
        }

        JSONArray itensJson = corpo.optJSONArray("itens");
        if (itensJson == null || itensJson.isEmpty()) {
            JsonUtil.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Informe ao menos um item.");
            return;
        }
        if (itensJson.length() > MAXIMO_ITENS_POR_PEDIDO) {
            JsonUtil.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Pedido com itens demais.");
            return;
        }

        List<ItemPedido> itens = new ArrayList<>();
        Set<Integer> idsVistos = new HashSet<>();

        for (int i = 0; i < itensJson.length(); i++) {
            JSONObject itemJson = itensJson.optJSONObject(i);
            if (itemJson == null) {
                JsonUtil.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Item inválido.");
                return;
            }

            int idProduto = itemJson.optInt("idProduto", -1);
            int quantidade = itemJson.optInt("quantidade", -1);

            if (idProduto <= 0 || quantidade < 1) {
                JsonUtil.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Quantidade inválida.");
                return;
            }
            if (!idsVistos.add(idProduto)) {
                JsonUtil.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Produto repetido no pedido.");
                return;
            }

            Produto produto = produtoDAO.buscarPorId(idProduto);
            if (produto == null) {
                JsonUtil.erro(response, HttpServletResponse.SC_NOT_FOUND, "Produto não encontrado.");
                return;
            }
            if (quantidade > produto.getEstoque()) {
                JSONObject erroCorpo = new JSONObject();
                erroCorpo.put("erro", "Estoque insuficiente para concluir a compra.");
                erroCorpo.put("codigo", "ESTOQUE_INSUFICIENTE");
                JsonUtil.escrever(response, HttpServletResponse.SC_CONFLICT, erroCorpo);
                return;
            }

            ItemPedido item = new ItemPedido();
            item.setProduto(produto);
            item.setQuantidade(quantidade);
            // Preço sempre lido do banco agora, nunca aceito do corpo da requisição.
            item.setPrecoUnitario(produto.getPreco());
            itens.add(item);
        }

        Pedido pedido = new Pedido();
        pedido.setCliente(cliente);
        pedido.setStatus("pendente");
        pedido.setItens(itens);

        int idPedido = pedidoDAO.inserir(pedido);

        JSONObject resposta = new JSONObject();
        resposta.put("idPedido", idPedido);
        resposta.put("mensagem", "Pedido realizado com sucesso.");
        JsonUtil.escrever(response, HttpServletResponse.SC_CREATED, resposta);
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
            return Integer.valueOf(valor);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
