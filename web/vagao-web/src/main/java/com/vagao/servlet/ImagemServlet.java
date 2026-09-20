package com.vagao.servlet;

import com.vagao.dao.ProdutoImagemDAO;
import com.vagao.entidade.ProdutoImagem;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Serve a foto de um produto (tabela `produto_imagem`).
 * Rota pública, sem filtro: o Image.network do app Mobile não compartilha
 * o cookie de sessão do Dio, e foto de produto não é dado sensível.
 * O id no path é convertido por Integer.parseInt — qualquer tentativa de
 * path traversal ou nome forjado falha nesse parse e vira 404, antes de
 * qualquer acesso a dado.
 */
@WebServlet("/imagens/produtos/*")
public class ImagemServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(ImagemServlet.class.getName());

    private final ProdutoImagemDAO produtoImagemDAO = new ProdutoImagemDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.length() <= 1) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        int idProduto;
        try {
            idProduto = Integer.parseInt(pathInfo.substring(1));
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        try {
            ProdutoImagem imagem = produtoImagemDAO.buscar(idProduto);
            if (imagem == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            byte[] conteudo = imagem.getConteudo();

            response.setContentType(imagem.getMime());
            response.setContentLength(conteudo.length);
            response.setHeader("X-Content-Type-Options", "nosniff");
            response.setHeader("Content-Disposition", "inline");
            response.setHeader("Cache-Control", "public, max-age=3600");
            if (imagem.getAtualizadoEm() != null) {
                response.setDateHeader("Last-Modified", imagem.getAtualizadoEm().getTime());
            }

            response.getOutputStream().write(conteudo);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Erro ao carregar imagem do produto " + idProduto, e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
