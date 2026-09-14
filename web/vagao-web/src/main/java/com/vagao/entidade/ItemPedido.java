package com.vagao.entidade;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Entidade que representa um item (linha) de um pedido.
 * Espelha a tabela `item_pedido`, com o produto composto como objeto.
 */
public class ItemPedido implements Serializable {

    private static final long serialVersionUID = 1L;

    private int idItemPedido;
    private int quantidade;
    private BigDecimal precoUnitario;
    private Produto produto;

    public ItemPedido() {
    }

    public int getIdItemPedido() {
        return idItemPedido;
    }

    public void setIdItemPedido(int idItemPedido) {
        this.idItemPedido = idItemPedido;
    }

    public int getQuantidade() {
        return quantidade;
    }

    public void setQuantidade(int quantidade) {
        this.quantidade = quantidade;
    }

    public BigDecimal getPrecoUnitario() {
        return precoUnitario;
    }

    public void setPrecoUnitario(BigDecimal precoUnitario) {
        this.precoUnitario = precoUnitario;
    }

    public Produto getProduto() {
        return produto;
    }

    public void setProduto(Produto produto) {
        this.produto = produto;
    }

    public BigDecimal getSubtotal() {
        return precoUnitario.multiply(BigDecimal.valueOf(quantidade));
    }
}
