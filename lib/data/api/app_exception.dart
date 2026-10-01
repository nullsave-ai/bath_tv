import 'package:dio/dio.dart';

import '../../core/constants/app_strings.dart';

/// استثناء موحد يحمل رسالة عربية مناسبة للعرض للمستخدم.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  factory AppException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException(AppStrings.timeout);
      case DioExceptionType.connectionError:
        return const AppException(AppStrings.noConnection);
      case DioExceptionType.badResponse:
        return AppException(AppStrings.serverError(e.response?.statusCode));
      default:
        return const AppException(AppStrings.genericError);
    }
  }

  @override
  String toString() => message;
}

String errorMessageOf(Object error) {
  if (error is AppException) return error.message;
  return AppStrings.genericError;
}
