/// Espelha a entidade com.vagao.entidade.Usuario do backend Java.
/// Nunca carrega senha — a API não a envia (JsonUtil.usuarioParaJson a omite).
class Usuario {
  final int idUsuario;
  final String nome;
  final String email;
  final String perfil;
  final String? telefone;

  Usuario({
    required this.idUsuario,
    required this.nome,
    required this.email,
    required this.perfil,
    this.telefone,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
      perfil: json['perfil'] as String,
      telefone: json['telefone'] as String?,
    );
  }

  /// Espelha Usuario.isAdmin() do backend — mesma regra dos dois lados.
  bool get isAdmin => perfil == 'admin';

  /// Espelha Usuario.isCliente() do backend — mesma regra dos dois lados.
  bool get isCliente => perfil == 'cliente';
}
