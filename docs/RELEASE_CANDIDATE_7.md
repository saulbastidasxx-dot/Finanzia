# Finanzia RC7 — correcciones de auditoría

Versión `2.0.0-rc.7+20`.

## Corregido en código
- P0-02: `upload()` ya no borra tablas remotas antes de reinsertar. El snapshot es no destructivo y las eliminaciones siguen el canal incremental.
- P1-06: cada tarjeta puede guardar `statementDay` y `dueDay`; esquema, sync, editor y cálculo actualizados.
- P1-07/P1-08: PDF usa gastos del mes actual y ordena movimientos por fecha descendente.
- P2-02: eliminadas condiciones duplicadas del motor de alertas.
- P1-12: `analysis_options.yaml` activa `flutter_lints`.
- P1-14: workflow de GitHub Actions para pub get, analyze, test, Web release y Android AAB.
- Limpieza: eliminado `zzz`; `.env.example` permanece sin secretos.

## Bloqueos que NO se declaran resueltos
- P0-01: faltan runners Android/iOS/Web; deben generarse con Flutter SDK y luego configurarse plugins/permisos.
- P0-03: RLS requiere prueba real con dos usuarios Supabase.
- P0-04: eliminación de cuenta requiere prueba E2E real y estrategia explícita ante fallo parcial.
- P1-01/P1-02: almacenamiento seguro y rate limiting de PIN requieren implementación/validación multiplataforma.
- P1-03/P1-04/P1-05/P1-09/P1-10/P1-11/P1-13/P1-15 y QA P2 siguen abiertos o parciales.

RC7 no es producción hasta que CI/builds y QA de staging estén verdes.
