import 'package:flutter/material.dart';

import '../widgets/action_button.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  Future<void> connectDevice(BuildContext context) async {

    final result = await showDialog<Map<String, String?>>(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('Conectar dispositivo'),
        content: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Endereço IP'),
                keyboardType: TextInputType.text,
              ),
              // Espaçamento entre os campos
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Porta'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Conectar'),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dispositivo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Status: Desconectado'),
                    SizedBox(height: 10),
                    Text('MAC Address: --'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ActionButton(
              label: 'Conectar Dispositivo',
              icon: Icons.wifi,
              onPressed: () => connectDevice(context),
            ),
          ],
        ),
      ),
    );
  }
}
