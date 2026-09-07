import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// import '../models/program_model.dart'; // Ensure these imports are there if needed
// import '../models/app_theme_model.dart'; // Ensure these imports are there if needed

class StorageService {
  static const _storage = FlutterSecureStorage();

  // ── Token (secure) ───────────────────────────────────────────────────────
  static Future<void> saveToken(String token) async =>
      await _storage.write(key: 'auth_token', value: token);

  static Future<String?> getToken() async =>
      await _storage.read(key: 'auth_token');

  static Future<void> deleteToken() async =>
      await _storage.delete(key: 'auth_token');

  // ── Generic helpers ──────────────────────────────────────────────────────
  static Future<void> _saveJson(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  static Future<dynamic> _getJson(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  // ── Theme ────────────────────────────────────────────────────────────────
  static Future<void> cacheTheme(Map<String, dynamic> data) async {
    await _saveJson('cache_theme', data);
    await saveCacheTime('cache_theme');
  }

  static Future<Map<String, dynamic>?> getCachedTheme() async {
    final data = await _getJson('cache_theme');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  // ── Speakers ─────────────────────────────────────────────────────────────
  static Future<void> cacheSpeakers(List<dynamic> data) async {
    await _saveJson('cache_speakers', data);
    await saveCacheTime('cache_speakers');
  }

  static Future<List<dynamic>?> getCachedSpeakers() async {
    final data = await _getJson('cache_speakers');
    return data != null ? List<dynamic>.from(data) : null;
  }

  // ── Program ──────────────────────────────────────────────────────────────
  static Future<void> cacheProgram(List<dynamic> data) async {
    await _saveJson('cache_program', data);
    await saveCacheTime('cache_program');
  }

  static Future<List<dynamic>?> getCachedProgram() async {
    final data = await _getJson('cache_program');
    return data != null ? List<dynamic>.from(data) : null;
  }

  // ── Sponsors ─────────────────────────────────────────────────────────────
  static Future<void> cacheSponsors(List<dynamic> data) async {
    await _saveJson('cache_sponsors', data);
    await saveCacheTime('cache_sponsors');
  }

  static Future<List<dynamic>?> getCachedSponsors() async {
    final data = await _getJson('cache_sponsors');
    return data != null ? List<dynamic>.from(data) : null;
  }

  // ── Committee ────────────────────────────────────────────────────────────
  static Future<void> cacheCommittee(List<dynamic> data) async {
    await _saveJson('cache_committee', data);
    await saveCacheTime('cache_committee');
  }

  static Future<List<dynamic>?> getCachedCommittee() async {
    final data = await _getJson('cache_committee');
    return data != null ? List<dynamic>.from(data) : null;
  }

  // ── Abstracts / Posters ──────────────────────────────────────────────────
  static Future<void> cacheAbstracts(List<dynamic> data) =>
      _saveJson('cache_abstracts', data);

  static Future<List<dynamic>?> getCachedAbstracts() async {
    final data = await _getJson('cache_abstracts');
    return data != null ? List<dynamic>.from(data) : null;
  }

  // ── VODs ─────────────────────────────────────────────────────────────────
  static Future<void> cacheVods(List<dynamic> data) async {
    await _saveJson('cache_vods', data);
    await saveCacheTime('cache_vods');
  }

  static Future<List<dynamic>?> getCachedVods() async {
    final data = await _getJson('cache_vods');
    return data != null ? List<dynamic>.from(data) : null;
  }

  // ── FAQs ─────────────────────────────────────────────────────────────────
  static Future<void> cacheFaqs(List<dynamic> data) async {
    await _saveJson('cache_faqs', data);
    await saveCacheTime('cache_faqs');
  }

  static Future<List<dynamic>?> getCachedFaqs() async {
    final data = await _getJson('cache_faqs');
    return data != null ? List<dynamic>.from(data) : null;
  }

  // ── Infos ────────────────────────────────────────────────────────────────
  static Future<void> cacheInfos(List<dynamic> data) =>
      _saveJson('cache_infos', data);

  static Future<List<dynamic>?> getCachedInfos() async {
    final data = await _getJson('cache_infos');
    return data != null ? List<dynamic>.from(data) : null;
  }

  // ── Cache TTL ────────────────────────────────────────────────────────────
  static Future<void> saveCacheTime(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      '${key}_saved_at',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<bool> isCacheValid(
    String key, {
    int maxAgeHours = 24,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final savedAt = prefs.getInt('${key}_saved_at');
    if (savedAt == null) return false;
    final age = DateTime.now().millisecondsSinceEpoch - savedAt;
    return age < maxAgeHours * 3600 * 1000;
  }

  // ── Splash background URL ────────────────────────────────────────────────
  static Future<void> cacheSplashBgUrl(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    if (url != null && url.isNotEmpty) {
      await prefs.setString('splash_bg_url', url);
    }
  }

  static Future<String?> getCachedSplashBgUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('splash_bg_url');
  }

  // ── Splash logo URL ──────────────────────────────────────────────────────
  static Future<void> cacheSplashLogoUrl(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    if (url != null && url.isNotEmpty) {
      await prefs.setString('splash_logo_url', url);
    }
  }

  static Future<String?> getCachedSplashLogoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('splash_logo_url');
  }

  // ── Layout preferences (grid / list) ────────────────────────────────────
  static Future<void> saveLayoutPreference(String viewKey, bool isGrid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('layout_$viewKey', isGrid);
  }

  static Future<bool?> getLayoutPreference(String viewKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('layout_$viewKey')
        ? prefs.getBool('layout_$viewKey')
        : null;
  }

  // ── Agenda ───────────────────────────────────────────────────────────────
  static const String _agendaItemsKey = 'agenda_items';

  static Future<void> cacheAgenda(List<int> itemIds) async {
    await _saveJson(_agendaItemsKey, itemIds);
  }

  static Future<List<int>?> getCachedAgenda() async {
    final data = await _getJson(_agendaItemsKey);
    return data != null ? List<int>.from(data) : null;
  }

  // ── Délais de notification (itemId → minutes) ─────────────────────────────
  static const String _notificationDelaysKey = 'notification_delays';

  static Future<void> cacheNotificationDelays(Map<int, int> delays) async {
    // SharedPreferences ne supporte pas les Map<int,int> directement → on
    // encode en Map<String,int> pour la sérialisation JSON.
    final encoded = {
      for (final e in delays.entries) e.key.toString(): e.value,
    };
    await _saveJson(_notificationDelaysKey, encoded);
  }

  static Future<Map<int, int>> getCachedNotificationDelays() async {
    final data = await _getJson(_notificationDelaysKey);
    if (data == null) return {};
    return {
      for (final e in (data as Map).entries)
        int.parse(e.key as String): (e.value as num).toInt(),
    };
  }
}
