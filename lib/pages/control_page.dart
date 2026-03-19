import 'package:flutter/material.dart';
import '../widgets/action_button.dart';

class ControlPage extends StatelessWidget {
  const ControlPage({super.key});

  // 🔹 Funções vazias
  void turnLightOn() {}
  void turnLightOff() {}
  void turnFanOn() {}
  void turnFanOff() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controle da Casa')),
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
              'Ventilador',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ActionButton(
              label: 'Ligar Ventilador',
              icon: Icons.toys,
              onPressed: turnFanOn,
            ),

            const SizedBox(height: 10),

            ActionButton(
              label: 'Desligar Ventilador',
              icon: Icons.toys_outlined,
              onPressed: turnFanOff,
            ),
          ],
        ),
      ),
    );
  }
}
