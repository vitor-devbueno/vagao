import 'package:flutter/material.dart';

import '../tema/tema_vagao.dart';

/// Placeholder visual de produto: iniciais do nome sobre um bloco vermelho
/// quadrado — cópia literal do `.thumb` da Web. Não há coluna de imagem no
/// banco (decisão E9).
class ThumbProduto extends StatelessWidget {
  final String iniciais;
  final double tamanhoFonte;

  const ThumbProduto({
    super.key,
    required this.iniciais,
    this.tamanhoFonte = 40,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: TemaVagao.vermelho,
        alignment: Alignment.center,
        child: Text(
          iniciais,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: tamanhoFonte,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            color: TemaVagao.preto,
          ),
        ),
      ),
    );
  }
}
