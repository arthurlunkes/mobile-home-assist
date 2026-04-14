import 'package:flutter/material.dart';

import '../controllers/config_controller.dart';
import '../widgets/action_button.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final _controller = ConfigController();

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

  Future<void> connectDevice(BuildContext context) async {
    final ipController = TextEditingController(text: _controller.config.ip);
    final portController = TextEditingController(
      text: _controller.config.port > 0
          ? _controller.config.port.toString()
          : '',
    );
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Conectar dispositivo'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: ipController,
                  decoration: const InputDecoration(labelText: 'Endereço IP'),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o IP';
                    }
                    return null;
                  },
                ),
                // Espaçamento entre os campos
                const SizedBox(height: 16),
                TextFormField(
                  controller: portController,
                  decoration: const InputDecoration(labelText: 'Porta'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final port = int.tryParse(value ?? '');
                    if (port == null || port <= 0) {
                      return 'Informe uma porta válida';
                    }
                    return null;
                  },
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
                if (formKey.currentState?.validate() != true) {
                  return;
                }
                Navigator.of(context).pop({
                  'ip': ipController.text.trim(),
                  'port': portController.text.trim(),
                });
              },
              child: const Text('Conectar'),
            ),
          ],
        );
      },
    );
    if (result == null) {
      return;
    }

    final ip = result['ip'] ?? '';
    final port = int.tryParse(result['port'] ?? '') ?? 0;

    final sucesso = await _controller.salvar(ip: ip, port: port);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso
              ? 'Dispositivo salvo com sucesso'
              : 'Erro ao salvar dispositivo',
        ),
      ),
    );
  }

  Future<void> _testarConexao(BuildContext context) async {
    final sucesso = await _controller.testarConexao();
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso
              ? 'Conexão com dispositivo estabelecida'
              : 'Não foi possível conectar ao dispositivo',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _controller.config;
    final status = config.isConnected ? 'Conectado' : 'Desconectado';

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dispositivo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Status: $status'),
                    const SizedBox(height: 10),
                    Text('IP: ${config.ip.isEmpty ? '--' : config.ip}'),
                    const SizedBox(height: 6),
                    Text('Porta: ${config.port > 0 ? config.port : '--'}'),
                    if (config.isConnected) ...[
                      const SizedBox(height: 6),
                      Text(
                        'MAC Address: ${config.macAddress?.isNotEmpty == true ? config.macAddress : 'Indisponível'}',
                      ),
                    ],
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
            const SizedBox(height: 12),
            ActionButton(
              label: 'Testar conexão',
              icon: Icons.network_check,
              onPressed: _controller.carregando
                  ? () {}
                  : () => _testarConexao(context),
            ),
          ],
        ),
      ),
    );
  }
}
