import 'package:flutter/material.dart';

import '../../modelos/item_carrinho.dart';
import '../../servicos/carrinho.dart';
import '../../servicos/erro_api.dart';
import '../../servicos/servico_pedidos.dart';
import '../../tema/tema_vagao.dart';
import '../../utils/formato.dart';
import 'tela_detalhe_pedido.dart';

/// Carrinho de compras (RF18). Ao finalizar, envia POST /api/pedidos/novo com
/// todos os itens; em caso de estoque insuficiente (ErroEstoque), mantém o
/// carrinho intacto e convida o usuário a reduzir a quantidade.
class TelaCarrinho extends StatefulWidget {
  const TelaCarrinho({super.key});

  @override
  State<TelaCarrinho> createState() => _TelaCarrinhoState();
}

class _TelaCarrinhoState extends State<TelaCarrinho> {
  final ServicoPedidos _servico = ServicoPedidos();

  bool _enviando = false;
  String? _mensagemErro;

  Future<void> _finalizar() async {
    setState(() {
      _enviando = true;
      _mensagemErro = null;
    });

    try {
      final idPedido = await _servico.realizar(Carrinho.instancia.itens);

      if (!mounted) return;

      Carrinho.instancia.limpar();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TelaDetalhePedido(idPedido: idPedido)),
      );
    } on ErroApi catch (e) {
      // Tanto ErroEstoque quanto falha de rede caem aqui — em ambos os casos
      // o carrinho permanece intacto, para o usuário poder tentar de novo.
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _mensagemErro = e.mensagem;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaVagao.preto,
      appBar: AppBar(title: const Text('V A G Ã O // CARRINHO')),
      body: ListenableBuilder(
        listenable: Carrinho.instancia,
        builder: (context, _) => _corpo(),
      ),
    );
  }

  Widget _corpo() {
    final carrinho = Carrinho.instancia;

    if (carrinho.vazio) {
      return const Center(
        child: Text(
          'Seu carrinho está vazio.',
          style: TextStyle(color: TemaVagao.claro),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: carrinho.itens.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _linhaItem(carrinho.itens[index]),
          ),
        ),
        if (_mensagemErro != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _mensagemErro!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Total: ${Formato.moeda(carrinho.valorTotal)}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TemaVagao.claro,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: const BoxDecoration(boxShadow: TemaVagao.sombraDura),
                child: ElevatedButton(
                  onPressed: _enviando ? null : _finalizar,
                  child: _enviando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: TemaVagao.claro,
                          ),
                        )
                      : const Text('FINALIZAR PEDIDO'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _linhaItem(ItemCarrinho item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TemaVagao.painel,
        border: Border.all(color: TemaVagao.vermelho, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.produto.nome,
                  style: const TextStyle(color: TemaVagao.claro, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(Formato.moeda(item.produto.preco), style: TemaVagao.label),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: TemaVagao.vermelho),
            onPressed: () => Carrinho.instancia.alterarQuantidade(
              item.produto.idProduto,
              item.quantidade - 1,
            ),
          ),
          Text('${item.quantidade}', style: const TextStyle(color: TemaVagao.claro)),
          IconButton(
            icon: const Icon(Icons.add_circle, color: TemaVagao.vermelho),
            onPressed: item.quantidade < item.produto.estoque
                ? () => Carrinho.instancia.alterarQuantidade(
                      item.produto.idProduto,
                      item.quantidade + 1,
                    )
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => Carrinho.instancia.remover(item.produto.idProduto),
          ),
        ],
      ),
    );
  }
}
