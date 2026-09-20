import 'package:flutter/material.dart';

import '../../modelos/pedido.dart';
import '../../servicos/erro_api.dart';
import '../../servicos/servico_admin.dart';
import '../../tema/tema_vagao.dart';
import '../../utils/formato.dart';
import '../../widgets/card_vagao.dart';
import '../../widgets/painel_erro.dart';
import 'tela_detalhe_pedido_admin.dart';

/// Lista de todos os pedidos recebidos, vinda de GET /api/admin/pedidos (RF20).
class TelaPedidosAdmin extends StatefulWidget {
  const TelaPedidosAdmin({super.key});

  @override
  State<TelaPedidosAdmin> createState() => _TelaPedidosAdminState();
}

class _TelaPedidosAdminState extends State<TelaPedidosAdmin> {
  final ServicoAdmin _servico = ServicoAdmin();

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
      final pedidos = await _servico.listarPedidos();
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
      appBar: AppBar(title: const Text('V A G Ã O // PEDIDOS')),
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
        child: Text('Nenhum pedido registrado.', style: TextStyle(color: TemaVagao.claro)),
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
      titulo: '',
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TelaDetalhePedidoAdmin(idPedido: pedido.idPedido),
        ),
      ),
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
          Text(pedido.nomeCliente ?? '', style: const TextStyle(color: TemaVagao.claro)),
          Text(pedido.emailCliente ?? '', style: TemaVagao.label),
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
