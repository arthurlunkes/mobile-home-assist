import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';

import '../controllers/config_controller.dart';
import '../model/provision_result.dart';
import '../services/wifi_scanner_service.dart';
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

  Future<void> connectDevice() async {
    bool step1Done = false;
    bool loadingNetworks = false;
    bool provisioning = false;
    List<WifiNetwork> networks = [];
    String? selectedSsid;
    bool isManualSsid = false;
    final ssidManualController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (!step1Done) {
              return AlertDialog(
                title: const Text('Conectar dispositivo'),
                content: const Text(
                  'Conecte seu celular na rede WiFi ESP32-SETUP-ARTHUR e retorne ao aplicativo.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setDialogState(() {
                        step1Done = true;
                        loadingNetworks = true;
                      });
                      
                      try {
                        final scanner = WifiScannerService();
                        final list = await scanner.scanNetworks();
                        
                        if (context.mounted) {
                          setDialogState(() {
                            networks = list;
                            loadingNetworks = false;
                            if (networks.isEmpty) {
                              isManualSsid = true;
                            }
                          });
                        }
                      } catch (e) {
                        if (context.mounted) {
                          setDialogState(() {
                            loadingNetworks = false;
                            isManualSsid = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao escanear WiFi: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Já conectei'),
                  ),
                ],
              );
            }

            if (loadingNetworks) {
              return const AlertDialog(
                title: Text('Buscando redes...'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(child: CircularProgressIndicator()),
                    SizedBox(height: 16),
                    Text('Aguarde, escaneando redes WiFi...'),
                  ],
                ),
              );
            }

            if (provisioning) {
              return const AlertDialog(
                title: Text('Enviando credenciais...'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(child: CircularProgressIndicator()),
                    SizedBox(height: 16),
                    Text('Aguarde, enviando para o ESP32...'),
                  ],
                ),
              );
            }

            return AlertDialog(
              title: const Text('Configurar WiFi'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isManualSsid)
                      TextFormField(
                        controller: ssidManualController,
                        decoration: const InputDecoration(
                          labelText: 'Rede WiFi (SSID)',
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o SSID';
                          }
                          return null;
                        },
                      )
                    else
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: selectedSsid,
                        decoration: const InputDecoration(labelText: 'Rede WiFi (SSID)'),
                        items: networks.map((net) {
                          return DropdownMenuItem(
                            value: net.ssid, 
                            child: Text(
                              '${net.ssid} (${net.rssi} dBm)',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedSsid = val;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecione a rede WiFi';
                          }
                          return null;
                        },
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setDialogState(() {
                            isManualSsid = !isManualSsid;
                          });
                        },
                        child: Text(
                          isManualSsid
                              ? 'Selecionar da lista'
                              : 'Digitar rede manualmente',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Senha da rede WiFi',
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a senha';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: provisioning ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: provisioning ? null : () async {
                    if (formKey.currentState?.validate() != true) {
                      return;
                    }
                    
                    final ssid = isManualSsid ? ssidManualController.text.trim() : selectedSsid;
                    if (ssid == null || ssid.isEmpty) return;

                    setDialogState(() {
                      provisioning = true;
                    });
                    
                    final password = passwordController.text;

                    final result = await _controller.provisionDevice(
                      ssid: ssid,
                      password: password,
                    );
                    
                    if (context.mounted) {
                      Navigator.of(context).pop(result);
                    }
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == null || confirmed is! ProvisionResult) return;
    
    if (!mounted) return;

    final ProvisionResult result = confirmed;

    if (result.success) {
      final macMsg = result.macAddress != null
          ? '\nMAC do dispositivo: ${result.macAddress}'
          : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.message}$macMsg'),
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Erro desconhecido'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _testarConexao() async {
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

  Future<void> _atualizarLocalizacao() async {
    final sucesso = await _controller.atualizarLocalizacaoAtual();
    if (!mounted) {
      return;
    }

    final mensagem = sucesso
        ? 'Localização atual salva com sucesso'
        : (_controller.erroLocalizacao ??
              'Não foi possível atualizar localização');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  String _formatCoord(double value) {
    return value.toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    final config = _controller.config;
    final status = config.isConnected ? 'Conectado' : 'Desconectado';
    final hasLocation = config.hasLocation;
    final lat = config.latitude;
    final lng = config.longitude;
    final locationText = hasLocation
        ? '${_formatCoord(lat!)} / ${_formatCoord(lng!)}'
        : '--';

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: SingleChildScrollView(
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
                    Text(
                      'Hostname: ${config.hostname.isEmpty ? '--' : config.hostname}',
                    ),
                    const SizedBox(height: 6),
                    Text('Porta: ${config.port > 0 ? config.port : '--'}'),
                    const SizedBox(height: 6),
                    Text('Localização: $locationText'),
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
              onPressed: connectDevice,
            ),
            const SizedBox(height: 12),
            ActionButton(
              label: 'Testar conexão',
              icon: Icons.network_check,
              onPressed: _controller.carregando ? () {} : _testarConexao,
            ),
            const SizedBox(height: 12),
            ActionButton(
              label: _controller.buscandoLocalizacao ? 'Buscando Localização...' : 'Localização atual',
              icon: Icons.my_location,
              onPressed: _controller.buscandoLocalizacao ? () {} : _atualizarLocalizacao,
            ),
            if (_controller.buscandoLocalizacao) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 24),
            ] else if (hasLocation) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    key: ValueKey(
                      'mini-map-${_formatCoord(lat!)}-${_formatCoord(lng!)}',
                    ),
                    initialCameraPosition: CameraPosition(
                      target: LatLng(lat, lng),
                      zoom: 16,
                    ),
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    markers: {
                      Marker(
                        markerId: const MarkerId('device-location'),
                        position: LatLng(lat, lng),
                      ),
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => MapsLauncher.launchCoordinates(lat, lng),
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
