

import 'package:bluetooth_lowenwrgy/pages/characteristics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ServicesScreen extends StatelessWidget {
  final List<Service> services;
  final String deviceId;

  ServicesScreen({required this.services, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Servicios del Dispositivo'),
      ),
      body: ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              title: Text('Servicio: ${service.id}'),
              onTap: () {
                // Convertir Service a DiscoveredService para compatibilidad
                final discoveredService = DiscoveredService(
                  serviceId: service.id,
                  serviceInstanceId: service.id.toString(), // Convertir Uuid a String
                  characteristicIds: service.characteristics.map((c) => c.id).toList(),
                  characteristics: service.characteristics.map((char) => 
                    DiscoveredCharacteristic(
                      characteristicId: char.id,
                      characteristicInstanceId: char.id.toString(), // Convertir Uuid a String
                      serviceId: service.id,
                      isReadable: char.isReadable,
                      isWritableWithResponse: char.isWritableWithResponse,
                      isWritableWithoutResponse: char.isWritableWithoutResponse,
                      isNotifiable: char.isNotifiable,
                      isIndicatable: char.isIndicatable,
                    )
                  ).toList(),
                );
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CharacteristicsScreen(
                      service: discoveredService,
                      deviceId: deviceId,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}