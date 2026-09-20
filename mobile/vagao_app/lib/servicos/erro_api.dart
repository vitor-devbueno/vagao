/// Erro de negócio ou de rede vindo da API. A mensagem já é adequada
/// para exibir diretamente ao usuário — nunca expor DioException.toString().
class ErroApi implements Exception {
  final String mensagem;

  ErroApi(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Erro específico de estoque insuficiente (HTTP 409, código ESTOQUE_INSUFICIENTE).
/// Distinguir esse caso permite à tela de carrinho manter os itens intactos e
/// convidar o usuário a reduzir a quantidade, em vez de tratá-lo como falha genérica.
class ErroEstoque extends ErroApi {
  ErroEstoque(super.mensagem);
}
