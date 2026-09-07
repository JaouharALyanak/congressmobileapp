import 'package:flutter/material.dart';
import '../models/sponsor_model.dart';
import '../services/sponsor_service.dart';
import '../services/storage_service.dart'; // ✅ NEW

class SponsorProvider extends ChangeNotifier {
  final SponsorService _service = SponsorService();

  List<SponsorGroup> groups = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadSponsors() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    try {
      final results = await _service.fetchSponsors();
      groups = results.where((g) => g.items.isNotEmpty).toList();

      // ✅ Save to persistent cache
      await StorageService.cacheSponsors(
        groups.map((g) => g.toJson()).toList(),
      );
    } catch (e) {
      // ✅ Fallback to persistent cache
      final cached = await StorageService.getCachedSponsors();
      if (cached != null) {
        final all = cached.map((e) => SponsorGroup.fromJson(e)).toList();
        groups = all.where((g) => g.items.isNotEmpty).toList();
      } else {
        errorMessage = e.toString();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
