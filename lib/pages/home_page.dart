import 'package:flutter/material.dart';

import '../widgets/action_button.dart';
import '../widgets/metric_card.dart';
import 'config_page.dart';
import 'control_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void refreshInfo() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Assist', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshInfo,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ConfigPage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Temperatura',
                    value: '-- °C',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MetricCard(
                    title: 'Umidade',
                    value: '-- %',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MetricCard(
                    title: 'Luminosidade',
                    value: '-- lx',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ActionButton(
              label: 'Controle da Casa',
              icon: Icons.home,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ControlPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
