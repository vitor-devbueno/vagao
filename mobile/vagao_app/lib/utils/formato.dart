/// Formatação manual de moeda e data, sem depender do pacote `intl`
/// (que não é dependência do projeto — ver decisão E6 do plano da Semana 6).
class Formato {
  Formato._();

  /// Ex.: 89.9 -> "R$ 89,90".
  static String moeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Ex.: 2026-09-20 14:32 -> "20/09/2026 14:32".
  static String dataHora(DateTime data) {
    String dois(int v) => v.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year} '
        '${dois(data.hour)}:${dois(data.minute)}';
  }
}
