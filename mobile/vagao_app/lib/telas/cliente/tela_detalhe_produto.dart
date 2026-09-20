import 'package:flutter/material.dart';

import '../../modelos/produto.dart';
import '../../servicos/carrinho.dart';
import '../../servicos/erro_api.dart';
import '../../servicos/servico_catalogo.dart';
import '../../tema/tema_vagao.dart';
import '../../utils/formato.dart';
import '../../widgets/painel_erro.dart';
import '../../widgets/thumb_produto.dart';

/// Detalhe de um produto, com formulário de compra (RF25).
/// Busca dado fresco de estoque via GET /api/catalogo/detalhe?id=N — não
/// reaproveita o Produto da lista, para não adicionar ao carrinho com um
/// estoque desatualizado.
class TelaDetalheProduto extends StatefulWidget {
  final int idProduto;

  const TelaDetalheProduto({super.key, required this.idProduto});

  @override
  State<TelaDetalheProduto> createState() => _TelaDetalheProdutoState();
}

class _TelaDetalheProdutoState extends State<TelaDetalheProduto> {
  final ServicoCatalogo _servico = ServicoCatalogo();

  bool _carregando = true;
  String? _mensagemErro;
  Produto? _produto;
  int _quantidade = 1;

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
      final produto = await _servico.buscar(widget.idProduto);
      if (!mounted) return;
      setState(() {
        _produto = produto;
        _quantidade = 1;
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

  void _adicionarAoCarrinho() {
    final produto = _produto;
    if (produto == null) return;

    Carrinho.instancia.adicionar(produto, _quantidade);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${produto.nome} adicionado ao carrinho.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaVagao.preto,
      appBar: AppBar(title: const Text('V A G Ã O // PRODUTO')),
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

    final produto = _produto!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThumbProduto(
            iniciais: produto.iniciais,
            tamanhoFonte: 64,
            imagemUrl: produto.imagemUrl,
          ),
          const SizedBox(height: 24),
          Text(produto.nome, style: TemaVagao.titulo.copyWith(fontSize: 24)),
          const SizedBox(height: 8),
          if (produto.categoria != null)
            Text(produto.categoria!.nome, style: TemaVagao.label),
          const SizedBox(height: 16),
          Text(
            Formato.moeda(produto.preco),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 24,
              color: TemaVagao.claro,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            produto.descricao ?? 'Sem descrição cadastrada.',
            style: const TextStyle(color: TemaVagao.claro, height: 1.5),
          ),
          const SizedBox(height: 24),
          if (produto.disponivel) ...[
            Text(
              'Estoque: ${produto.estoque} unidade(s) disponível(is)',
              style: TemaVagao.label,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: TemaVagao.vermelho),
                  onPressed: _quantidade > 1
                      ? () => setState(() => _quantidade--)
                      : null,
                ),
                Text(
                  '$_quantidade',
                  style: const TextStyle(color: TemaVagao.claro, fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: TemaVagao.vermelho),
                  onPressed: _quantidade < produto.estoque
                      ? () => setState(() => _quantidade++)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: const BoxDecoration(boxShadow: TemaVagao.sombraDura),
              child: ElevatedButton(
                onPressed: _adicionarAoCarrinho,
                child: const Text('ADICIONAR AO CARRINHO'),
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(12),
              color: TemaVagao.painel,
              child: const Text(
                'Produto esgotado',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }
}
