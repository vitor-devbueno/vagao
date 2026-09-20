import 'package:flutter/material.dart';

import '../../modelos/produto.dart';
import '../../servicos/carrinho.dart';
import '../../servicos/erro_api.dart';
import '../../servicos/servico_catalogo.dart';
import '../../tema/tema_vagao.dart';
import '../../utils/formato.dart';
import '../../widgets/painel_erro.dart';
import '../../widgets/thumb_produto.dart';
import 'tela_carrinho.dart';
import 'tela_detalhe_produto.dart';

/// Catálogo de produtos disponíveis, vindo de GET /api/catalogo (RF17).
class TelaCatalogo extends StatefulWidget {
  const TelaCatalogo({super.key});

  @override
  State<TelaCatalogo> createState() => _TelaCatalogoState();
}

class _TelaCatalogoState extends State<TelaCatalogo> {
  final ServicoCatalogo _servico = ServicoCatalogo();

  bool _carregando = true;
  String? _mensagemErro;
  List<Produto> _produtos = [];

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
      final produtos = await _servico.listar();
      if (!mounted) return;
      setState(() {
        _produtos = produtos;
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
      appBar: AppBar(
        title: const Text('V A G Ã O // CATÁLOGO'),
        actions: [
          ListenableBuilder(
            listenable: Carrinho.instancia,
            builder: (context, _) {
              final quantidade = Carrinho.instancia.totalItens;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    tooltip: 'Carrinho',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TelaCarrinho()),
                    ),
                  ),
                  if (quantidade > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: TemaVagao.preto,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$quantidade',
                          style: const TextStyle(
                            color: TemaVagao.claro,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
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
    if (_produtos.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum produto disponível no momento.',
          style: TextStyle(color: TemaVagao.claro),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregar,
      child: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 24,
          crossAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemCount: _produtos.length,
        itemBuilder: (context, index) => _cardProduto(_produtos[index]),
      ),
    );
  }

  Widget _cardProduto(Produto produto) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TelaDetalheProduto(idProduto: produto.idProduto),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: TemaVagao.painel,
          border: Border.all(color: TemaVagao.vermelho, width: 3),
          boxShadow: TemaVagao.sombraDura,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Expanded (em vez do quadrado 1:1 direto) absorve o espaço
            // sobrando depois do bloco de texto abaixo, que tem altura
            // variável (nome pode quebrar em 2 linhas) — evita overflow
            // no grid, cujas células têm altura fixa (childAspectRatio).
            Expanded(child: ThumbProduto(iniciais: produto.iniciais)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    produto.nome.toUpperCase(),
                    style: const TextStyle(
                      color: TemaVagao.claro,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (produto.categoria != null)
                    Text(produto.categoria!.nome, style: TemaVagao.label),
                  const SizedBox(height: 4),
                  Text(
                    Formato.moeda(produto.preco),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: TemaVagao.claro,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
