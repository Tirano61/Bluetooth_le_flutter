


import 'package:bluetooth_lowenwrgy/LPAPI/flutter_lpapi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class CharacteristicsScreen extends StatelessWidget {
  final DiscoveredService service;
  final String deviceId;
  final dataToSend = [0x48, 0x6F, 0x6C, 0x61]; // "Hola" en ASCII

  CharacteristicsScreen({required this.service, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Características del Servicio'),
      ),
      body: ListView.builder(
        itemCount: service.characteristics.length,
        itemBuilder: (context, index) {
          final characteristic = service.characteristics[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              title: Text('Característica: ${characteristic.characteristicId}'),
              subtitle: Text('Propiedades: ${characteristic.isWritableWithoutResponse}'),
              onTap: () async {
                await FlutterReactiveBle().writeCharacteristicWithoutResponse(QualifiedCharacteristic(
                  characteristicId: characteristic.characteristicId,
                  serviceId: service.serviceId,
                  deviceId: deviceId,
                ), value: dataToSend);
                await FlutterLpapi.openPrinter();
                await FlutterLpapi.startJob(width: 50, height: 150, orientation: 0);
                //await FlutterLpapi.printText( text: "Hola Mundo", x: 10.0, y: 20.0, width: 100.0, height: 50.0, fontWeight: 1.0);
                await FlutterLpapi.drawRoundRectangle(x: 2,y: 5,cornerHeight: 0.2,cornerWidth: 0.3,height: 10,lineWidth: 1,width: 4 );
                await FlutterLpapi.commitJob();
                // Aquí puedes implementar la lógica para leer/escribir la característica
                //print('Característica seleccionada: ${characteristic.characteristicId}');
              },
            ),
          );
        },
      ),
    );
  }
}