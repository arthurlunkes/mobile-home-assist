import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';

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
    await _controller.forceRefresh();
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
                Icon(
                  _controller.deviceConfig.connected ? Icons.wifi : Icons.wifi_off,
                  color: _controller.deviceConfig.connected ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _controller.deviceConfig.connected ? 'Conectado ao dispositivo' : 'Dispositivo Desconectado',
                  style: TextStyle(
                    color: _controller.deviceConfig.connected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                    value: _controller.formatarValor(state.luminosity, '%'),
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
            const SizedBox(height: 16),
            ActionButton(
              label: 'Atualizar Localização',
              icon: Icons.my_location,
              onPressed: _controller.buscandoLocalizacao 
                  ? () {} 
                  : () async {
                      final sucesso = await _controller.atualizarLocalizacaoAtual();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(sucesso
                                ? 'Localização salva com sucesso'
                                : 'Erro ao buscar localização'),
                          ),
                        );
                      }
                    },
            ),
            if (_controller.buscandoLocalizacao) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 24),
            ] else if (_controller.deviceConfig.hasLocation) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    key: ValueKey(
                      'mini-map-home-${_controller.deviceConfig.latitude}-${_controller.deviceConfig.longitude}',
                    ),
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_controller.deviceConfig.latitude!, _controller.deviceConfig.longitude!),
                      zoom: 16,
                    ),
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    markers: {
                      Marker(
                        markerId: const MarkerId('device-location-home'),
                        position: LatLng(_controller.deviceConfig.latitude!, _controller.deviceConfig.longitude!),
                      ),
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => MapsLauncher.launchCoordinates(
                    _controller.deviceConfig.latitude!, 
                    _controller.deviceConfig.longitude!,
                  ),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Abrir no Maps'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
