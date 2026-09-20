/// Contadores de pedidos por status, para o painel do administrador (RF20).
/// Espelha o JSON de GET /api/admin/resumo.
class ResumoLoja {
  final int totalPedidos;
  final Map<String, int> porStatus;

  ResumoLoja({required this.totalPedidos, required this.porStatus});

  factory ResumoLoja.fromJson(Map<String, dynamic> json) {
    final porStatusJson = json['porStatus'] as Map<String, dynamic>;
    return ResumoLoja(
      totalPedidos: json['totalPedidos'] as int,
      porStatus: porStatusJson.map((k, v) => MapEntry(k, v as int)),
    );
  }
}
