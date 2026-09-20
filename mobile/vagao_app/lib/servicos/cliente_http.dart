import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

import '../config/ambiente.dart';

/// Cliente HTTP único do app, com cookie jar persistente em disco.
///
/// Reaproveita a mesma HttpSession + cookie JSESSIONID do backend Web
/// (Semanas 1-4) — nenhuma infraestrutura de autenticação nova.
class ClienteHttp {
  ClienteHttp._();

  static late final Dio dio;

  static Future<void> inicializar() async {
    final dir = await getApplicationDocumentsDirectory();

    // ignoreExpires: true é obrigatório. O JSESSIONID do backend não tem
    // Max-Age/Expires (é cookie de sessão) — sem essa flag, o cookie jar
    // o descarta ao recarregar do disco e a persistência de login quebra.
    final jar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage('${dir.path}/.cookies/'),
    );

    dio = Dio(BaseOptions(
      baseUrl: Ambiente.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
      // Deixa 400/401 chegarem como resposta normal (não como exceção),
      // para o serviço ler a mensagem do campo "erro". Só erro de rede/
      // timeout vira DioException.
      validateStatus: (status) => status != null && status < 500,
    ));

    dio.interceptors.add(CookieManager(jar));
  }

  /// Usado no logout: limpa os cookies locais além de invalidar a sessão
  /// no servidor (feito separadamente pelo ServicoAutenticacao).
  static Future<void> limparCookies() async {
    final dir = await getApplicationDocumentsDirectory();
    final jar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage('${dir.path}/.cookies/'),
    );
    await jar.deleteAll();
  }
}
