package com.vagao.entidade;

import java.io.Serializable;
import java.util.Date;

/**
 * Entidade que representa a foto de um produto (tabela `produto_imagem`).
 * Relação 1:1 com Produto, em tabela separada para que o binário nunca
 * seja carregado em consultas de listagem do catálogo.
 */
public class ProdutoImagem implements Serializable {

    private static final long serialVersionUID = 1L;

    private int idProduto;
    private String mime;
    private byte[] conteudo;
    private Date atualizadoEm;

    public ProdutoImagem() {
    }

    public int getIdProduto() {
        return idProduto;
    }

    public void setIdProduto(int idProduto) {
        this.idProduto = idProduto;
    }

    public String getMime() {
        return mime;
    }

    public void setMime(String mime) {
        this.mime = mime;
    }

    public byte[] getConteudo() {
        return conteudo;
    }

    public void setConteudo(byte[] conteudo) {
        this.conteudo = conteudo;
    }

    public Date getAtualizadoEm() {
        return atualizadoEm;
    }

    public void setAtualizadoEm(Date atualizadoEm) {
        this.atualizadoEm = atualizadoEm;
    }
}
