import 'package:flutter/material.dart';

import '../servicos/erro_api.dart';
import '../servicos/servico_autenticacao.dart';
import '../tema/tema_vagao.dart';

/// Tela inicial do app. Verifica se já existe uma sessão válida (cookie
/// persistido em disco) e decide para onde navegar, sem exigir login de
/// novo a cada abertura enquanto a sessão continuar viva no servidor.
class TelaCarregamento extends StatefulWidget {
  const TelaCarregamento({super.key});

  @override
  State<TelaCarregamento> createState() => _TelaCarregamentoState();
}

class _TelaCarregamentoState extends State<TelaCarregamento> {
  final ServicoAutenticacao _servico = ServicoAutenticacao();
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _verificarSessao();
  }

  Future<void> _verificarSessao() async {
    setState(() => _mensagemErro = null);

    try {
      final usuario = await _servico.sessaoAtual();

      if (!mounted) return;

      if (usuario == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      Navigator.of(context).pushReplacementNamed(
        usuario.isAdmin ? '/admin' : '/cliente',
      );
    } on ErroApi catch (e) {
      if (!mounted) return;
      setState(() => _mensagemErro = e.mensagem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaVagao.preto,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'V A G Ã O',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                  color: TemaVagao.claro,
                ),
              ),
              const SizedBox(height: 32),
              if (_mensagemErro == null) ...[
                const CircularProgressIndicator(color: TemaVagao.vermelho),
              ] else ...[
                Text(
                  _mensagemErro!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: TemaVagao.claro),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _verificarSessao,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
