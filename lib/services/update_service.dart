import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLastDismissedKey = 'update_last_dismissed';
const _kIosAppId = '6763072246';
const _kAndroidPackage = 'com.htagsante.smr2026';

class UpdateInfo {
  final String currentVersion;
  final String storeVersion;
  final String storeUrl;

  const UpdateInfo({
    required this.currentVersion,
    required this.storeVersion,
    required this.storeUrl,
  });

  bool get hasUpdate => _compare(storeVersion, currentVersion) > 0;

  static int _compare(String a, String b) {
    final av = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final bv = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (int i = 0; i < 3; i++) {
      final ai = i < av.length ? av[i] : 0;
      final bi = i < bv.length ? bv[i] : 0;
      if (ai != bi) return ai.compareTo(bi);
    }
    return 0;
  }
}

class UpdateService {
  static Future<UpdateInfo?> check() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version;

      if (Platform.isIOS) return _checkiOS(current);
      if (Platform.isAndroid) return _checkAndroid(current);
      return null;
    } catch (e) {
      debugPrint('UpdateService: $e');
      return null;
    }
  }

  static Future<UpdateInfo?> _checkiOS(String current) async {
    final url = 'https://itunes.apple.com/lookup?id=$_kIosAppId';
    final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body);
    final results = data['results'] as List?;
    if (results == null || results.isEmpty) return null;
    final version = results[0]['version'] as String?;
    if (version == null) return null;
    return UpdateInfo(
      currentVersion: current,
      storeVersion: version,
      storeUrl: 'https://apps.apple.com/app/id$_kIosAppId',
    );
  }

  static Future<UpdateInfo?> _checkAndroid(String current) async {
    final url = 'https://play.google.com/store/apps/details?id=$_kAndroidPackage&hl=fr';
    final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) return null;
    final match = RegExp(r'\[\[\["(\d+\.\d+\.\d+)"').firstMatch(res.body);
    final version = match?.group(1);
    if (version == null) return null;
    return UpdateInfo(
      currentVersion: current,
      storeVersion: version,
      storeUrl: 'https://play.google.com/store/apps/details?id=$_kAndroidPackage',
    );
  }

  // Renvoie true si l'utilisateur a déjà ignoré aujourd'hui
  static Future<bool> wasDismissedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_kLastDismissedKey);
    if (last == null) return false;
    final date = DateTime.tryParse(last);
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static Future<void> saveDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastDismissedKey, DateTime.now().toIso8601String());
  }
}
