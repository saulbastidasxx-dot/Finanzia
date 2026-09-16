# Configuración segura de producción
## Supabase
No guardar `service_role` en la aplicación. El cliente solo debe usar la clave pública/anon o publishable correspondiente y RLS debe permanecer activa.

Recomendado:
```bash
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
flutter build appbundle --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```
Revisar el código para leer valores con `String.fromEnvironment`.

## Release
- Android: package/applicationId definitivo, keystore fuera del repositorio y Play App Signing.
- iOS: bundle ID definitivo, Team/Signing y capacidades necesarias.
- Web: HTTPS, headers de seguridad y redirects de autenticación permitidos.
- Separar proyectos Supabase de desarrollo y producción.
