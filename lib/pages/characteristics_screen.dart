


import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class CharacteristicsScreen extends StatelessWidget {
  final DiscoveredService service;
  final String deviceId;

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
              onTap: () {
                // Aquí puedes implementar la lógica para leer/escribir la característica
                print('Característica seleccionada: ${characteristic.characteristicId}');
              },
            ),
          );
        },
      ),
    );
  }
}