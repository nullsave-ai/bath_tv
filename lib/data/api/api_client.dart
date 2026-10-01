import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_strings.dart';
import 'app_exception.dart';

/// طبقة الشبكة: عميل Dio واحد مع تحويل الأخطاء إلى [AppException].
class ApiClient {
  ApiClient(String baseUrl)
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: AppConfig.networkTimeout,
            receiveTimeout: AppConfig.networkTimeout,
            headers: const {'Accept': 'application/json'},
          ),
        );

  final Dio _dio;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: query);
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      throw const AppException(AppStrings.badResponse);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }
}
