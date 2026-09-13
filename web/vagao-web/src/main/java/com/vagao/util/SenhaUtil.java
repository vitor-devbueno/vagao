package com.vagao.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Utilitário para gerar e conferir hashes bcrypt de senha.
 * Uso via linha de comando: gera o hash de uma senha para inserir no banco.
 *
 *   mvn exec:java ... ou, após compilar:
 *   java -cp target/classes:<caminho-do-jbcrypt.jar> com.vagao.util.SenhaUtil "minhaSenha"
 */
public class SenhaUtil {

    private static final int CUSTO_HASH = 12;

    private SenhaUtil() {
    }

    public static String hash(String senhaPura) {
        return BCrypt.hashpw(senhaPura, BCrypt.gensalt(CUSTO_HASH));
    }

    public static boolean confere(String senhaPura, String hash) {
        return BCrypt.checkpw(senhaPura, hash);
    }

    public static void main(String[] args) {
        if (args.length != 1) {
            System.err.println("Uso: SenhaUtil <senha>");
            System.exit(1);
        }
        System.out.println(hash(args[0]));
    }
}
