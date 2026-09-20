import 'package:dio/dio.dart';

import '../modelos/produto.dart';
import 'cliente_http.dart';
import 'erro_api.dart';

/// Consome a API JSON de catálogo (com.vagao.api.CatalogoApiServlet).
class ServicoCatalogo {
  static const String _mensagemSemConexao =
      'Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.';

  /// GET /api/catalogo. 200 -> lista de produtos disponíveis.
  Future<List<Produto>> listar() async {
    try {
      final resposta = await ClienteHttp.dio.get('/api/catalogo');

      if (resposta.statusCode == 200) {
        final lista = resposta.data['produtos'] as List<dynamic>;
        return lista
            .map((e) => Produto.fromJson(e as Map<String, dynamic>))
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

  /// GET /api/catalogo/detalhe?id=N. 200 -> produto; 404 -> ErroApi.
  Future<Produto> buscar(int id) async {
    try {
      final resposta = await ClienteHttp.dio.get(
        '/api/catalogo/detalhe',
        queryParameters: {'id': id},
      );

      if (resposta.statusCode == 200) {
        return Produto.fromJson(resposta.data['produto'] as Map<String, dynamic>);
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
