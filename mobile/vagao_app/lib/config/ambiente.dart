/// Configuração de ambiente do aplicativo.
///
/// Exclusivo de desenvolvimento: aponta para o backend Tomcat rodando na
/// própria máquina. Em produção, isso viraria uma URL HTTPS real.
class Ambiente {
  /// 10.0.2.2 é o alias que o emulador Android usa para acessar o
  /// localhost da máquina host (não é um IP de rede real).
  ///
  /// Testando em celular físico na mesma rede Wi-Fi: trocar por
  /// 'http://192.168.1.11:8080/vagao-web' (IP da máquina na LAN).
  ///
  /// O caminho '/vagao-web' é obrigatório: o cookie de sessão do backend
  /// vem com Path=/vagao-web, e o cookie jar só o reenvia em requisições
  /// cujo caminho começa com esse prefixo.
  static const String baseUrl = 'http://10.0.2.2:8080/vagao-web';
}
