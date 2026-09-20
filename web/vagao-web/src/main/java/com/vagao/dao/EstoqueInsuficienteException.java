package com.vagao.dao;

/** Estoque acabou entre a exibição do produto e a confirmação do pedido. */
public class EstoqueInsuficienteException extends Exception {
    private static final long serialVersionUID = 1L;

    public EstoqueInsuficienteException(String mensagem) {
        super(mensagem);
    }
}
