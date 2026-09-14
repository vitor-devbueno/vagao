package com.vagao.entidade;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Entidade que representa um produto do catálogo.
 * Espelha a tabela `produto` do banco de dados, com a categoria
 * composta como objeto (e não apenas o id) para uso direto nas views.
 */
public class Produto implements Serializable {

    private static final long serialVersionUID = 1L;

    private int idProduto;
    private String nome;
    private String descricao;
    private BigDecimal preco;
    private int estoque;
    private Categoria categoria;

    public Produto() {
    }

    public int getIdProduto() {
        return idProduto;
    }

    public void setIdProduto(int idProduto) {
        this.idProduto = idProduto;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public BigDecimal getPreco() {
        return preco;
    }

    public void setPreco(BigDecimal preco) {
        this.preco = preco;
    }

    public int getEstoque() {
        return estoque;
    }

    public void setEstoque(int estoque) {
        this.estoque = estoque;
    }

    public Categoria getCategoria() {
        return categoria;
    }

    public void setCategoria(Categoria categoria) {
        this.categoria = categoria;
    }
}
