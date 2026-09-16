# Finanzia Beta 1.3 — checklist
Versión: `1.3.0-beta.1+13`

Prueba especialmente:
- Reportes: Este mes / 3 meses / Este año / Todo.
- Calendario: crear, editar y pausar recurrentes.
- Categorías: crear y protección al eliminar categorías en uso.
- Tarjetas: límite, disponible y utilización.
- Claro / Oscuro / Automático en web y móvil.

Validación recomendada:
```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
flutter build web --release
flutter build appbundle --release
```
Para iOS, validar y compilar en macOS con Xcode y firma configurada.
