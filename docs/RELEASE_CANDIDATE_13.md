# Finanzia RC13
Versión `2.6.0-rc.13+26`.

Correcciones basadas en GitHub Actions RC12:
- `anonKey` migrado a `publishableKey`.
- `DropdownButtonFormField.value` migrado a `initialValue` en las pantallas señaladas.
- Imports sin uso eliminados de Settings.
- UUID namespace migrado desde `NAMESPACE_URL`.
- PDF migra a `TableHelper.fromTextArray`.
- Implementaciones condicionales Web documentan/suprimen el lint web-only exclusivamente en esos archivos.
- Se añaden llaves a estructuras de control señaladas por analyzer.
- CI aplica `dart format` antes de analyze.

Objetivo de la siguiente ejecución: que `flutter analyze` avance a cero incidencias y permita ejecutar tests/builds reales.
