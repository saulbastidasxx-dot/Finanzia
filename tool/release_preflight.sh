#!/usr/bin/env bash
set -euo pipefail
command -v flutter >/dev/null || { echo "Flutter SDK no encontrado"; exit 2; }
flutter pub get
flutter analyze
flutter test
flutter build web --release
flutter build appbundle --release
echo "Android/Web preflight completado. iOS: flutter build ipa --release en macOS."
