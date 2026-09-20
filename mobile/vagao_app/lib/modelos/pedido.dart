import 'item_pedido.dart';

/// Espelha com.vagao.entidade.Pedido do backend Java.
/// `itens` só vem preenchido no detalhe (pedidoComItensParaJson/pedidoAdminDetalheParaJson);
/// na listagem (pedidoResumoParaJson/pedidoComClienteParaJson) chega vazio.
/// `nomeCliente`/`emailCliente` só vêm preenchidos nas respostas do admin
/// (pedidoComClienteParaJson/pedidoAdminDetalheParaJson).
class Pedido {
  final int idPedido;
  final DateTime dataPedido;
  final String status;
  final double total;
  final List<ItemPedido> itens;
  final String? nomeCliente;
  final String? emailCliente;

  Pedido({
    required this.idPedido,
    required this.dataPedido,
    required this.status,
    required this.total,
    this.itens = const [],
    this.nomeCliente,
    this.emailCliente,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    final itensJson = json['itens'] as List<dynamic>?;
    final clienteJson = json['cliente'] as Map<String, dynamic>?;

    return Pedido(
      idPedido: json['idPedido'] as int,
      dataPedido: DateTime.parse(json['dataPedido'] as String),
      status: json['status'] as String,
      total: double.parse(json['total'] as String),
      itens: itensJson == null
          ? const []
          : itensJson
              .map((e) => ItemPedido.fromJson(e as Map<String, dynamic>))
              .toList(),
      nomeCliente: clienteJson?['nome'] as String?,
      emailCliente: clienteJson?['email'] as String?,
    );
  }
}
