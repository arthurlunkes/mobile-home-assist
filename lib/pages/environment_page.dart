import 'package:flutter/material.dart';
import '../widgets/action_button.dart';

class EnvironmentPage extends StatelessWidget {
  const EnvironmentPage({super.key});

  // 🔹 Funções vazias
  void refreshData() {}
  void connectDevice() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitor de Ambiente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoCard('Temperatura', '-- °C'),
            _infoCard('Umidade', '-- %'),
            _infoCard('Luminosidade', '-- lx'),

            const SizedBox(height: 20),

            ActionButton(
              label: 'Atualizar Dados',
              icon: Icons.refresh,
              onPressed: refreshData,
            ),

            const SizedBox(height: 10),

            ActionButton(
              label: 'Conectar Dispositivo',
              icon: Icons.wifi,
              onPressed: connectDevice,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(value),
      ),
    );
  }
}