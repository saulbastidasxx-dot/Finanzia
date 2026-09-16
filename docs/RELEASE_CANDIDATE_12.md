# Finanzia RC12
Versión `2.5.0-rc.12+25`.

Correcciones basadas en el primer GitHub Actions real:
- Supabase `signUp`: `userMetadata` corregido a `data`.
- Movimientos: restaurados filtros avanzados por cuenta, categoría y rango de fechas.
- SecurityService: derivación usa `List<int>` compatible con el resultado de SHA-256.
- Se incluye `test/widget_test.dart` para impedir que `flutter create` genere el test obsoleto que referencia `MyApp`.
- El paso de formato deja de bloquear analyze/tests/builds; sigue ejecutándose para informar cambios.

Pendiente: volver a ejecutar GitHub Actions y corregir la siguiente capa según logs reales.
