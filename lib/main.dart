import 'dart:convert';

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
  List<DiscoveredService> services = [];
  Map<String, List<int>> characteristicValues = {};
 

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
    flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
      setState(() {
        if (!devices.any((d) => d.id == device.id)) {
          devices.add(device);
        }
      });
    });
  }

  void connectToDevice(DiscoveredDevice device) async {
    final connection = flutterReactiveBle.connectToDevice(id: device.id);
    connection.listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        setState(() {
          connectedDevice = device;
        });
        discoverServices(device.id);
        
      }
    });
  }

  void discoverServices(String deviceId) async {
    services = await flutterReactiveBle.discoverServices(deviceId);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ServicesScreen(services: services, deviceId: deviceId),
    ),
  );
  }

  void readCharacteristic(QualifiedCharacteristic characteristic, WidgetRef ref) async {
    String value = '';
    List<String> lista = []; 
    try {
      flutterReactiveBle.subscribeToCharacteristic(characteristic).listen((data) {
          lista = [];
          for (int i = 1; i < data.length; i++) {
            lista.add( String.fromCharCode(data[i]));
          }

          lista = lista.sublist(0, lista.length - 2);
          
          if (lista.length >= 7) {
            String lastSevenData = lista.sublist(lista.length - 7).join('');
            double number = double.parse(lastSevenData);
            ref.read(pesoValueProvider.notifier).state = number.toString();
          } 
          ref.read(characteristicValueProvider.notifier).state = lista;

      }, onError: (dynamic error) {
        // code to handle errors
      });
    } catch (e) {
      //print('Error reading characteristic: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reading characteristic: $e')),
      );
    }
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
                      
                      //Navigator.push(context,MaterialPageRoute(builder: (context) => CharacteristicScreen()));
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
        child: Text(peso, style: TextStyle(fontSize: 30),),
      ),
    );
  }
}