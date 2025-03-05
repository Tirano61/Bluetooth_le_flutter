

import 'package:flutter_riverpod/flutter_riverpod.dart';

final characteristicValueProvider = StateProvider.autoDispose<List<String>>((ref) {
  
  return [];
});

final pesoValueProvider = StateProvider.autoDispose<String>((ref) {
  return '0.0';
});