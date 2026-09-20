import 'package:flutter/material.dart';

import '../../servicos/servico_autenticacao.dart';
import '../../tema/tema_vagao.dart';
import '../../widgets/card_vagao.dart';
import 'tela_catalogo.dart';
import 'tela_meus_pedidos.dart';

/// Home do perfil cliente. Navega para o catálogo real e para os próprios
/// pedidos (RF17/RF19) — as duas entregas da Semana 6 para este perfil.
class TelaHomeCliente extends StatelessWidget {
  const TelaHomeCliente({super.key});

  Future<void> _sair(BuildContext context) async {
    await ServicoAutenticacao().sair();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaVagao.preto,
      appBar: AppBar(
        title: const Text('V A G Ã O // CLIENTE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => _sair(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Área do cliente',
              style: TemaVagao.titulo,
            ),
            const SizedBox(height: 24),
            CardVagao(
              titulo: 'Catálogo',
              subtitulo: 'Ver produtos disponíveis',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TelaCatalogo()),
              ),
            ),
            const SizedBox(height: 16),
            CardVagao(
              titulo: 'Meus pedidos',
              subtitulo: 'Acompanhar pedidos realizados',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TelaMeusPedidos()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
