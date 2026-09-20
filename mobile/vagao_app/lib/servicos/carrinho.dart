import 'package:flutter/foundation.dart';

import '../modelos/item_carrinho.dart';
import '../modelos/produto.dart';

/// Carrinho de compras em memória (não persiste em disco — ver decisão E5).
/// Usa ChangeNotifier + ListenableBuilder, ambos nativos do Flutter, para não
/// introduzir Provider/Bloc/Riverpod (decisão D9 da Semana 5).
class Carrinho extends ChangeNotifier {
  Carrinho._();

  static final Carrinho instancia = Carrinho._();

  final List<ItemCarrinho> _itens = [];

  List<ItemCarrinho> get itens => List.unmodifiable(_itens);

  bool get vazio => _itens.isEmpty;

  int get totalItens => _itens.fold(0, (soma, item) => soma + item.quantidade);

  double get valorTotal => _itens.fold(0.0, (soma, item) => soma + item.subtotal);

  /// Soma a quantidade se o produto já está no carrinho, sempre limitado ao
  /// estoque disponível (dado fresco, lido na tela de detalhe do produto).
  void adicionar(Produto produto, int quantidade) {
    final existente = _itens.where((i) => i.produto.idProduto == produto.idProduto);
    if (existente.isNotEmpty) {
      final item = existente.first;
      final novaQuantidade = item.quantidade + quantidade;
      item.quantidade = novaQuantidade > produto.estoque ? produto.estoque : novaQuantidade;
    } else {
      final inicial = quantidade > produto.estoque ? produto.estoque : quantidade;
      _itens.add(ItemCarrinho(produto: produto, quantidade: inicial));
    }
    notifyListeners();
  }

  void alterarQuantidade(int idProduto, int quantidade) {
    final encontrados = _itens.where((i) => i.produto.idProduto == idProduto);
    if (encontrados.isEmpty) return;

    if (quantidade < 1) {
      remover(idProduto);
      return;
    }
    final item = encontrados.first;
    item.quantidade = quantidade > item.produto.estoque ? item.produto.estoque : quantidade;
    notifyListeners();
  }

  void remover(int idProduto) {
    _itens.removeWhere((i) => i.produto.idProduto == idProduto);
    notifyListeners();
  }

  /// Chamado após uma compra bem-sucedida (nunca após ErroEstoque/ErroApi).
  void limpar() {
    _itens.clear();
    notifyListeners();
  }
}
