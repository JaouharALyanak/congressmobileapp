import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../models/sponsor_model.dart';
import '../config/app_config.dart';

class SponsorService {
  Future<List<SponsorGroup>> fetchSponsors() async {
    try {
      final response = await ApiClient.dio.get(
        '/${AppConfig.eventSlug}/sponsors',
      );

      if (response.data['success'] == true) {
        List rawList = response.data['data'];
        return rawList.map((json) => SponsorGroup.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Erreur Service Sponsor: $e");
      rethrow;
    }
  }
}
