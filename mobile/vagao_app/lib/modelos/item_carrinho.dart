import 'produto.dart';

/// Item do carrinho em memória (Carrinho, lib/servicos/carrinho.dart).
/// Não existe do lado do backend — é só estado local até o pedido ser enviado.
class ItemCarrinho {
  final Produto produto;
  int quantidade;

  ItemCarrinho({required this.produto, required this.quantidade});

  double get subtotal => produto.preco * quantidade;
}
