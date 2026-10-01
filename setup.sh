#!/usr/bin/env bash
# يولّد ملفات Android الأساسية (Gradle) بواسطة Flutter ثم يطبق تعديلات التلفاز.
# الاستخدام:  bash setup.sh
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter غير مثبت أو غير موجود في PATH" >&2
  exit 1
fi

BACKUP="$(mktemp -d)"
cp -r lib pubspec.yaml analysis_options.yaml test "$BACKUP"/

flutter create --platforms=android --org com.bath --project-name bath_tv .

# استرجاع ملفات المشروع الأصلية (flutter create قد يستبدلها بقوالب افتراضية)
rm -rf lib test
cp -r "$BACKUP"/lib lib
cp -r "$BACKUP"/test test
cp "$BACKUP"/pubspec.yaml pubspec.yaml
cp "$BACKUP"/analysis_options.yaml analysis_options.yaml

# تعديلات Android TV: Manifest وMainActivity (كشف التلفاز)
rm -f android/app/src/main/java/com/bath/bath_tv/MainActivity.java
cp -r android_overrides/app android/

# تصغير حجم APK: ضغط المكتبات الأصلية داخل الحزمة + R8 الكامل
python3 -c "
import os
for path in ['android/app/build.gradle.kts', 'android/app/build.gradle']:
    if os.path.exists(path):
        with open(path, 'r') as f:
            c = f.read()
        if 'useLegacyPackaging' not in c and 'android {' in c:
            c = c.replace('android {', 'android {\n    packaging { jniLibs { useLegacyPackaging = true } }', 1)
            with open(path, 'w') as f:
                f.write(c)
        break
" || true
echo "android.enableR8.fullMode=true" >> android/gradle.properties || true

flutter pub get
echo
echo "تم الإعداد. للتشغيل:  flutter run"
echo "لبناء APK صغير:        bash build_release.sh"
