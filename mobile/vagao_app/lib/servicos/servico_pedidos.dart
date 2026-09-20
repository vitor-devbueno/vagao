import 'package:dio/dio.dart';

import '../modelos/item_carrinho.dart';
import '../modelos/pedido.dart';
import 'cliente_http.dart';
import 'erro_api.dart';

/// Consome a API JSON de pedidos do cliente (com.vagao.api.PedidoApiServlet).
class ServicoPedidos {
  static const String _mensagemSemConexao =
      'Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.';

  /// GET /api/pedidos. 200 -> pedidos do cliente logado.
  Future<List<Pedido>> meusPedidos() async {
    try {
      final resposta = await ClienteHttp.dio.get('/api/pedidos');

      if (resposta.statusCode == 200) {
        final lista = resposta.data['pedidos'] as List<dynamic>;
        return lista
            .map((e) => Pedido.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ErroApi(_extrairMensagemErro(resposta));
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErroApi(_extrairMensagemErro(e.response!));
      }
      throw ErroApi(_mensagemSemConexao);
    }
  }

  /// GET /api/pedidos/detalhe?id=N. 404 se o pedido não existir ou não for
  /// do cliente logado (checagem de propriedade feita no backend).
  Future<Pedido> buscar(int id) async {
    try {
      final resposta = await ClienteHttp.dio.get(
        '/api/pedidos/detalhe',
        queryParameters: {'id': id},
      );

      if (resposta.statusCode == 200) {
        return Pedido.fromJson(resposta.data['pedido'] as Map<String, dynamic>);
      }

      throw ErroApi(_extrairMensagemErro(resposta));
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErroApi(_extrairMensagemErro(e.response!));
      }
      throw ErroApi(_mensagemSemConexao);
    }
  }

  /// POST /api/pedidos/novo. 201 -> id do pedido criado.
  /// 409 (estoque insuficiente) -> ErroEstoque, para a tela manter o carrinho.
  Future<int> realizar(List<ItemCarrinho> itens) async {
    try {
      final resposta = await ClienteHttp.dio.post(
        '/api/pedidos/novo',
        data: {
          'itens': itens
              .map((item) => {
                    'idProduto': item.produto.idProduto,
                    'quantidade': item.quantidade,
                  })
              .toList(),
        },
      );

      if (resposta.statusCode == 201) {
        return resposta.data['idPedido'] as int;
      }

      if (resposta.statusCode == 409) {
        throw ErroEstoque(_extrairMensagemErro(resposta));
      }

      throw ErroApi(_extrairMensagemErro(resposta));
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 409) {
          throw ErroEstoque(_extrairMensagemErro(e.response!));
        }
        throw ErroApi(_extrairMensagemErro(e.response!));
      }
      throw ErroApi(_mensagemSemConexao);
    }
  }

  String _extrairMensagemErro(Response resposta) {
    final corpo = resposta.data;
    if (corpo is Map<String, dynamic> && corpo['erro'] is String) {
      return corpo['erro'] as String;
    }
    return _mensagemSemConexao;
  }
}
