import 'package:bath_tv/core/utils/arabic_normalizer.dart';
import 'package:bath_tv/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeArabic', () {
    test('يوحد الهمزات والتاء المربوطة والياء', () {
      expect(normalizeArabic('أسرار المدينة'), normalizeArabic('اسرار المدينه'));
      expect(normalizeArabic('مصطفى'), normalizeArabic('مصطفي'));
    });

    test('يزيل التشكيل والتطويل', () {
      expect(normalizeArabic('حَكَايَة'), 'حكايه');
      expect(normalizeArabic('بحــر'), 'بحر');
    });

    test('يحول الأرقام الهندية', () {
      expect(normalizeArabic('الجزء ٢'), 'الجزء 2');
    });
  });

  group('formatDuration', () {
    test('يعرض الدقائق والثواني', () {
      expect(formatDuration(const Duration(minutes: 5, seconds: 7)), '05:07');
    });

    test('يعرض الساعات عند الحاجة', () {
      expect(
        formatDuration(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '1:02:03',
      );
    });
  });
}
