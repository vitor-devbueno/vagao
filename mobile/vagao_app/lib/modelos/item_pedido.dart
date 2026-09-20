/// Espelha com.vagao.entidade.ItemPedido do backend Java.
/// O produto aninhado no JSON vem só com idProduto/nome (JsonUtil.produtoResumoParaJson),
/// pois é isso que o PedidoDAO carrega para itens de pedido — por isso os campos
/// de produto ficam soltos aqui, não como um Produto completo.
class ItemPedido {
  final int idItemPedido;
  final int quantidade;
  final double precoUnitario;
  final double subtotal;
  final int idProduto;
  final String nomeProduto;

  ItemPedido({
    required this.idItemPedido,
    required this.quantidade,
    required this.precoUnitario,
    required this.subtotal,
    required this.idProduto,
    required this.nomeProduto,
  });

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    final produtoJson = json['produto'] as Map<String, dynamic>;
    return ItemPedido(
      idItemPedido: json['idItemPedido'] as int,
      quantidade: json['quantidade'] as int,
      precoUnitario: double.parse(json['precoUnitario'] as String),
      subtotal: double.parse(json['subtotal'] as String),
      idProduto: produtoJson['idProduto'] as int,
      nomeProduto: produtoJson['nome'] as String,
    );
  }
}
