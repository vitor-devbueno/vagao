package com.vagao.entidade;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Entidade que representa um pedido feito por um cliente.
 * Espelha a tabela `pedido`; `total` e calculado na consulta (nao e
 * coluna) e `itens` so e preenchido em buscarPorId.
 */
public class Pedido implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final List<String> STATUS_VALIDOS =
            List.of("pendente", "em preparo", "enviado", "entregue");

    private int idPedido;
    private Date dataPedido;
    private String status;
    private Usuario cliente;
    private BigDecimal total;
    private List<ItemPedido> itens = new ArrayList<>();

    public Pedido() {
    }

    public int getIdPedido() {
        return idPedido;
    }

    public void setIdPedido(int idPedido) {
        this.idPedido = idPedido;
    }

    public Date getDataPedido() {
        return dataPedido;
    }

    public void setDataPedido(Date dataPedido) {
        this.dataPedido = dataPedido;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Usuario getCliente() {
        return cliente;
    }

    public void setCliente(Usuario cliente) {
        this.cliente = cliente;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public void setTotal(BigDecimal total) {
        this.total = total;
    }

    public List<ItemPedido> getItens() {
        return itens;
    }

    public void setItens(List<ItemPedido> itens) {
        this.itens = itens;
    }
}
