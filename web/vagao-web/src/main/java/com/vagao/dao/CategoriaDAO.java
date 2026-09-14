package com.vagao.dao;

import com.vagao.entidade.Categoria;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Acesso a dados da tabela `categoria`.
 */
public class CategoriaDAO {

    public List<Categoria> listarTodas() throws SQLException {
        String sql = "SELECT id_categoria, nome FROM categoria ORDER BY nome";
        List<Categoria> categorias = new ArrayList<>();

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                categorias.add(mapear(rs));
            }
        }
        return categorias;
    }

    public Categoria buscarPorId(int id) throws SQLException {
        String sql = "SELECT id_categoria, nome FROM categoria WHERE id_categoria = ?";

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? mapear(rs) : null;
            }
        }
    }

    public int inserir(Categoria categoria) throws SQLException {
        String sql = "INSERT INTO categoria (nome) VALUES (?)";

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, categoria.getNome());
            stmt.executeUpdate();

            try (ResultSet chaves = stmt.getGeneratedKeys()) {
                if (chaves.next()) {
                    return chaves.getInt(1);
                }
                throw new SQLException("Nenhuma chave gerada ao inserir categoria.");
            }
        }
    }

    public boolean atualizar(Categoria categoria) throws SQLException {
        String sql = "UPDATE categoria SET nome = ? WHERE id_categoria = ?";

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql)) {

            stmt.setString(1, categoria.getNome());
            stmt.setInt(2, categoria.getIdCategoria());

            return stmt.executeUpdate() == 1;
        }
    }

    public boolean excluir(int id) throws SQLException {
        String sql = "DELETE FROM categoria WHERE id_categoria = ?";

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() == 1;
        }
    }

    /**
     * Verifica se já existe outra categoria com o mesmo nome.
     * Use ignorarId = 0 ao validar uma categoria nova.
     */
    public boolean existeNome(String nome, int ignorarId) throws SQLException {
        String sql = "SELECT 1 FROM categoria WHERE nome = ? AND id_categoria <> ? LIMIT 1";

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql)) {

            stmt.setString(1, nome);
            stmt.setInt(2, ignorarId);

            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    public int contarProdutos(int idCategoria) throws SQLException {
        String sql = "SELECT COUNT(*) FROM produto WHERE id_categoria = ?";

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql)) {

            stmt.setInt(1, idCategoria);

            try (ResultSet rs = stmt.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    private Categoria mapear(ResultSet rs) throws SQLException {
        Categoria categoria = new Categoria();
        categoria.setIdCategoria(rs.getInt("id_categoria"));
        categoria.setNome(rs.getString("nome"));
        return categoria;
    }
}
