import 'package:flutter/material.dart';

import '../tema/tema_vagao.dart';

/// Estado de erro de rede reutilizável — extrai o padrão já usado em
/// tela_carregamento.dart (mensagem + botão "Tentar novamente") para todas
/// as telas de lista da Semana 6.
class PainelErro extends StatelessWidget {
  final String mensagem;
  final VoidCallback onTentarNovamente;

  const PainelErro({
    super.key,
    required this.mensagem,
    required this.onTentarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(color: TemaVagao.claro),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onTentarNovamente,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
