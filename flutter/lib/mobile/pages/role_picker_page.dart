import 'package:flutter/material.dart';

import '../../common.dart';
import '../../models/platform_model.dart';

/// MR Acesso Remoto: tela de escolha do papel na primeira abertura.
/// Mostrada quando a opção 'mr-role' ainda está vazia.
/// O papel é guardado em 'mr-role' ('technician' ou 'client') e pode ser
/// trocado depois em Configurações.
class RolePickerPage extends StatelessWidget {
  final VoidCallback onPicked;

  const RolePickerPage({Key? key, required this.onPicked}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/icon.png',
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'MR Acesso Remoto',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFC9A227),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Como você vai usar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await bind.mainSetOption(key: 'mr-role', value: 'technician');
                  onPicked();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    children: const [
                      Text(
                        'SOU TÉCNICO',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Vou controlar outros aparelhos',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await bind.mainSetOption(key: 'mr-role', value: 'client');
                  onPicked();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    children: const [
                      Text(
                        'SOU CLIENTE',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Vou deixar o técnico me ajudar',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Você pode trocar depois em Configurações.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
