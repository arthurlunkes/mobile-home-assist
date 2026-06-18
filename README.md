# Mobile Home Assist

Mobile Home Assist é uma solução completa de casa inteligente (smart home) baseada em Flutter e ESP32. Ele permite provisionar, configurar e controlar diretamente do seu smartphone um dispositivo ESP32 equipado com sensores ambientais e um sistema de alarme.

## 🚀 Funcionalidades

- **Provisionamento Wi-Fi**: Configure facilmente o ESP32 para se conectar à rede da sua casa através de uma interface SoftAP (`ESP32-SETUP-ARTHUR`).
- **Monitoramento Ambiental**:
  - Leitura de temperatura (Termistor)
  - Leitura de umidade (DHT11)
  - Leitura de luminosidade (LDR)
- **Sistema de Alarme**: Acione um alarme que toca a *Marcha Imperial de Star Wars* em um buzzer conectado.
- **Contexto de Geolocalização**: Utiliza o GPS do seu smartphone para vincular uma localização ao seu dispositivo configurado.
- **Banco de Dados Local**: Persiste suas configurações e o status do dispositivo utilizando SQLite.
- **Suporte a mDNS**: Descobre e se comunica com o ESP32 de forma transparente na sua rede local usando o endereço `alarme.local`.

## 🛠️ Tecnologias Utilizadas

### Mobile (Flutter)
- **Dart SDK**: `^3.10.0`
- **Flutter**: Utiliza os lints recomendados da versão `^6.0.0`
- **http** (`^1.6.0`): Comunicação HTTP REST API
- **sqflite** (`^2.4.2`): Armazenamento Local via SQLite
- **geolocator** (`^14.0.2`): Serviços de localização via GPS
- **google_maps_flutter** (`^2.17.0`) & **maps_launcher** (`^3.0.0+1`): Mapas e direcionamento
- **wifi_scan** (`^0.4.1+2`): Escaneamento de redes (se aplicável ao provisionamento)
- **permission_handler** (`^12.0.3`): Gerenciamento de permissões do sistema
- **path** (`^1.9.1`): Gerenciamento de caminhos de arquivos

### Hardware (ESP32)
- **Plataforma**: `espressif32` (Placa: `esp32doit-devkit-v1`)
- **Framework**: Arduino / PlatformIO
- **ArduinoJson** (`bblanchon/ArduinoJson`): Serialização de pacotes JSON via HTTP
- **DHTesp** (`beegee-tokyo/DHT sensor library for ESPx`): Leitura do sensor de temperatura/umidade DHT11

## 📱 Arquitetura do App

### Serviços
- **WifiProvisionService**: Gerencia a comunicação inicial com o ESP32 no modo Access Point (IP: `192.168.4.1`) para enviar as credenciais do seu Wi-Fi.
- **ConnectionTester**: Verifica a conectividade com o ESP32 através do seu hostname local (`alarme.local`).

### Banco de Dados (`DatabaseProvider`)
Armazena dados localmente divididos em duas tabelas principais:
- `device_config`: Hostname, porta, endereço MAC, status de conexão, latitude e longitude.
- `home_state`: Valores em cache de temperatura, umidade, luminosidade e status do alarme.

## 🔌 Visão Geral dos Endpoints do ESP32

O ESP32 expõe um servidor web RESTful na porta 80:
- `GET /` - Interface web HTML simples para testes.
- `GET /status` - Retorna o status de configuração do dispositivo e o endereço MAC.
- `GET /info` - Retorna informações detalhadas da rede (IP, MAC, modo).
- `POST /wifi` - Recebe um payload JSON com `ssid` e `password` para conectar a uma nova rede.
- `GET /temperature` - Retorna a temperatura atual em graus Celsius.
- `GET /humidity` - Retorna a umidade atual em porcentagem.
- `GET /luminosity` - Retorna o nível de luminosidade em porcentagem.
- `GET /H` - LIGA o alarme (toca a Marcha Imperial).
- `GET /L` - DESLIGA o alarme.
- `GET /reset` - Apaga as credenciais de Wi-Fi salvas e reinicia o ESP32.

## 🏃 Como Executar

### Pré-requisitos
- Flutter SDK
- Um ESP32 configurado e rodando o código de hardware (projeto MyHome do PlatformIO).

### Rodando o App
1. Clone este repositório.
2. Execute `flutter pub get` para instalar todas as dependências.
3. Rode o aplicativo no seu dispositivo físico ou emulador usando `flutter run` (um dispositivo físico é altamente recomendado para que o provisionamento do Wi-Fi e o GPS funcionem corretamente).
