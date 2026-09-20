import 'package:flutter/material.dart';

import '../servicos/erro_api.dart';
import '../servicos/servico_autenticacao.dart';
import '../tema/tema_vagao.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final ServicoAutenticacao _servico = ServicoAutenticacao();

  bool _carregando = false;
  String? _mensagemErro;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    // Validação local antes de qualquer chamada de rede.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      final usuario = await _servico.entrar(
        _emailController.text.trim(),
        _senhaController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(
        usuario.isAdmin ? '/admin' : '/cliente',
      );
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'V A G Ã O',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: TemaVagao.claro,
                    ),
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    style: const TextStyle(color: TemaVagao.claro),
                    decoration: const InputDecoration(labelText: 'E-MAIL'),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Informe o e-mail.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: true,
                    style: const TextStyle(color: TemaVagao.claro),
                    decoration: const InputDecoration(labelText: 'SENHA'),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Informe a senha.';
                      }
                      return null;
                    },
                  ),
                  if (_mensagemErro != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _mensagemErro!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Container(
                    decoration: const BoxDecoration(
                      boxShadow: TemaVagao.sombraDura,
                    ),
                    child: ElevatedButton(
                      onPressed: _carregando ? null : _entrar,
                      child: _carregando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: TemaVagao.claro,
                              ),
                            )
                          : const Text('ENTRAR'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
