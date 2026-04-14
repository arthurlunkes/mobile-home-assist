import 'package:flutter/material.dart';

import '../controllers/home_controller.dart';
import '../widgets/action_button.dart';
import '../widgets/metric_card.dart';
import 'config_page.dart';
import 'control_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = HomeController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.carregar();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshInfo() async {
    await _controller.carregar();
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Assist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshInfo),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ConfigPage()));
              if (!mounted) {
                return;
              }
              await _refreshInfo();
            },
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
                    value: _controller.formatarValor(state.temperature, '°C'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MetricCard(
                    title: 'Umidade',
                    value: _controller.formatarValor(state.humidity, '%'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MetricCard(
                    title: 'Luminosidade',
                    value: _controller.formatarValor(state.luminosity, 'lx'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ActionButton(
              label: 'Controle da Casa',
              icon: Icons.home,
              onPressed: () async {
                await Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ControlPage()));
                if (!mounted) {
                  return;
                }
                await _refreshInfo();
              },
            ),
          ],
        ),
      ),
    );
  }
}
