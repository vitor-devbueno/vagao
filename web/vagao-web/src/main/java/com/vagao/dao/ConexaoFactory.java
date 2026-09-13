package com.vagao.dao;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Fábrica de conexões JDBC com o MySQL.
 * Lê as credenciais de `db.properties` (classpath) uma única vez.
 */
public class ConexaoFactory {

    private static final String ARQUIVO_CONFIG = "db.properties";
    private static final Properties propriedades = new Properties();

    static {
        try (InputStream in = ConexaoFactory.class.getClassLoader()
                .getResourceAsStream(ARQUIVO_CONFIG)) {
            if (in == null) {
                throw new RuntimeException(
                        "Arquivo " + ARQUIVO_CONFIG + " não encontrado no classpath. "
                        + "Copie db.properties.example para db.properties e preencha as credenciais.");
            }
            propriedades.load(in);
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (IOException e) {
            throw new RuntimeException("Erro ao ler " + ARQUIVO_CONFIG, e);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Driver JDBC do MySQL não encontrado no classpath.", e);
        }
    }

    private ConexaoFactory() {
    }

    public static Connection getConexao() throws SQLException {
        String url = propriedades.getProperty("db.url");
        String usuario = propriedades.getProperty("db.user");
        String senha = propriedades.getProperty("db.password");
        return DriverManager.getConnection(url, usuario, senha);
    }
}
