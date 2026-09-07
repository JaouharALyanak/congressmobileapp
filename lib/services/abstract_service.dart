import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../models/abstract_model.dart';
import '../config/app_config.dart';

class AbstractService {
  Future<Map<String, dynamic>> fetchAbstracts(int page, String query) async {
    try {
      final response = await ApiClient.dio.get(
        '/${AppConfig.eventSlug}/abstracts',
        queryParameters: {'page': page, 'q': query},
      );
      if (response.data['success'] == true) {
        final data = response.data['data'];
        // ── Paginated response ──
        if (data is Map && data.containsKey('data')) {
          List rawList = data['data'];
          return {
            'abstracts': rawList.map((j) => AbstractModel.fromJson(j)).toList(),
            'hasNext': data['next_page_url'] != null,
          };
        }
        // ── Simple list response ──
        if (data is List) {
          return {
            'abstracts': data.map((j) => AbstractModel.fromJson(j)).toList(),
            'hasNext': false,
          };
        }
      }
      return {'abstracts': [], 'hasNext': false};
    } on DioException catch (e) {
      debugPrint("❌ Erreur Dio AbstractService: ${e.message}");
      throw Exception("Impossible de charger les abstracts: ${e.message}");
    } catch (e) {
      debugPrint("❌ Erreur inattendue AbstractService: $e");
      throw Exception("Erreur inattendue: $e");
    }
  }
}
