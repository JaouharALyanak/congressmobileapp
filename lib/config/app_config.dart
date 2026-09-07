import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://mob-app-ascrea.hashtagsante.com/api/v1',
  );

  static const String eventSlug = String.fromEnvironment(
    'EVENT_SLUG',
    defaultValue: 'smr26_9v9z4',
  );

  static const String eventAccessKey = String.fromEnvironment(
    'EVENT_KEY',
    defaultValue: 'ev_jkfIj6Fu362m0iOK',
  );

  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Event App',
  );

  static const String storeUrlAndroid = String.fromEnvironment(
    'STORE_URL_ANDROID',
    defaultValue: '',
  );

  static const String storeUrlIos = String.fromEnvironment(
    'STORE_URL_IOS',
    defaultValue: '',
  );

  // Rétrocompat — retourne l'URL selon la plateforme
  static String get storeUrl {
    if (defaultTargetPlatform == TargetPlatform.iOS) return storeUrlIos;
    return storeUrlAndroid;
  }

  // When true: blocks the app until the user updates.
  // When false: the dialog has a "Later" button the user can dismiss.
  static const bool forceUpdate = bool.fromEnvironment(
    'FORCE_UPDATE',
    defaultValue: false,
  );

  static const String _primaryHex = String.fromEnvironment(
    'PRIMARY_COLOR',
    defaultValue: '6A1B62',
  );

  // ✅ Couleur dynamique depuis le .env
  static Color get primaryColor {
    try {
      return Color(int.parse('0xFF$_primaryHex'));
    } catch (_) {
      return const Color(0xFF6A1B62);
    }
  }
}
