package com.vagao.dao;

import com.vagao.entidade.ItemPedido;
import com.vagao.entidade.Pedido;
import com.vagao.entidade.Produto;
import com.vagao.entidade.Usuario;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Acesso a dados das tabelas `pedido` e `item_pedido`.
 * Nunca seleciona a coluna `usuario.senha`.
 */
public class PedidoDAO {

    private static final String SELECT_CABECALHO =
            "SELECT pe.id_pedido, pe.data_pedido, pe.status, "
            + "u.id_usuario, u.nome, u.email, "
            + "COALESCE(SUM(i.quantidade * i.preco_unitario), 0) AS total "
            + "FROM pedido pe "
            + "JOIN usuario u ON u.id_usuario = pe.id_usuario "
            + "LEFT JOIN item_pedido i ON i.id_pedido = pe.id_pedido";

    private static final String SELECT_ITENS =
            "SELECT i.id_item_pedido, i.quantidade, i.preco_unitario, "
            + "pr.id_produto, pr.nome "
            + "FROM item_pedido i "
            + "JOIN produto pr ON pr.id_produto = i.id_produto "
            + "WHERE i.id_pedido = ?";

    public List<Pedido> listarTodos() throws SQLException {
        String sql = SELECT_CABECALHO
                + " GROUP BY pe.id_pedido, pe.data_pedido, pe.status, u.id_usuario, u.nome, u.email "
                + "ORDER BY pe.data_pedido DESC";

        List<Pedido> pedidos = new ArrayList<>();

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                pedidos.add(mapearCabecalho(rs));
            }
        }
        return pedidos;
    }

    public Pedido buscarPorId(int id) throws SQLException {
        String sql = SELECT_CABECALHO
                + " WHERE pe.id_pedido = ? "
                + "GROUP BY pe.id_pedido, pe.data_pedido, pe.status, u.id_usuario, u.nome, u.email";

        try (Connection con = ConexaoFactory.getConexao()) {
            Pedido pedido;

            try (PreparedStatement stmt = con.prepareStatement(sql)) {
                stmt.setInt(1, id);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (!rs.next()) {
                        return null;
                    }
                    pedido = mapearCabecalho(rs);
                }
            }

            try (PreparedStatement stmt = con.prepareStatement(SELECT_ITENS)) {
                stmt.setInt(1, id);
                try (ResultSet rs = stmt.executeQuery()) {
                    List<ItemPedido> itens = new ArrayList<>();
                    while (rs.next()) {
                        itens.add(mapearItem(rs));
                    }
                    pedido.setItens(itens);
                }
            }

            return pedido;
        }
    }

    public boolean atualizarStatus(int idPedido, String status) throws SQLException {
        String sql = "UPDATE pedido SET status = ? WHERE id_pedido = ?";

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setInt(2, idPedido);

            return stmt.executeUpdate() == 1;
        }
    }

    private Pedido mapearCabecalho(ResultSet rs) throws SQLException {
        Pedido pedido = new Pedido();
        pedido.setIdPedido(rs.getInt("id_pedido"));
        pedido.setDataPedido(rs.getTimestamp("data_pedido"));
        pedido.setStatus(rs.getString("status"));
        pedido.setTotal(rs.getBigDecimal("total"));

        Usuario cliente = new Usuario();
        cliente.setIdUsuario(rs.getInt("id_usuario"));
        cliente.setNome(rs.getString("nome"));
        cliente.setEmail(rs.getString("email"));
        pedido.setCliente(cliente);

        return pedido;
    }

    private ItemPedido mapearItem(ResultSet rs) throws SQLException {
        ItemPedido item = new ItemPedido();
        item.setIdItemPedido(rs.getInt("id_item_pedido"));
        item.setQuantidade(rs.getInt("quantidade"));
        item.setPrecoUnitario(rs.getBigDecimal("preco_unitario"));

        Produto produto = new Produto();
        produto.setIdProduto(rs.getInt("id_produto"));
        produto.setNome(rs.getString("nome"));
        item.setProduto(produto);

        return item;
    }
}
