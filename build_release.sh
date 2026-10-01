#!/usr/bin/env bash
# بناء أصغر APK ممكن لمعمارية arm64 (أغلب الهواتف وأجهزة التلفاز الحديثة).
# لبناء لأجهزة قديمة 32 بت: استبدل android-arm64 بـ android-arm.
set -euo pipefail
flutter build apk --release --split-per-abi --target-platform android-arm64 \
  --obfuscate --split-debug-info=build/symbols --tree-shake-icons
ls -lh build/app/outputs/flutter-apk/*.apk
