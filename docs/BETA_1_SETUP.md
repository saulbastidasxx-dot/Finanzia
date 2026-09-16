# Finanzia Beta 1.0 — checklist

1. Instalar Flutter estable compatible con Dart >=3.3.
2. Ejecutar `flutter pub get`, `flutter analyze` y `flutter test`.
3. Configurar Supabase URL/anon key y aplicar las migraciones SQL incluidas en el proyecto.
4. Revisar permisos de notificaciones y biometría en Android/iOS.
5. Configurar applicationId/bundle identifier, iconos, splash y firma de release.
6. Probar onboarding, PIN/biometría, sincronización en dos dispositivos y resolución de conflictos.
7. Probar exportaciones CSV/PDF en Android, iOS y web.

No publicar en producción hasta completar las pruebas en dispositivos físicos.
