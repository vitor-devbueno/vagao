import 'package:flutter/material.dart';

import '../../modelos/pedido.dart';
import '../../servicos/erro_api.dart';
import '../../servicos/servico_pedidos.dart';
import '../../tema/tema_vagao.dart';
import '../../utils/formato.dart';
import '../../widgets/card_vagao.dart';
import '../../widgets/painel_erro.dart';
import 'tela_detalhe_pedido.dart';

/// Lista dos pedidos do cliente logado, vinda de GET /api/pedidos (RF19).
class TelaMeusPedidos extends StatefulWidget {
  const TelaMeusPedidos({super.key});

  @override
  State<TelaMeusPedidos> createState() => _TelaMeusPedidosState();
}

class _TelaMeusPedidosState extends State<TelaMeusPedidos> {
  final ServicoPedidos _servico = ServicoPedidos();

  bool _carregando = true;
  String? _mensagemErro;
  List<Pedido> _pedidos = [];

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
      final pedidos = await _servico.meusPedidos();
      if (!mounted) return;
      setState(() {
        _pedidos = pedidos;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaVagao.preto,
      appBar: AppBar(title: const Text('V A G Ã O // MEUS PEDIDOS')),
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
    if (_pedidos.isEmpty) {
      return const Center(
        child: Text(
          'Você ainda não fez nenhum pedido.',
          style: TextStyle(color: TemaVagao.claro),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _pedidos.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _cardPedido(_pedidos[index]),
      ),
    );
  }

  Widget _cardPedido(Pedido pedido) {
    return CardVagao(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TelaDetalhePedido(idPedido: pedido.idPedido),
        ),
      ),
      titulo: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PEDIDO #${pedido.idPedido}',
            style: const TextStyle(
              color: TemaVagao.claro,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(Formato.dataHora(pedido.dataPedido), style: TemaVagao.label),
          const SizedBox(height: 4),
          Text(
            '${Formato.moeda(pedido.total)}  •  ${pedido.status.toUpperCase()}',
            style: const TextStyle(fontFamily: 'monospace', color: TemaVagao.claro),
          ),
        ],
      ),
    );
  }
}
