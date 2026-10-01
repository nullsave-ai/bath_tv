import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_strings.dart';
import '../../core/device/ui_metrics.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = <(String, String)>[
    (
      'جمع البيانات',
      'يحفظ التطبيق على جهازك فقط الإعدادات وسجل البحث ومواضع المشاهدة '
          'لتحسين تجربتك. لا تُرسل هذه البيانات إلى أي جهة.',
    ),
    (
      'استخدام الشبكة',
      'يتصل التطبيق بخوادم المحتوى لعرض القوائم وتشغيل البث. قد تسجل هذه '
          'الخوادم بيانات تقنية اعتيادية مثل عنوان الشبكة ونوع الجهاز.',
    ),
    (
      'التخزين المؤقت',
      'تُخزن الصور والبيانات مؤقتاً لتسريع التصفح، ويمكنك مسحها في أي وقت '
          'من صفحة الإعدادات.',
    ),
    (
      'الإشعارات',
      'الإشعارات اختيارية ويمكن إيقافها من الإعدادات في أي وقت.',
    ),
    (
      'التواصل',
      'عند وجود أي استفسار حول الخصوصية يرجى التواصل مع مطور التطبيق '
          'عبر بيانات التواصل المدرجة في صفحة المتجر.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final m = UiMetrics.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.privacyPolicy)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: EdgeInsets.all(m.pagePadding),
            children: [
              for (final (title, body) in _sections) ...[
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(body, style: const TextStyle(height: 1.7)),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
