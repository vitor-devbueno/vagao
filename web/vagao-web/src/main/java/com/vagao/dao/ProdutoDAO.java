package com.vagao.dao;

import com.vagao.entidade.Categoria;
import com.vagao.entidade.Produto;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * Acesso a dados da tabela `produto`, com a categoria trazida via JOIN.
 */
public class ProdutoDAO {

    private static final String SELECT_BASE =
            "SELECT p.id_produto, p.nome, p.descricao, p.preco, p.estoque, "
            + "c.id_categoria, c.nome AS nome_categoria "
            + "FROM produto p JOIN categoria c ON c.id_categoria = p.id_categoria";

    public List<Produto> listarTodos() throws SQLException {
        String sql = SELECT_BASE + " ORDER BY p.nome";
        List<Produto> produtos = new ArrayList<>();

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                produtos.add(mapear(rs));
            }
        }
        return produtos;
    }

    public Produto buscarPorId(int id) throws SQLException {
        String sql = SELECT_BASE + " WHERE p.id_produto = ?";

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? mapear(rs) : null;
            }
        }
    }

    public int inserir(Produto produto) throws SQLException {
        String sql = "INSERT INTO produto (nome, descricao, preco, estoque, id_categoria) "
                + "VALUES (?, ?, ?, ?, ?)";

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            preencherParametros(stmt, produto);
            stmt.executeUpdate();

            try (ResultSet chaves = stmt.getGeneratedKeys()) {
                if (chaves.next()) {
                    return chaves.getInt(1);
                }
                throw new SQLException("Nenhuma chave gerada ao inserir produto.");
            }
        }
    }

    public boolean atualizar(Produto produto) throws SQLException {
        String sql = "UPDATE produto SET nome = ?, descricao = ?, preco = ?, estoque = ?, "
                + "id_categoria = ? WHERE id_produto = ?";

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql)) {

            preencherParametros(stmt, produto);
            stmt.setInt(6, produto.getIdProduto());

            return stmt.executeUpdate() == 1;
        }
    }

    public boolean excluir(int id) throws SQLException {
        String sql = "DELETE FROM produto WHERE id_produto = ?";

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() == 1;
        }
    }

    public boolean possuiPedidos(int idProduto) throws SQLException {
        String sql = "SELECT 1 FROM item_pedido WHERE id_produto = ? LIMIT 1";

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql)) {

            stmt.setInt(1, idProduto);

            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    private void preencherParametros(PreparedStatement stmt, Produto produto) throws SQLException {
        stmt.setString(1, produto.getNome());

        String descricao = produto.getDescricao();
        if (descricao == null || descricao.isEmpty()) {
            stmt.setNull(2, Types.VARCHAR);
        } else {
            stmt.setString(2, descricao);
        }

        stmt.setBigDecimal(3, produto.getPreco());
        stmt.setInt(4, produto.getEstoque());
        stmt.setInt(5, produto.getCategoria().getIdCategoria());
    }

    private Produto mapear(ResultSet rs) throws SQLException {
        Produto produto = new Produto();
        produto.setIdProduto(rs.getInt("id_produto"));
        produto.setNome(rs.getString("nome"));
        produto.setDescricao(rs.getString("descricao"));
        produto.setPreco(rs.getBigDecimal("preco"));
        produto.setEstoque(rs.getInt("estoque"));

        Categoria categoria = new Categoria();
        categoria.setIdCategoria(rs.getInt("id_categoria"));
        categoria.setNome(rs.getString("nome_categoria"));
        produto.setCategoria(categoria);

        return produto;
    }
}
