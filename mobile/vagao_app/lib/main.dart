import 'package:flutter/material.dart';

import 'servicos/cliente_http.dart';
import 'tema/tema_vagao.dart';
import 'telas/tela_carregamento.dart';
import 'telas/tela_login.dart';
import 'telas/admin/tela_home_admin.dart';
import 'telas/cliente/tela_home_cliente.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ClienteHttp.inicializar();
  runApp(const VagaoApp());
}

class VagaoApp extends StatelessWidget {
  const VagaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VAGÃO',
      debugShowCheckedModeBanner: false,
      theme: TemaVagao.tema,
      home: const TelaCarregamento(),
      routes: {
        '/login': (context) => const TelaLogin(),
        '/admin': (context) => const TelaHomeAdmin(),
        '/cliente': (context) => const TelaHomeCliente(),
      },
    );
  }
}
