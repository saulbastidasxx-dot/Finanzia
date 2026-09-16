# RC14 · corrección dirigida de CI

Este parche mantiene RC14 como base y corrige únicamente fallos observados en el run #4.

- `credit_card_cycle_rc7_test.dart`: el test ahora registra la tarjeta en `FinanceStore` antes de calcular el resumen; el fallo anterior provenía de `balanceFor()` al buscar una cuenta que el propio test no había agregado.
- `retry_policy_test.dart`: el test ahora espera correctamente el `Future` con `expectLater`; antes comprobaba el contador antes de que terminara el segundo intento asíncrono.
- `widget_test.dart`: verifica la construcción real de `MaterialApp` en lugar de exigir un texto visible durante la pantalla de carga inicial.
- CI: `flutter analyze --no-fatal-infos` mantiene errores y warnings como bloqueantes, pero no convierte sugerencias `info` de lint en fallo del pipeline.
- CI: la comprobación de formato ya no modifica el workspace; usa `--output=none --set-exit-if-changed`.

No se declara el CI aprobado hasta ejecutar nuevamente GitHub Actions y revisar el resultado completo.
