import 'package:flutter/material.dart';

import '../tema/tema_vagao.dart';

/// Card canônico da identidade VAGÃO: painel escuro, borda vermelha e sombra
/// dura. Promovido do `_CardEstatico` que existia duplicado, byte a byte,
/// em tela_home_admin.dart e tela_home_cliente.dart.
class CardVagao extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final VoidCallback? onTap;
  final Widget? child;

  const CardVagao({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final conteudo = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TemaVagao.painel,
        border: Border.all(color: TemaVagao.vermelho, width: 2),
        boxShadow: TemaVagao.sombraDura,
      ),
      child: child ??
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo.toUpperCase(),
                style: const TextStyle(
                  color: TemaVagao.claro,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              if (subtitulo != null) ...[
                const SizedBox(height: 8),
                Text(subtitulo!, style: TemaVagao.label),
              ],
            ],
          ),
    );

    if (onTap == null) return conteudo;

    return InkWell(onTap: onTap, child: conteudo);
  }
}
