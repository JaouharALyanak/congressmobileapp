import 'dart:io';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (kIsWeb) {
        final info = await deviceInfo.webBrowserInfo;
        return '${info.browserName.name}-${info.platform}-${info.vendor}'
            .replaceAll(' ', '-')
            .toLowerCase();
      }
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return info.id;
      }
      if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        return info.identifierForVendor ?? 'unknown-ios';
      }
    } catch (e) {
      debugPrint("DeviceService error: $e");
    }

    return 'unknown-${DateTime.now().millisecondsSinceEpoch}';
  }
}
