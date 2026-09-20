/// Erro de negócio ou de rede vindo da API. A mensagem já é adequada
/// para exibir diretamente ao usuário — nunca expor DioException.toString().
class ErroApi implements Exception {
  final String mensagem;

  ErroApi(this.mensagem);

  @override
  String toString() => mensagem;
}
