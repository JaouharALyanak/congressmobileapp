import 'package:flutter/material.dart';
import '../models/faq_model.dart';
import '../core/api_client.dart';
import '../config/app_config.dart';
import '../services/storage_service.dart';

class FaqProvider extends ChangeNotifier {
  List<FaqCategory> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FaqCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadFaqs({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get(
        '/${AppConfig.eventSlug}/faqs',
      );

      if (response.data['success'] == true) {
        final List data = response.data['data'];
        _categories = data.map((c) => FaqCategory.fromJson(c)).toList();
        await StorageService.cacheFaqs(
          _categories.map((c) => c.toJson()).toList(),
        );
      }
    } catch (e) {
      final cached = await StorageService.getCachedFaqs();
      if (cached != null) {
        _categories = cached.map((c) => FaqCategory.fromJson(c)).toList();
      } else {
        _errorMessage = 'Impossible de charger les FAQs';
      }
      debugPrint('Erreur chargement FAQs : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
