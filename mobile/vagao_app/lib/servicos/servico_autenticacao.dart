import 'package:dio/dio.dart';

import '../modelos/usuario.dart';
import 'cliente_http.dart';
import 'erro_api.dart';

/// Consome a API JSON de autenticação (com.vagao.api.AutenticacaoApiServlet),
/// que reaproveita o mesmo mecanismo de sessão/perfil da aplicação Web.
class ServicoAutenticacao {
  static const String _mensagemSemConexao =
      'Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.';

  /// POST /api/auth/login.
  /// 200 -> Usuario autenticado.
  /// 400/401 -> ErroApi com a mensagem devolvida pelo servidor.
  /// Falha de rede -> ErroApi com mensagem amigável.
  Future<Usuario> entrar(String email, String senha) async {
    try {
      final resposta = await ClienteHttp.dio.post(
        '/api/auth/login',
        data: {'email': email, 'senha': senha},
      );

      if (resposta.statusCode == 200) {
        final usuarioJson = resposta.data['usuario'] as Map<String, dynamic>;
        return Usuario.fromJson(usuarioJson);
      }

      throw ErroApi(_extrairMensagemErro(resposta));
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErroApi(_extrairMensagemErro(e.response!));
      }
      throw ErroApi(_mensagemSemConexao);
    }
  }

  /// GET /api/auth/sessao.
  /// 200 -> Usuario da sessão ativa.
  /// 401 -> null (sessão ausente ou expirada — não é erro, é estado normal).
  /// Falha de rede -> ErroApi.
  Future<Usuario?> sessaoAtual() async {
    try {
      final resposta = await ClienteHttp.dio.get('/api/auth/sessao');

      if (resposta.statusCode == 200) {
        final usuarioJson = resposta.data['usuario'] as Map<String, dynamic>;
        return Usuario.fromJson(usuarioJson);
      }

      if (resposta.statusCode == 401) {
        return null;
      }

      throw ErroApi(_extrairMensagemErro(resposta));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return null;
      }
      throw ErroApi(_mensagemSemConexao);
    }
  }

  /// POST /api/auth/logout, seguido da limpeza dos cookies locais.
  /// Não propaga erro: sair sempre "funciona" do ponto de vista do app,
  /// mesmo que o servidor esteja fora do ar.
  Future<void> sair() async {
    try {
      await ClienteHttp.dio.post('/api/auth/logout');
    } on DioException {
      // Sem servidor disponível para invalidar a sessão remota, mas o app
      // ainda deve conseguir "esquecer" o usuário localmente.
    }
    await ClienteHttp.limparCookies();
  }

  String _extrairMensagemErro(Response resposta) {
    final corpo = resposta.data;
    if (corpo is Map<String, dynamic> && corpo['erro'] is String) {
      return corpo['erro'] as String;
    }
    return _mensagemSemConexao;
  }
}
