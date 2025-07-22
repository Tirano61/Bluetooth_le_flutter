


import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';

class CharacteristicsScreen extends StatefulWidget {
  final DiscoveredService service;
  final String deviceId;

  CharacteristicsScreen({required this.service, required this.deviceId});

  @override
  _CharacteristicsScreenState createState() => _CharacteristicsScreenState();
}

class _CharacteristicsScreenState extends State<CharacteristicsScreen> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription<List<int>>? _subscription;
  Map<String, bool> _subscribedCharacteristics = {};
  Map<String, List<int>> _characteristicValues = {};
  int _currentMtu = 23; // MTU por defecto

  @override
  void initState() {
    super.initState();
    _requestMaxMtu();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _requestMaxMtu() async {
    try {
      // Solicitar MTU máximo (hasta 517 bytes en Bluetooth LE)
      final mtu = await _ble.requestMtu(deviceId: widget.deviceId, mtu: 517);
      setState(() {
        _currentMtu = mtu;
      });
      print('MTU negociado: $mtu bytes');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('MTU configurado a: $mtu bytes'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error al solicitar MTU: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al configurar MTU: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _subscribeToCharacteristic(DiscoveredCharacteristic characteristic) async {
    final characteristicId = characteristic.characteristicId.toString();
    
    // Si ya está suscrito, cancelar la suscripción
    if (_subscribedCharacteristics[characteristicId] == true) {
      _subscription?.cancel();
      setState(() {
        _subscribedCharacteristics[characteristicId] = false;
        _characteristicValues.remove(characteristicId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Suscripción cancelada para: $characteristicId')),
      );
      return;
    }

    try {
      // Crear el QualifiedCharacteristic para la suscripción
      final qualifiedCharacteristic = QualifiedCharacteristic(
        serviceId: widget.service.serviceId,
        characteristicId: characteristic.characteristicId,
        deviceId: widget.deviceId,
      );

      // Suscribirse a las notificaciones
      _subscription = _ble.subscribeToCharacteristic(qualifiedCharacteristic).listen(
        (data) {
          setState(() {
            _characteristicValues[characteristicId] = data;
          });
          
          // Convertir data a string
          String dataAsString = '';
          try {
            // Intentar convertir cada byte a carácter
            dataAsString = String.fromCharCodes(data);
          } catch (e) {
            // Si falla, usar representación hexadecimal
            dataAsString = data.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' ');
          }
          
          print('Datos recibidos de $characteristicId: $data');
          print('Datos como string: $dataAsString');
          
          // Mostrar los datos recibidos como string
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Datos recibidos: $dataAsString'),
              duration: Duration(seconds: 3),
            ),
          );
        },
        onError: (error) {
          print('Error en la suscripción: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error en la suscripción: $error')),
          );
        },
      );

      setState(() {
        _subscribedCharacteristics[characteristicId] = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Suscrito a notificaciones de: $characteristicId')),
      );
    } catch (e) {
      print('Error al suscribirse: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al suscribirse: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Características del Servicio'),
            Text('MTU: $_currentMtu bytes', 
                 style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _requestMaxMtu,
            tooltip: 'Solicitar MTU máximo',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.service.characteristics.length,
        itemBuilder: (context, index) {
          final characteristic = widget.service.characteristics[index];
          final characteristicId = characteristic.characteristicId.toString();
          final isSubscribed = _subscribedCharacteristics[characteristicId] ?? false;
          final hasValue = _characteristicValues.containsKey(characteristicId);
          
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              title: Text('Característica: ${characteristic.characteristicId}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Propiedades: ${characteristic.isWritableWithoutResponse}'),
                  if (isSubscribed) 
                    Text('🔔 Suscrito', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  if (hasValue) ...[
                    Builder(
                      builder: (context) {
                        // Convertir el último valor a string para mostrar
                        String lastValueAsString = '';
                        final lastValue = _characteristicValues[characteristicId];
                        if (lastValue != null) {
                          try {
                            lastValueAsString = String.fromCharCodes(lastValue);
                          } catch (e) {
                            lastValueAsString = lastValue.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}').join(' ');
                          }
                        }
                        return Text('Último valor: $lastValueAsString', 
                             style: TextStyle(color: Colors.blue));
                      },
                    ),
                  ],
                ],
              ),
              trailing: isSubscribed 
                  ? Icon(Icons.notifications_active, color: Colors.green)
                  : Icon(Icons.notifications_none),
              onTap: () {
                _subscribeToCharacteristic(characteristic);
              },
            ),
          );
        },
      ),
    );
  }
}