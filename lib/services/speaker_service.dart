// lib/services/speaker_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // <<< AJOUTER CET IMPORT
import '../core/api_client.dart';
import '../models/speaker_model.dart';
import 'package:event_app/config/app_config.dart';

class SpeakerService {
  Future<Map<String, dynamic>> fetchSpeakers(int page, String query) async {
    try {
      final response = await ApiClient.dio.get(
        '/${AppConfig.eventSlug}/speakers',
        queryParameters: {'page': page, 'q': query},
      );

      if (response.data['success'] == true) {
        var paginationData = response.data['data'];
        List rawList = paginationData['data'];

        return {
          'speakers': rawList.map((json) => Speaker.fromJson(json)).toList(),
          'hasNext': paginationData['next_page_url'] != null,
        };
      }
      return {'speakers': [], 'hasNext': false};
    } on DioException catch (e) {
      debugPrint(
        "❌ Erreur Dio dans SpeakerService.fetchSpeakers: ${e.message}",
      );
      if (e.response != null) {
        debugPrint("Response data: ${e.response?.data}");
        debugPrint("Response headers: ${e.response?.headers}");
      }
      throw Exception(
        "Impossible de charger les speakers. Erreur: ${e.message}",
      );
    } catch (e) {
      debugPrint("❌ Erreur inattendue dans SpeakerService.fetchSpeakers: $e");
      throw Exception(
        "Une erreur inattendue est survenue lors du chargement des speakers.",
      );
    }
  }

  Future<List<Speaker>> fetchRandomSpeakers() async {
    try {
      final response = await ApiClient.dio.get(
        '/${AppConfig.eventSlug}/speakers/random',
      );

      if (response.data['success'] == true) {
        List rawList = response.data['data'];
        return rawList.map((json) => Speaker.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint(
        "❌ Erreur Dio dans SpeakerService.fetchRandomSpeakers: ${e.message}",
      );
      if (e.response != null) {
        debugPrint("Response data: ${e.response?.data}");
        debugPrint("Response headers: ${e.response?.headers}");
      }
      throw Exception(
        "Impossible de charger les speakers aléatoires. Erreur: ${e.message}",
      );
    } catch (e) {
      debugPrint(
        "❌ Erreur inattendue dans SpeakerService.fetchRandomSpeakers: $e",
      );
      throw Exception(
        "Une erreur inattendue est survenue lors du chargement des speakers aléatoires.",
      );
    }
  }
}
