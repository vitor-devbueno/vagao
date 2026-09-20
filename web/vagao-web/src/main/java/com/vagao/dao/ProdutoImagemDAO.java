package com.vagao.dao;

import com.vagao.entidade.ProdutoImagem;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Acesso a dados da tabela `produto_imagem`. O binário só é lido por
 * `buscar`, chamado exclusivamente pela ImagemServlet — nenhuma listagem
 * de produto carrega o conteúdo da foto.
 */
public class ProdutoImagemDAO {

    public void salvar(int idProduto, String mime, byte[] conteudo) throws SQLException {
        String sql = "INSERT INTO produto_imagem (id_produto, mime, conteudo) VALUES (?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE mime = VALUES(mime), conteudo = VALUES(conteudo)";

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql)) {

            stmt.setInt(1, idProduto);
            stmt.setString(2, mime);
            stmt.setBytes(3, conteudo);
            stmt.executeUpdate();
        }
    }

    public ProdutoImagem buscar(int idProduto) throws SQLException {
        String sql = "SELECT id_produto, mime, conteudo, atualizado_em "
                + "FROM produto_imagem WHERE id_produto = ?";

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql)) {

            stmt.setInt(1, idProduto);

            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                ProdutoImagem imagem = new ProdutoImagem();
                imagem.setIdProduto(rs.getInt("id_produto"));
                imagem.setMime(rs.getString("mime"));
                imagem.setConteudo(rs.getBytes("conteudo"));
                imagem.setAtualizadoEm(rs.getTimestamp("atualizado_em"));
                return imagem;
            }
        }
    }

    public boolean excluir(int idProduto) throws SQLException {
        String sql = "DELETE FROM produto_imagem WHERE id_produto = ?";

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql)) {

            stmt.setInt(1, idProduto);
            return stmt.executeUpdate() == 1;
        }
    }
}
