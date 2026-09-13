package com.vagao.dao;

import com.vagao.entidade.Usuario;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Acesso a dados da tabela `usuario`.
 */
public class UsuarioDAO {

    // Hash "morto" usado apenas para gastar tempo equivalente a uma verificação real
    // quando o e-mail informado não existe, evitando timing attack para descobrir
    // quais e-mails estão cadastrados.
    private static final String HASH_FICTICIO =
            "$2a$12$CwTycUXWue0Thq9StjUM0uJ8xAOdc9v3P5Xn3O9tR5X6HkX9r0j0S";

    /**
     * Busca um usuário pelo e-mail. Retorna null se não encontrado.
     */
    public Usuario buscarPorEmail(String email) throws SQLException {
        String sql = "SELECT id_usuario, nome, email, senha, perfil, telefone "
                + "FROM usuario WHERE email = ?";

        try (Connection con = ConexaoFactory.getConexao();
             PreparedStatement stmt = con.prepareStatement(sql)) {

            stmt.setString(1, email);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapear(rs);
                }
                return null;
            }
        }
    }

    /**
     * Valida e-mail e senha. Retorna o usuário autenticado (sem o hash da senha)
     * em caso de sucesso, ou null se as credenciais forem inválidas.
     */
    public Usuario autenticar(String email, String senhaDigitada) throws SQLException {
        Usuario usuario = buscarPorEmail(email);

        if (usuario == null) {
            // Gasta tempo equivalente a uma checagem real para não revelar,
            // pelo tempo de resposta, se o e-mail existe ou não.
            BCrypt.checkpw(senhaDigitada, HASH_FICTICIO);
            return null;
        }

        if (!BCrypt.checkpw(senhaDigitada, usuario.getSenha())) {
            return null;
        }

        // Não mantém o hash da senha em memória além do necessário (ex.: sessão).
        usuario.setSenha(null);
        return usuario;
    }

    private Usuario mapear(ResultSet rs) throws SQLException {
        Usuario usuario = new Usuario();
        usuario.setIdUsuario(rs.getInt("id_usuario"));
        usuario.setNome(rs.getString("nome"));
        usuario.setEmail(rs.getString("email"));
        usuario.setSenha(rs.getString("senha"));
        usuario.setPerfil(rs.getString("perfil"));
        usuario.setTelefone(rs.getString("telefone"));
        return usuario;
    }
}
