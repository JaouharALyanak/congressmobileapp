// providers/theme_provider.dart
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../config/app_config.dart';
import '../models/app_theme_model.dart';
import '../models/app_settings_model.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  AppThemeModel? _theme;
  AppSettingsModel? _settings;

  // États de chargement
  bool isLoading = true;
  String? errorMessage;
  int requiredVersion = 0;

  // Modules optionnels activés depuis le back office (1 = affiché, 0 = masqué)
  int _videoMenu = 0;
  int _faqMenu = 0;
  int _motMenu = 1;      // mot du président
  int _membreMenu = 1;   // comité
  int _abstractMenu = 1; // abstracts/posters
  int _infosMenu = 1;    // infos pratiques

  int get videoMenu    => _videoMenu;
  int get faqMenu      => _faqMenu;
  int get motMenu      => _motMenu;
  int get membreMenu   => _membreMenu;
  int get abstractMenu => _abstractMenu;
  int get infosMenu    => _infosMenu;

  // Données spécifiques à l'événement
  String? _presidentWord;
  String? _badgeText;
  String? _address;
  String? _phone;
  String? _googleMapsUrl;
  String? _email;
  String? _city;
  String? _country;

  // --- Getters Thème & Settings ---
  AppThemeModel get theme => _theme ?? AppThemeModel.fromJson({});
  AppSettingsModel get settings => _settings ?? AppSettingsModel.fromJson({});

  // --- Raccourcis Couleurs (UI) ---
  Color get primaryColor => theme.headerBg;
  Color get pageBgColor => theme.eventBgColor;
  Color get cardBg => theme.cardBgColor;
  Color get mainTextPrimaryColor => theme.mainTextPrimaryColor;
  Color get mainTextSecondaryColor => theme.mainTextSecondaryColor;

  // --- Getters Infos Événement ---
  String get presidentWord =>
      _presidentWord ?? "Mot du président non disponible";
  String get badgeText => _badgeText ?? "";
  String get address => _address ?? "Adresse non communiquée";
  String get phone => _phone ?? "";
  String get googleMapsUrl => _googleMapsUrl ?? "";
  String get email => _email ?? "";
  String get city => _city ?? "";
  String get country => _country ?? "";

  // ── Load from API (online) ───────────────────────────────────────────────
  Future<void> loadTheme({bool forceRefresh = false}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    // ── Utilise le cache si encore valide (2h) et pas de force refresh ──
    if (!forceRefresh) {
      final cacheValid = await StorageService.isCacheValid(
        'cache_theme',
        maxAgeHours: 2,
      );
      if (cacheValid) {
        await loadCachedTheme();
        return;
      }
    }

    try {
      final response = await ApiClient.dio.get(
        '/themes/${AppConfig.eventSlug}',
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];

        // ✅ Cache the full response for offline use
        await StorageService.cacheTheme(Map<String, dynamic>.from(data));

        // Clear image cache so updated banner/logo images are re-fetched
        PaintingBinding.instance.imageCache.clear();

        _applyThemeData(data);
      } else {
        errorMessage = 'Réponse inattendue du serveur';
      }
    } catch (e) {
      errorMessage = 'Impossible de charger le thème et les réglages';
      debugPrint('ThemeProvider error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Load from cache (offline) ────────────────────────────────────────────
  Future<void> loadCachedTheme() async {
    isLoading = true;
    notifyListeners();

    try {
      final cached = await StorageService.getCachedTheme();
      if (cached != null) {
        _applyThemeData(cached);
      } else {
        // No cache at all — app will show error screen
        errorMessage = 'Aucune donnée en cache';
      }
    } catch (e) {
      errorMessage = 'Erreur lors du chargement du cache';
      debugPrint('ThemeProvider cache error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Shared logic: apply data to state ───────────────────────────────────
  void _applyThemeData(Map<String, dynamic> data) {
    _theme = AppThemeModel.fromJson(data);
    _settings = AppSettingsModel.fromJson(data['settings']);
    requiredVersion = (data['app_version'] as num?)?.toInt() ?? 0;
    _videoMenu    = (data['video_menu']    as num?)?.toInt() ?? 0;
    _faqMenu      = (data['faq_menu']      as num?)?.toInt() ?? 0;
    _motMenu      = (data['mot_menu']      as num?)?.toInt() ?? 1;
    _membreMenu   = (data['membre_menu']   as num?)?.toInt() ?? 1;
    _abstractMenu = (data['abstract_menu'] as num?)?.toInt() ?? 1;
    _infosMenu    = (data['infos_menu']    as num?)?.toInt() ?? 1;
    StorageService.cacheSplashBgUrl(_theme!.eventBgImageUrl);

    if (data['event'] != null) {
      final ev = data['event'];
      _presidentWord = ev['president_word'];
      _badgeText = ev['badge_text'];
      _phone = ev['contact_phone'];
      _googleMapsUrl = ev['google_maps_url'];
      _email = ev['email'];
      _city = ev['city'];
      _country = ev['country'];
      _address = ev['full_address'] ?? ev['address'];
    }
  }
}
