import 'dart:convert';
import 'dart:async';

import 'package:bluetooth_lowenwrgy/pages/services_screen.dart';
import 'package:bluetooth_lowenwrgy/providers/peso_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(
    ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothScreen(),
    );
  }
}

class BluetoothScreen extends ConsumerStatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends ConsumerState<BluetoothScreen> {
  final flutterReactiveBle = FlutterReactiveBle();
  DiscoveredDevice? connectedDevice;
  List<DiscoveredDevice> devices = [];
  List<Service> services = [];
  Map<String, List<int>> characteristicValues = {};
  StreamSubscription<ConnectionStateUpdate>? deviceConnection;
  StreamSubscription<List<int>>? characteristicSubscription;
  StreamSubscription<DiscoveredDevice>? scanSubscription;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  void requestPermissions() async {
    await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ].request();

    flutterReactiveBle.statusStream.listen((status) {
      if (status == BleStatus.ready) {
        print("****************** Bluetooth está listo *********************");
      } else {
        print("****************** Bluetooth no está listo: $status *********************");
      }
    });

    startScan();
  }

  void startScan() {
    scanSubscription = flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
      setState(() {
        if (!devices.any((d) => d.id == device.id)) {
          devices.add(device);
          print('Dispositivo encontrado: ${device.name} (${device.id})');
        }
      });
    });
  }

  void connectToDevice(DiscoveredDevice device) async {
    print('Intentando conectar a ${device.name} (${device.id})');
    
    // Cancelar conexión anterior
    await deviceConnection?.cancel();

    final connection = flutterReactiveBle.connectToDevice(
      id: device.id,
      connectionTimeout: Duration(seconds: 10),
    );

    deviceConnection = connection.listen((connectionState) {
      print('Connection state: ${connectionState.connectionState}');
      
      switch (connectionState.connectionState) {
        case DeviceConnectionState.connecting:
          print('Conectando...');
          break;
        case DeviceConnectionState.connected:
          print('¡Conectado exitosamente!');
          setState(() {
            connectedDevice = device;
          });
          // Solicitar MTU máximo inmediatamente después de conectar
          _requestMaxMtu(device.id);
          // Agregar un pequeño delay antes de descubrir servicios
          Future.delayed(Duration(milliseconds: 1000), () {
            discoverServices(device.id);
          });
          break;
        case DeviceConnectionState.disconnecting:
          print('Desconectando...');
          break;
        case DeviceConnectionState.disconnected:
          print('Desconectado. Razón: ${connectionState.failure}');
          setState(() {
            connectedDevice = null;
          });
          break;
      }
    }, onError: (error) {
      print('Error de conexión: $error');
      setState(() {
        connectedDevice = null;
      });
    });
  }

  Future<void> _requestMaxMtu(String deviceId) async {
    try {
      // Solicitar MTU máximo (hasta 517 bytes en Bluetooth LE)
      final mtu = await flutterReactiveBle.requestMtu(deviceId: deviceId, mtu: 517);
      print('MTU negociado: $mtu bytes');
    } catch (e) {
      print('Error al solicitar MTU: $e');
    }
  }

  discoverServices(String deviceId) async {
    try {
      print('Iniciando descubrimiento de servicios para: $deviceId');
      await flutterReactiveBle.discoverAllServices(deviceId);
      
      print('Servicios descubiertos, obteniendo lista...');
      final discoveredServices = await flutterReactiveBle.getDiscoveredServices(deviceId);
      services = discoveredServices;
      
      print('Se encontraron ${services.length} servicios');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServicesScreen(services: services, deviceId: deviceId),
        ),
      );
    } catch (e) {
      print('Error discovering services: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error discovering services: $e')),
      );
    }
  }

  void readCharacteristic(QualifiedCharacteristic characteristic, WidgetRef ref) async {
    List<String> lista = [];
    try {
      // Cancelar suscripción anterior si existe
      await characteristicSubscription?.cancel();
      
      // Almacenar la nueva suscripción
      characteristicSubscription = flutterReactiveBle.subscribeToCharacteristic(characteristic).listen((data) {
        lista = [];
        for (int i = 1; i < data.length; i++) {
          lista.add(String.fromCharCode(data[i]));
        }

        lista = lista.sublist(0, lista.length - 2);

        if (lista.length >= 7) {
          String lastSevenData = lista.sublist(lista.length - 7).join('');
          double number = double.parse(lastSevenData);
          ref.read(pesoValueProvider.notifier).state = number.toString();
        }
        ref.read(characteristicValueProvider.notifier).state = lista;
      }, onError: (dynamic error) {
        print('Characteristic error: $error');
      });
    } catch (e) {
      //print('Error reading characteristic: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reading characteristic: $e')),
      );
    }
  }

  void disconnect() async {
    await deviceConnection?.cancel();
    setState(() {
      connectedDevice = null;
    });
  }

  @override
  void dispose() {
    deviceConnection?.cancel();
    characteristicSubscription?.cancel();
    scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth LE Example'),
      ),
      body: connectedDevice == null
          ? ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(device.name),
                    subtitle: Text(device.id),
                    onTap: () {
                      connectToDevice(device);
                    },
                  ),
                );
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class CharacteristicScreen extends ConsumerWidget {
  CharacteristicScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peso = ref.watch(pesoValueProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Characteristic Value'),
      ),
      body: Center(
        child: Text(
          peso,
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}