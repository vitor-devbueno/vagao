import 'package:flutter/material.dart';

import '../../modelos/pedido.dart';
import '../../servicos/erro_api.dart';
import '../../servicos/servico_admin.dart';
import '../../tema/tema_vagao.dart';
import '../../utils/formato.dart';
import '../../widgets/painel_erro.dart';

/// Detalhe de um pedido para o administrador: mesmos itens da tela do
/// cliente, mais os dados do comprador. Não altera status — isso é RF11,
/// exclusivo da aplicação Web.
class TelaDetalhePedidoAdmin extends StatefulWidget {
  final int idPedido;

  const TelaDetalhePedidoAdmin({super.key, required this.idPedido});

  @override
  State<TelaDetalhePedidoAdmin> createState() => _TelaDetalhePedidoAdminState();
}

class _TelaDetalhePedidoAdminState extends State<TelaDetalhePedidoAdmin> {
  final ServicoAdmin _servico = ServicoAdmin();

  bool _carregando = true;
  String? _mensagemErro;
  Pedido? _pedido;

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
      final pedido = await _servico.buscarPedido(widget.idPedido);
      if (!mounted) return;
      setState(() {
        _pedido = pedido;
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
      appBar: AppBar(title: const Text('V A G Ã O // PEDIDO')),
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

    final pedido = _pedido!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pedido #${pedido.idPedido}', style: TemaVagao.titulo.copyWith(fontSize: 22)),
          const SizedBox(height: 8),
          Text(Formato.dataHora(pedido.dataPedido), style: TemaVagao.label),
          const SizedBox(height: 4),
          Text('Status: ${pedido.status}', style: TemaVagao.label),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: TemaVagao.painel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pedido.nomeCliente ?? '', style: const TextStyle(color: TemaVagao.claro)),
                Text(pedido.emailCliente ?? '', style: TemaVagao.label),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: TemaVagao.painel,
              border: Border.all(color: TemaVagao.vermelho, width: 2),
              boxShadow: TemaVagao.sombraDura,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in pedido.itens) ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.nomeProduto,
                          style: const TextStyle(color: TemaVagao.claro),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'x${item.quantidade}',
                          textAlign: TextAlign.center,
                          style: TemaVagao.label,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          Formato.moeda(item.subtotal),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: TemaVagao.claro,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Total: ${Formato.moeda(pedido.total)}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: TemaVagao.claro,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            color: TemaVagao.painel,
            child: const Text(
              'Alteração de status disponível no sistema Web.',
              style: TemaVagao.label,
            ),
          ),
        ],
      ),
    );
  }
}
