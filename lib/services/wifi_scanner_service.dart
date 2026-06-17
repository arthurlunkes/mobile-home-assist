import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiNetwork {
  final String ssid;
  final int rssi;

  WifiNetwork({required this.ssid, required this.rssi});
}

class WifiScannerService {
  Future<List<WifiNetwork>> scanNetworks() async {
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      throw Exception("Permissão de localização é necessária para escanear WiFi.");
    }

    final canScan = await WiFiScan.instance.canStartScan(askPermissions: true);
    if (canScan != CanStartScan.yes) {
      throw Exception("Não foi possível iniciar o escaneamento: \$canScan");
    }

    await WiFiScan.instance.startScan();

    final canGet = await WiFiScan.instance.canGetScannedResults(askPermissions: true);
    if (canGet != CanGetScannedResults.yes) {
      throw Exception("Não foi possível obter os resultados: \$canGet");
    }

    final results = await WiFiScan.instance.getScannedResults();
    
    final Map<String, WifiNetwork> uniqueNetworks = {};
    
    for (var accessPoint in results) {
      final ssid = accessPoint.ssid.trim();
      if (ssid.isEmpty) continue;
      
      if (!uniqueNetworks.containsKey(ssid) || uniqueNetworks[ssid]!.rssi < accessPoint.level) {
        uniqueNetworks[ssid] = WifiNetwork(ssid: ssid, rssi: accessPoint.level);
      }
    }

    final networkList = uniqueNetworks.values.toList();
    networkList.sort((a, b) => b.rssi.compareTo(a.rssi));
    
    return networkList;
  }
}
