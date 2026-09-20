import 'package:dio/dio.dart';

import '../modelos/pedido.dart';
import '../modelos/resumo_loja.dart';
import 'cliente_http.dart';
import 'erro_api.dart';

/// Consome a API JSON administrativa (com.vagao.api.AdminApiServlet).
class ServicoAdmin {
  static const String _mensagemSemConexao =
      'Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.';

  /// GET /api/admin/resumo. Contagem de pedidos por status (RF20).
  Future<ResumoLoja> resumo() async {
    try {
      final resposta = await ClienteHttp.dio.get('/api/admin/resumo');

      if (resposta.statusCode == 200) {
        return ResumoLoja.fromJson(resposta.data['resumo'] as Map<String, dynamic>);
      }

      throw ErroApi(_extrairMensagemErro(resposta));
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErroApi(_extrairMensagemErro(e.response!));
      }
      throw ErroApi(_mensagemSemConexao);
    }
  }

  /// GET /api/admin/pedidos. Todos os pedidos, com dados do cliente.
  Future<List<Pedido>> listarPedidos() async {
    try {
      final resposta = await ClienteHttp.dio.get('/api/admin/pedidos');

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

  /// GET /api/admin/pedidos/detalhe?id=N.
  Future<Pedido> buscarPedido(int id) async {
    try {
      final resposta = await ClienteHttp.dio.get(
        '/api/admin/pedidos/detalhe',
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

  String _extrairMensagemErro(Response resposta) {
    final corpo = resposta.data;
    if (corpo is Map<String, dynamic> && corpo['erro'] is String) {
      return corpo['erro'] as String;
    }
    return _mensagemSemConexao;
  }
}
