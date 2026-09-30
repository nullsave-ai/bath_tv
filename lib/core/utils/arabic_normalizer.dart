/// توحيد النص العربي لدعم البحث: إزالة التشكيل والتطويل وتوحيد الهمزات
/// والياء والتاء المربوطة، وتحويل الأرقام الهندية إلى لاتينية.
String normalizeArabic(String input) {
  var s = input.toLowerCase().trim();
  s = s.replaceAll(RegExp('[ً-ٰٟـ]'), '');
  s = s
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي');
  const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
  for (var i = 0; i < arabicDigits.length; i++) {
    s = s.replaceAll(arabicDigits[i], '$i');
  }
  return s.replaceAll(RegExp(r'\s+'), ' ');
}
