import 'package:flutter/material.dart';

import '../widgets/action_button.dart';

class ControlPage extends StatelessWidget {
  const ControlPage({super.key});

  void turnLightOn() {}
  void turnLightOff() {}
  void openGate() {}
  void closeGate() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle da Casa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Luz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ActionButton(
              label: 'Ligar Luz',
              icon: Icons.lightbulb,
              onPressed: turnLightOn,
            ),

            const SizedBox(height: 10),

            ActionButton(
              label: 'Desligar Luz',
              icon: Icons.lightbulb_outline,
              onPressed: turnLightOff,
            ),

            const SizedBox(height: 20),

            const Text(
              'Portão',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ActionButton(
              label: 'Abrir Portão',
              icon: Icons.door_front_door,
              onPressed: openGate,
            ),

            const SizedBox(height: 10),

            ActionButton(
              label: 'Fechar Portão',
              icon: Icons.door_back_door,
              onPressed: closeGate,
            ),
          ],
        ),
      ),
    );
  }
}
