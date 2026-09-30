/// إعدادات التطبيق العامة.
///
/// لتشغيل التطبيق مع خادم حقيقي مرر عنوان الخادم عند البناء:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com/v1`
///
/// عند ترك العنوان فارغاً يعمل التطبيق ببيانات تجريبية محلية.
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static bool get useDemoData => apiBaseUrl.isEmpty;

  /// عدد العناصر في كل صفحة.
  static const int pageSize = 20;

  static const Duration networkTimeout = Duration(seconds: 15);

  /// عدد محاولات إعادة الاتصال التلقائي في المشغل.
  static const int maxReconnectAttempts = 8;
}
