package com.vagao.api;

import com.vagao.entidade.Categoria;
import com.vagao.entidade.ItemPedido;
import com.vagao.entidade.Pedido;
import com.vagao.entidade.Produto;
import com.vagao.entidade.Usuario;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Date;

/**
 * Utilitários de serialização JSON para a API do aplicativo Mobile (com.vagao.api).
 * Nunca monta JSON por concatenação de String.
 */
public final class JsonUtil {

    private JsonUtil() {
    }

    /**
     * Escreve o corpo JSON com o status informado. Sempre UTF-8.
     */
    public static void escrever(HttpServletResponse response, int status, JSONObject corpo) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(corpo.toString());
    }

    /**
     * Atalho para {"erro": "..."} com o status informado.
     */
    public static void erro(HttpServletResponse response, int status, String mensagem) throws IOException {
        JSONObject corpo = new JSONObject();
        corpo.put("erro", mensagem);
        escrever(response, status, corpo);
    }

    /**
     * Serializa o usuário SEM a senha. Campos: idUsuario, nome, email, perfil, telefone.
     */
    public static JSONObject usuarioParaJson(Usuario usuario) {
        JSONObject json = new JSONObject();
        json.put("idUsuario", usuario.getIdUsuario());
        json.put("nome", usuario.getNome());
        json.put("email", usuario.getEmail());
        json.put("perfil", usuario.getPerfil());
        json.put("telefone", usuario.getTelefone());
        return json;
    }

    /**
     * Lê e parseia o corpo JSON da requisição. Devolve null se ausente ou malformado.
     */
    public static JSONObject lerCorpo(HttpServletRequest request) {
        try {
            return new JSONObject(new JSONTokener(request.getReader()));
        } catch (JSONException | IOException e) {
            return null;
        }
    }

    /**
     * Formata valor monetário sempre com 2 casas decimais, como String.
     * O org.json remove zeros à direita de números (90.00 viraria 90 no JSON),
     * o que quebra o parse no app (Dart não sabe se espera int ou double). Emitir
     * como String elimina essa ambiguidade.
     */
    public static String dinheiro(BigDecimal valor) {
        BigDecimal v = (valor != null) ? valor : BigDecimal.ZERO;
        return v.setScale(2, RoundingMode.HALF_UP).toPlainString();
    }

    /**
     * Formata data/hora em ISO-8601 (hora local do servidor), consumível por
     * DateTime.parse no Dart. Não usa SimpleDateFormat (não é thread-safe).
     */
    public static String dataIso(Date data) {
        if (data == null) {
            return null;
        }
        return data.toInstant()
                .atZone(ZoneId.systemDefault())
                .toLocalDateTime()
                .format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
    }

    /**
     * Serializa a categoria. Campos: idCategoria, nome.
     */
    public static JSONObject categoriaParaJson(Categoria categoria) {
        JSONObject json = new JSONObject();
        json.put("idCategoria", categoria.getIdCategoria());
        json.put("nome", categoria.getNome());
        return json;
    }

    /**
     * Serializa o produto completo. Campos: idProduto, nome, descricao (ou null),
     * preco (String, 2 casas), estoque, categoria (aninhada ou null), imagemUrl
     * (caminho relativo já versionado com ?v=, ou null quando não há foto).
     */
    public static JSONObject produtoParaJson(Produto produto) {
        JSONObject json = new JSONObject();
        json.put("idProduto", produto.getIdProduto());
        json.put("nome", produto.getNome());
        json.put("descricao", produto.getDescricao() != null ? produto.getDescricao() : JSONObject.NULL);
        json.put("preco", dinheiro(produto.getPreco()));
        json.put("estoque", produto.getEstoque());
        json.put("categoria", produto.getCategoria() != null
                ? categoriaParaJson(produto.getCategoria())
                : JSONObject.NULL);
        json.put("imagemUrl", produto.isTemImagem()
                ? "/imagens/produtos/" + produto.getIdProduto() + "?v=" + produto.getImagemVersao()
                : JSONObject.NULL);
        return json;
    }

    /**
     * Serializa só o essencial do produto, para usar dentro de um item de pedido
     * (onde o Produto carregado pelo PedidoDAO só traz idProduto e nome).
     */
    public static JSONObject produtoResumoParaJson(Produto produto) {
        JSONObject json = new JSONObject();
        json.put("idProduto", produto.getIdProduto());
        json.put("nome", produto.getNome());
        return json;
    }

    /**
     * Serializa um item de pedido. Campos: idItemPedido, quantidade,
     * precoUnitario (String), subtotal (String), produto (resumo).
     */
    public static JSONObject itemPedidoParaJson(ItemPedido item) {
        JSONObject json = new JSONObject();
        json.put("idItemPedido", item.getIdItemPedido());
        json.put("quantidade", item.getQuantidade());
        json.put("precoUnitario", dinheiro(item.getPrecoUnitario()));
        json.put("subtotal", dinheiro(item.getSubtotal()));
        json.put("produto", produtoResumoParaJson(item.getProduto()));
        return json;
    }

    /**
     * Serializa o resumo do pedido, sem itens e sem cliente. Campos: idPedido,
     * dataPedido (ISO-8601), status, total (String).
     */
    public static JSONObject pedidoResumoParaJson(Pedido pedido) {
        JSONObject json = new JSONObject();
        json.put("idPedido", pedido.getIdPedido());
        json.put("dataPedido", dataIso(pedido.getDataPedido()));
        json.put("status", pedido.getStatus());
        json.put("total", dinheiro(pedido.getTotal()));
        return json;
    }

    /**
     * Resumo do pedido + itens. Uso: cliente vendo o próprio pedido.
     */
    public static JSONObject pedidoComItensParaJson(Pedido pedido) {
        JSONObject json = pedidoResumoParaJson(pedido);
        JSONArray itens = new JSONArray();
        for (ItemPedido item : pedido.getItens()) {
            itens.put(itemPedidoParaJson(item));
        }
        json.put("itens", itens);
        return json;
    }

    /**
     * Resumo do pedido + dados do cliente (sem itens). Uso: admin listando todos
     * os pedidos.
     */
    public static JSONObject pedidoComClienteParaJson(Pedido pedido) {
        JSONObject json = pedidoResumoParaJson(pedido);
        JSONObject cliente = new JSONObject();
        cliente.put("idUsuario", pedido.getCliente().getIdUsuario());
        cliente.put("nome", pedido.getCliente().getNome());
        cliente.put("email", pedido.getCliente().getEmail());
        json.put("cliente", cliente);
        return json;
    }

    /**
     * Resumo do pedido + cliente + itens. Uso: admin vendo o detalhe de um pedido.
     */
    public static JSONObject pedidoAdminDetalheParaJson(Pedido pedido) {
        JSONObject json = pedidoComClienteParaJson(pedido);
        JSONArray itens = new JSONArray();
        for (ItemPedido item : pedido.getItens()) {
            itens.put(itemPedidoParaJson(item));
        }
        json.put("itens", itens);
        return json;
    }
}
