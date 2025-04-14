

import 'package:bluetooth_lowenwrgy/pages/characteristics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ServicesScreen extends StatelessWidget {
  final List<DiscoveredService> services;
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
              title: Text('Servicio: ${service.serviceId}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CharacteristicsScreen(
                      service: service,
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