package com.vagao.dao;

import com.vagao.entidade.Categoria;
import com.vagao.entidade.Produto;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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
