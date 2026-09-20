package com.vagao.util;

/**
 * Validação de upload de imagem de produto. O tipo aceito é sempre
 * determinado pelos bytes do arquivo (magic bytes) — nunca pela extensão
 * do nome original nem pelo Content-Type informado pelo cliente, ambos
 * facilmente forjáveis.
 */
public final class ImagemUpload {

    public static final long TAMANHO_MAXIMO = 2 * 1024 * 1024;

    private ImagemUpload() {
    }

    /**
     * Devolve o mime derivado dos magic bytes do conteúdo, ou null se o
     * arquivo não for JPEG, PNG ou WebP.
     */
    public static String detectarMime(byte[] conteudo) {
        if (conteudo == null) {
            return null;
        }

        if (comecaCom(conteudo, 0xFF, 0xD8, 0xFF)) {
            return "image/jpeg";
        }

        if (comecaCom(conteudo, 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)) {
            return "image/png";
        }

        if (conteudo.length >= 12
                && conteudo[0] == 'R' && conteudo[1] == 'I' && conteudo[2] == 'F' && conteudo[3] == 'F'
                && conteudo[8] == 'W' && conteudo[9] == 'E' && conteudo[10] == 'B' && conteudo[11] == 'P') {
            return "image/webp";
        }

        return null;
    }

    private static boolean comecaCom(byte[] conteudo, int... bytesEsperados) {
        if (conteudo.length < bytesEsperados.length) {
            return false;
        }
        for (int i = 0; i < bytesEsperados.length; i++) {
            if ((conteudo[i] & 0xFF) != bytesEsperados[i]) {
                return false;
            }
        }
        return true;
    }
}
