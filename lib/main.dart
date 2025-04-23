import 'dart:convert';

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

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final flutterReactiveBle = FlutterReactiveBle();
  DiscoveredDevice? connectedDevice;
  List<DiscoveredService> services = [];
  Map<String, List<int>> characteristicValues = {};
  String _peso= "";

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

    startScan();
  }

  void startScan() {
    flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
      //print('${device.name} found! rssi: ${device.rssi}');
      if (device.name == "BALANZAS_HOOK") {
        //flutterReactiveBle. stopScan();
        connectToDevice(device);
      }
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
    setState(() {
      print(services);
    });
  }
  
  void readCharacteristic(QualifiedCharacteristic characteristic) async {
    try {
      flutterReactiveBle.subscribeToCharacteristic(characteristic).listen((data) {
      setState(() {
         final value = utf8.decode(data); 
         _peso = value;
        characteristicValues[characteristic.characteristicId.toString()] = data;
      });
    }, onError: (dynamic error) {
      print(error);
      // code to handle errors
    });
     // final value = await flutterReactiveBle.readCharacteristic(characteristic);
     
    } catch (e) {
      print('Error reading characteristic: $e');
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
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: services
                  .map((service) => ExpansionTile(
                        title: Text(service.serviceId.toString()),
                        children: service.characteristics
                            .map((characteristic) => ListTile(
                                  title: Column(
                                    children: [
                                      Text(characteristic.characteristicInstanceId),
                                      Text(characteristic.characteristicId.toString()),
                                      Text('isIndicatable : '+characteristic.isIndicatable.toString()),
                                      Text('isNotifiable : '+characteristic.isNotifiable.toString()),
                                      Text('isReadable : '+characteristic.isReadable.toString()),
                                      Text('isWritableWithResponse : '+ characteristic.isWritableWithResponse.toString()),
                                      Text('isWritableWithoutResponse : '+ characteristic.isWritableWithoutResponse.toString()),
                                   
                                    ],
                                  ),
                                  onTap: () {
                                    if (characteristic.isNotifiable) {
                                      readCharacteristic(QualifiedCharacteristic(
                                        serviceId: service.serviceId,
                                        characteristicId: characteristic.characteristicId,
                                        deviceId: connectedDevice!.id,
                                      ));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Characteristic not readable')),
                                      );
                                    }
                                  },
                                  subtitle: Column(
                                    children: [
                                      Text('PESO : $_peso'),
                                      Text(characteristicValues[characteristic.characteristicId.toString()]?.toString() ?? 'Tap to read value'),
                                      Text('LENGTH : ${characteristicValues[characteristic.characteristicId.toString()]?.length.toString()}'),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ))
                  .toList(),
            ),
    );
  }
}