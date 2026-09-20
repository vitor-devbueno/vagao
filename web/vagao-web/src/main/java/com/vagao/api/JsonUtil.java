package com.vagao.api;

import com.vagao.entidade.Usuario;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Utilitários de serialização JSON para a API do aplicativo Mobile (com.vagao.api).
 * Nunca monta JSON por concatenação de String.
 */
public final class JsonUtil {

    private JsonUtil() {
    }

    /**
     * Escreve o corpo JSON com o status informado. Sempre UTF-8.
     */
    public static void escrever(HttpServletResponse response, int status, JSONObject corpo) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(corpo.toString());
    }

    /**
     * Atalho para {"erro": "..."} com o status informado.
     */
    public static void erro(HttpServletResponse response, int status, String mensagem) throws IOException {
        JSONObject corpo = new JSONObject();
        corpo.put("erro", mensagem);
        escrever(response, status, corpo);
    }

    /**
     * Serializa o usuário SEM a senha. Campos: idUsuario, nome, email, perfil, telefone.
     */
    public static JSONObject usuarioParaJson(Usuario usuario) {
        JSONObject json = new JSONObject();
        json.put("idUsuario", usuario.getIdUsuario());
        json.put("nome", usuario.getNome());
        json.put("email", usuario.getEmail());
        json.put("perfil", usuario.getPerfil());
        json.put("telefone", usuario.getTelefone());
        return json;
    }

    /**
     * Lê e parseia o corpo JSON da requisição. Devolve null se ausente ou malformado.
     */
    public static JSONObject lerCorpo(HttpServletRequest request) {
        try {
            return new JSONObject(new JSONTokener(request.getReader()));
        } catch (JSONException | IOException e) {
            return null;
        }
    }
}
