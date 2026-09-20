import 'categoria.dart';

/// Espelha com.vagao.entidade.Produto do backend Java.
class Produto {
  final int idProduto;
  final String nome;
  final String? descricao;
  final double preco;
  final int estoque;
  final Categoria? categoria;

  Produto({
    required this.idProduto,
    required this.nome,
    this.descricao,
    required this.preco,
    required this.estoque,
    this.categoria,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      idProduto: json['idProduto'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
      // O backend sempre manda preco como String com 2 casas (JsonUtil.dinheiro),
      // justamente para não haver ambiguidade int/double no parse — nunca usar
      // `as double` aqui.
      preco: double.parse(json['preco'] as String),
      estoque: json['estoque'] as int,
      categoria: json['categoria'] != null
          ? Categoria.fromJson(json['categoria'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get disponivel => estoque > 0;

  /// Duas primeiras letras do nome, maiúsculas — usadas no placeholder visual
  /// (ThumbProduto), já que o banco não tem coluna de imagem.
  String get iniciais {
    final limpo = nome.trim();
    final ate = limpo.length < 2 ? limpo.length : 2;
    return limpo.substring(0, ate).toUpperCase();
  }
}
