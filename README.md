# Finanzia Beta 1.1

Aplicación de finanzas personales premium/minimalista en Flutter para web, Android e iOS.

## Incluye
- Dashboard con patrimonio, ingresos, gastos, ahorro y cuentas.
- Ingresos, gastos y transferencias sin doble contabilización.
- Creación **y edición** de cuentas y movimientos con validaciones.
- Confirmación segura antes de eliminar y protección para cuentas con movimientos.
- Cuentas, tarjetas, presupuestos, metas, deudas, calendario y reportes.
- Tema Claro / Oscuro / Automático **persistente**.
- Supabase Auth + PostgreSQL/RLS.
- Sincronización incremental por registro con detección de conflictos.
- Historial local de cambios y estado pendiente/sincronizado.
- PIN y biometría en plataformas compatibles.
- Exportación CSV y reporte PDF A4.
- Centro de Alertas y notificaciones locales Android/iOS.
- Onboarding y preferencias de alertas.
- Estados vacíos orientados a acciones.
- Activos iniciales de icono/splash en `assets/branding/`.
- Pruebas automatizadas de reglas financieras, preferencias y validadores.

## Ejecutar
1. Instala Flutter estable.
2. Ejecuta `flutter pub get`.
3. Web: `flutter run -d chrome`.
4. Android/iOS: integra/configura los runners de plataforma y sigue `docs/PLATFORM_SETUP.md`, `docs/V09_SETUP.md` y `docs/BETA_1_1_SETUP.md`.

## Supabase
Finanzia funciona en modo local sin Supabase. Para sincronización, configura URL/anon key y ejecuta `supabase/schema.sql` completo.

## Importante antes de publicar
Este paquete es código fuente Beta. En un equipo con Flutter SDK deben ejecutarse `flutter analyze` y `flutter test`, y deben configurarse firma, Bundle ID/Application ID, permisos, privacidad, Supabase de producción y builds Release.


## Beta 1.2
- Edición y eliminación confirmada de presupuestos, metas y deudas.
- Búsqueda y filtros por tipo en Movimientos.
- Dashboard responsive con indicador de ahorro mensual.
- Estados vacíos y validaciones reforzadas en Planificación.
- Versión interna: `1.9.0-rc.6+19`.


## Beta 1.3
Filtros de reportes por período, calendario recurrente editable, categorías personalizadas y visualización de utilización de tarjetas. Consulta `docs/BETA_1_3_SETUP.md`.


## Release Candidate 1
Incluye filtros avanzados y documentación de QA/publicación. Revisa `docs/RELEASE_CANDIDATE_1.md` y `docs/PRIVACY_DATA_CHECKLIST.md` antes de distribuir.


## Release Candidate 2
Cierre de experiencia de tarjetas, legal/privacidad, offline/error y documentación de producción. Consulta `docs/RELEASE_CANDIDATE_2.md`.


## Release Candidate 3
Cierre de tarjetas, contratos y eliminación segura de cuenta. Consulta `docs/RELEASE_CANDIDATE_3.md`.


## Release Candidate 4
Cierre de alertas, eliminación, RLS y preflight. Consulta `docs/RELEASE_CANDIDATE_4.md`.


## Release Candidate 5
Pulido de privacidad, planificación y preparación QA/tiendas.


## Release Candidate 6
Cierre financiero y de sincronización previo a 1.0. Consulta `docs/FINAL_1_0_GATE.md`.


## Release Candidate 8
Segundo bloque de endurecimiento de seguridad, sincronización y UX. Consulta `docs/RELEASE_CANDIDATE_8.md`.
\n\n## Release Candidate 9\nExportaciones móviles compartibles, calendario recurrente reforzado y deduplicación de notificaciones.\n

## Release Candidate 10
Endurecimiento de sincronización, RLS, CI y gates E2E de eliminación de cuenta.


## Release Candidate 11
Reintentos controlados de sincronización y cierre de gates de producción. Consulta `docs/PRODUCTION_READINESS_RC11.md`.
