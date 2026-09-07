import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../services/storage_service.dart';
import '../services/device_service.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // ✅ Intercepteur ajouté une seule fois à l'init
  static final Dio dio = _dio
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        // ✅ Intercepte les 401 → reboot automatique
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await StorageService.deleteToken();
            // Re-boot silencieux
            final ok = await _reboot();
            if (ok) {
              // Rejoue la requête originale avec le nouveau token
              final token = await StorageService.getToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          }
          return handler.next(error);
        },
      ),
    );

  static Future<bool> _reboot() async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      final response = await _dio.post(
        '/boot',
        data: {
          'event_slug': AppConfig.eventSlug,
          'event_token': AppConfig.eventAccessKey,
          'device_id': deviceId,
        },
      );
      if (response.statusCode == 200) {
        await StorageService.saveToken(response.data['token']);
        return true;
      }
    } catch (_) {}
    return false;
  }

  static Future<bool> verifyToken() async {
    try {
      final response = await dio.get('/verify-token');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
