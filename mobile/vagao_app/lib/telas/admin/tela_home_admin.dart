import 'package:flutter/material.dart';

import '../../servicos/servico_autenticacao.dart';
import '../../tema/tema_vagao.dart';

/// Home estática do perfil admin. Sem dados reais e sem chamadas à API
/// de catálogo/pedidos — isso é Semana 6. Aqui só se prova a navegação
/// por perfil (RF16).
class TelaHomeAdmin extends StatelessWidget {
  const TelaHomeAdmin({super.key});

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
        title: const Text('V A G Ã O // ADMIN'),
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
              'Área administrativa',
              style: TemaVagao.titulo,
            ),
            const SizedBox(height: 24),
            const _CardEstatico(titulo: 'Produtos'),
            const SizedBox(height: 16),
            const _CardEstatico(titulo: 'Categorias'),
            const SizedBox(height: 16),
            const _CardEstatico(titulo: 'Pedidos'),
          ],
        ),
      ),
    );
  }
}

class _CardEstatico extends StatelessWidget {
  final String titulo;

  const _CardEstatico({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TemaVagao.painel,
        border: Border.all(color: TemaVagao.vermelho, width: 2),
        boxShadow: TemaVagao.sombraDura,
      ),
      child: Column(
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
          const SizedBox(height: 8),
          const Text(
            'Disponível na próxima entrega',
            style: TemaVagao.label,
          ),
        ],
      ),
    );
  }
}
