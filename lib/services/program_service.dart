import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../config/app_config.dart';
import '../models/program_model.dart';

class ProgramService {
  Future<List<ProgramDay>> fetchProgram() async {
    try {
      final response = await ApiClient.dio.get(
        '/${AppConfig.eventSlug}/program',
      );

      if (response.data['success'] == true) {
        final List rawList = response.data['data'];
        return rawList.map((json) => ProgramDay.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur ProgramService: $e');
      rethrow;
    }
  }
}
