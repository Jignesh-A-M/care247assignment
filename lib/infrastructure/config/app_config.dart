import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig();

  // Local network ip of the computer running JSON Server.
  // Keep it empty for an emulator or simulator. Fill it only for a physical device.
  static const String networkHostIp = '192.168.1.13';

  static String get baseUrl {
    if (networkHostIp.isNotEmpty) {
      return 'http://$networkHostIp:3001/customers';
    }
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3001/customers';
    }
    return 'http://localhost:3001/customers';
  }
}