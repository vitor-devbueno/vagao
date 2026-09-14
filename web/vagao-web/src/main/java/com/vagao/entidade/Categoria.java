package com.vagao.entidade;

import java.io.Serializable;

/**
 * Entidade que representa uma categoria (ou "drop") de produtos.
 * Espelha a tabela `categoria` do banco de dados.
 */
public class Categoria implements Serializable {

    private static final long serialVersionUID = 1L;

    private int idCategoria;
    private String nome;

    public Categoria() {
    }

    public int getIdCategoria() {
        return idCategoria;
    }

    public void setIdCategoria(int idCategoria) {
        this.idCategoria = idCategoria;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }
}
