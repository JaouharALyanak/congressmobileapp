import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../models/committee_member_model.dart';
import '../config/app_config.dart';

class CommitteeService {
  Future<List<CommitteeCategory>> fetchCommittee() async {
    try {
      final response = await ApiClient.dio.get(
        '/${AppConfig.eventSlug}/committee',
      );

      if (response.data['success'] == true) {
        final List rawList = response.data['data'];
        return rawList.map((json) => CommitteeCategory.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Erreur Service Committee: $e");
      rethrow;
    }
  }
}
