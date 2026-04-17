import 'package:flutter/material.dart';

import '../controllers/control_controller.dart';
import '../widgets/action_button.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  final _controller = ControlController();

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

  Future<void> _turnLightOn() async {
    await _controller.setLuz(true);
  }

  Future<void> _turnLightOff() async {
    await _controller.setLuz(false);
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return Scaffold(
      appBar: AppBar(title: const Text('Controle da Casa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Luz: ${state.lightOn ? 'Ligada' : 'Desligada'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Luz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ActionButton(
              label: state.lightOn ? 'Desligar Luz' : 'Ligar Luz',
              icon: state.lightOn ? Icons.lightbulb_outline : Icons.lightbulb,
              onPressed: state.lightOn ? _turnLightOff : _turnLightOn,
            ),
          ],
        ),
      ),
    );
  }
}
