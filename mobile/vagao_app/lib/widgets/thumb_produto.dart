import 'package:flutter/material.dart';

import '../config/ambiente.dart';
import '../tema/tema_vagao.dart';

/// Foto do produto quando cadastrada, com fallback duplo para o placeholder
/// de iniciais: URL nula (produto sem foto) ou falha de carregamento (rede
/// instável, imagem removida etc.) — cópia visual do `.thumb` da Web.
class ThumbProduto extends StatelessWidget {
  final String iniciais;
  final double tamanhoFonte;
  final String? imagemUrl;

  const ThumbProduto({
    super.key,
    required this.iniciais,
    this.tamanhoFonte = 40,
    this.imagemUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Wrapper externo (AspectRatio) inalterado de propósito: o catálogo usa
    // um GridView com childAspectRatio fixo e já teve bug de overflow aqui
    // — só o filho muda entre placeholder e imagem real.
    return AspectRatio(
      aspectRatio: 1,
      child: imagemUrl == null ? _placeholder() : _imagem(imagemUrl!),
    );
  }

  Widget _imagem(String url) {
    return Image.network(
      '${Ambiente.baseUrl}$url',
      fit: BoxFit.cover,
      cacheWidth: 600,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _placeholder();
      },
    );
  }

  Widget _placeholder() {
    return Container(
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
    );
  }
}
