import 'package:flutter/material.dart';

import '../../modelos/resumo_loja.dart';
import '../../servicos/erro_api.dart';
import '../../servicos/servico_admin.dart';
import '../../servicos/servico_autenticacao.dart';
import '../../tema/tema_vagao.dart';
import '../../widgets/card_vagao.dart';
import '../../widgets/painel_erro.dart';
import 'tela_pedidos_admin.dart';

/// Home do perfil admin: mostra o "status geral da loja" (RF20) — contagem
/// de pedidos por status — e dá acesso à lista completa de pedidos.
class TelaHomeAdmin extends StatefulWidget {
  const TelaHomeAdmin({super.key});

  @override
  State<TelaHomeAdmin> createState() => _TelaHomeAdminState();
}

class _TelaHomeAdminState extends State<TelaHomeAdmin> {
  final ServicoAdmin _servico = ServicoAdmin();

  bool _carregando = true;
  String? _mensagemErro;
  ResumoLoja? _resumo;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      final resumo = await _servico.resumo();
      if (!mounted) return;
      setState(() {
        _resumo = resumo;
        _carregando = false;
      });
    } on ErroApi catch (e) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _mensagemErro = e.mensagem;
      });
    }
  }

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
      body: _corpo(),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(color: TemaVagao.vermelho),
      );
    }
    if (_mensagemErro != null) {
      return PainelErro(mensagem: _mensagemErro!, onTentarNovamente: _carregar);
    }

    final resumo = _resumo!;

    return RefreshIndicator(
      onRefresh: _carregar,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status geral da loja', style: TemaVagao.titulo),
            const SizedBox(height: 8),
            Text(
              '${resumo.totalPedidos} pedido(s) no total',
              style: TemaVagao.label,
            ),
            const SizedBox(height: 24),
            for (final entrada in resumo.porStatus.entries) ...[
              CardVagao(
                titulo: entrada.key,
                subtitulo: '${entrada.value} pedido(s)',
              ),
              const SizedBox(height: 16),
            ],
            CardVagao(
              titulo: 'Todos os pedidos',
              subtitulo: 'Consultar pedidos recebidos',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TelaPedidosAdmin()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
