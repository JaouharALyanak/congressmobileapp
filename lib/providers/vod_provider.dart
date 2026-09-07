import 'package:flutter/material.dart';
import '../models/vod_model.dart';
import '../core/api_client.dart';
import '../config/app_config.dart';
import '../services/storage_service.dart';

class VodProvider extends ChangeNotifier {
  List<Vod> _vods = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Vod> get vods => _vods;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadVods({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get(
        '/${AppConfig.eventSlug}/vods',
      );

      if (response.data['success'] == true) {
        final List data = response.data['data'];
        _vods = data.map((v) => Vod.fromJson(v)).toList();
        await StorageService.cacheVods(
          _vods.map((v) => v.toJson()).toList(),
        );
      }
    } catch (e) {
      final cached = await StorageService.getCachedVods();
      if (cached != null) {
        _vods = cached.map((v) => Vod.fromJson(v)).toList();
      } else {
        _errorMessage = 'Impossible de charger les vidéos';
      }
      debugPrint('Erreur chargement VODs : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
