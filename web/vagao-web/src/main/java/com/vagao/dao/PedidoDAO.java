package com.vagao.dao;

import com.vagao.entidade.ItemPedido;
import com.vagao.entidade.Pedido;
import com.vagao.entidade.Produto;
import com.vagao.entidade.Usuario;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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

    public List<Pedido> listarPorUsuario(int idUsuario) throws SQLException {
        String sql = SELECT_CABECALHO
                + " WHERE pe.id_usuario = ? "
                + "GROUP BY pe.id_pedido, pe.data_pedido, pe.status, u.id_usuario, u.nome, u.email "
                + "ORDER BY pe.data_pedido DESC";

        List<Pedido> pedidos = new ArrayList<>();

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    pedidos.add(mapearCabecalho(rs));
                }
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

    /**
     * Filtra por dono no próprio SQL: um cliente nunca recebe o pedido de outro (RF14).
     */
    public Pedido buscarPorIdEUsuario(int idPedido, int idUsuario) throws SQLException {
        String sql = SELECT_CABECALHO
                + " WHERE pe.id_pedido = ? AND pe.id_usuario = ? "
                + "GROUP BY pe.id_pedido, pe.data_pedido, pe.status, u.id_usuario, u.nome, u.email";

        try (Connection con = ConexaoFactory.getConexao()) {
            Pedido pedido;

            try (PreparedStatement stmt = con.prepareStatement(sql)) {
                stmt.setInt(1, idPedido);
                stmt.setInt(2, idUsuario);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (!rs.next()) {
                        return null;
                    }
                    pedido = mapearCabecalho(rs);
                }
            }

            try (PreparedStatement stmt = con.prepareStatement(SELECT_ITENS)) {
                stmt.setInt(1, idPedido);
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

    /**
     * Cria o pedido, seus itens e baixa o estoque em uma única transação.
     * Qualquer falha desfaz tudo.
     */
    public int inserir(Pedido pedido) throws SQLException, EstoqueInsuficienteException {
        String sqlPedido = "INSERT INTO pedido (status, id_usuario) VALUES (?, ?)";
        String sqlBaixaEstoque = "UPDATE produto SET estoque = estoque - ? WHERE id_produto = ? AND estoque >= ?";
        String sqlItem = "INSERT INTO item_pedido (quantidade, preco_unitario, id_pedido, id_produto) "
                + "VALUES (?, ?, ?, ?)";

        try (Connection con = ConexaoFactory.getConexao()) {
            con.setAutoCommit(false);

            try {
                int idPedido;
                try (PreparedStatement stmt = con.prepareStatement(sqlPedido, Statement.RETURN_GENERATED_KEYS)) {
                    stmt.setString(1, pedido.getStatus());
                    stmt.setInt(2, pedido.getCliente().getIdUsuario());
                    stmt.executeUpdate();

                    try (ResultSet chaves = stmt.getGeneratedKeys()) {
                        if (chaves.next()) {
                            idPedido = chaves.getInt(1);
                        } else {
                            throw new SQLException("Nenhuma chave gerada ao inserir pedido.");
                        }
                    }
                }

                for (ItemPedido item : pedido.getItens()) {
                    int idProduto = item.getProduto().getIdProduto();
                    int quantidade = item.getQuantidade();

                    try (PreparedStatement stmt = con.prepareStatement(sqlBaixaEstoque)) {
                        stmt.setInt(1, quantidade);
                        stmt.setInt(2, idProduto);
                        stmt.setInt(3, quantidade);

                        if (stmt.executeUpdate() == 0) {
                            throw new EstoqueInsuficienteException(
                                    "Estoque insuficiente para o produto " + idProduto + ".");
                        }
                    }

                    try (PreparedStatement stmt = con.prepareStatement(sqlItem)) {
                        stmt.setInt(1, quantidade);
                        stmt.setBigDecimal(2, item.getPrecoUnitario());
                        stmt.setInt(3, idPedido);
                        stmt.setInt(4, idProduto);
                        stmt.executeUpdate();
                    }
                }

                con.commit();
                return idPedido;
            } catch (SQLException | EstoqueInsuficienteException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
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

    /**
     * Conta os pedidos agrupados por status, para o painel do administrador (RF20).
     * Devolve só os status presentes no banco; preencher os ausentes é
     * responsabilidade de quem consome (a API completa com zero).
     */
    public Map<String, Integer> contarPorStatus() throws SQLException {
        String sql = "SELECT status, COUNT(*) AS quantidade FROM pedido GROUP BY status";

        Map<String, Integer> contagem = new LinkedHashMap<>();

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                contagem.put(rs.getString("status"), rs.getInt("quantidade"));
            }
        }
        return contagem;
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
