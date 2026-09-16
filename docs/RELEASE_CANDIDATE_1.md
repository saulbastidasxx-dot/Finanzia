# Finanzia Release Candidate 1
Versión `1.4.0-rc.1+14`

## QA obligatorio
1. Ejecutar `flutter pub get`, `flutter analyze` y `flutter test`.
2. Probar Android/iOS/Web en Claro, Oscuro y Automático.
3. Verificar registro, login, recuperación, sincronización y conflicto.
4. Probar filtros de movimientos por texto, tipo, cuenta, categoría y fechas.
5. Validar tarjetas: límite, deuda, disponible y utilización.
6. Verificar PDF/CSV, notificaciones, PIN/biometría y onboarding.
7. Revisar accesibilidad: tamaño de texto, contraste, lector de pantalla y targets táctiles.

## Builds
```bash
flutter build web --release
flutter build appbundle --release
flutter build apk --release
```
iOS requiere macOS + Xcode:
```bash
flutter build ipa --release
```

## Antes de tiendas
- Sustituir identificadores de paquete de desarrollo.
- Configurar firma Android y certificados/provisioning iOS.
- Configurar URLs/keys de Supabase mediante variables de entorno seguras.
- Crear política de privacidad, términos, URL de soporte y proceso de eliminación de cuenta.
- Preparar screenshots y metadatos de Google Play/App Store.
