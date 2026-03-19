import 'package:flutter/material.dart';
import 'environment_page.dart';
import 'control_page.dart';
import '../widgets/action_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void openEnvironment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EnvironmentPage()),
    );
  }

  void openControl(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ControlPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Home')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ActionButton(
              label: 'Monitor de Ambiente',
              icon: Icons.thermostat,
              onPressed: () => openEnvironment(context),
            ),
            const SizedBox(height: 16),
            ActionButton(
              label: 'Controle da Casa',
              icon: Icons.home,
              onPressed: () => openControl(context),
            ),
          ],
        ),
      ),
    );
  }
}
