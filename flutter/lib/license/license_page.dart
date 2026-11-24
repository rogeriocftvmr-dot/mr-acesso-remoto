import 'package:flutter/material.dart';

import '../common.dart';
import 'mr_license.dart';

/// MR Acesso Remoto: tela da chave de licença — a PRIMEIRA tela do
/// programa (antes do seletor Técnico/Cliente), para o técnico.
/// O cliente entra pelo link "Sou cliente", sem chave.
class MrLicensePage extends StatefulWidget {
  final Mr onActivated;
  final VoidCallback onClient;

  const MrLicensePage({
    Key? key,
    required this.onActivated,
    required this.onClient,
  }) : super(key: key);

  @override
  State<MrLicensePage> createState() => _MrLicensePageState();
}

class _MrLicensePageState extends State<MrLicensePage> {
  final _keyController = TextEditingController();
  final _emailController = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _keyController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _errorText(String reason) {
    switch (reason) {
      case 'trial':
        return 'Essa chave é de teste e não libera o MR Acesso Remoto.';
      case 'sem_produto':
        return 'Essa chave não tem o MR Acesso Remoto liberado.';
      case 'expirada':
        return 'Chave expirada.';
      case 'sem_ligacao':
        return 'Sem ligação com o servidor. Tenta de novo.';
      default:
        return 'Chave inválida.';
    }
  }

  Future<void> _activate() async {
    final chave = _keyController.text.trim();
    if (chave.isEmpty) {
      setState(() => _error = 'Digita a chave de licença.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await LicenseService.verify(
      chave,
      email: _emailController.text,
    );
    if (!mounted) return;
    if (result.allowed && result.expiraEm != null) {
      await LicenseService.save(chave, result.expiraEm!);
      widget.onActivated();
      return;
    }
    setState(() {
      _busy = false;
      _error = _errorText(result.reason);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/icon.png',
                        height: 96,
                        width: 96,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'MR Acesso Remoto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFC9A227),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Digita a chave de licença para liberar o programa.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _keyController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Chave de licença',
                        hintText: 'MR-XXXX-XXXX-XXXX',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _activate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _activate(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC9A227),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: _busy ? null : _activate,
                        child: _busy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                'ATIVAR',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _busy ? null : widget.onClient,
                      child: const Text('Sou cliente'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Planos: 7 dias 14,90 - 15 dias 19,90 - 30 dias 29,90 - 60 dias 39,90 - 1 ano 79,90',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
