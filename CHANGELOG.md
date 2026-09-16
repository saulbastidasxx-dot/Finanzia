# Changelog

## 1.9.0-rc.6
- Tests de transferencias y pagos de tarjeta sin doble conteo.
- Cálculos de ahorro y tasa de ahorro.
- Retención de historial sync.
- Puerta final 1.0 documentada.

## 1.8.0-rc.5
- Privacidad persistente.
- Fechas editables en metas/deudas.
- Matriz QA y metadatos de tiendas.

## 1.7.0-rc.4
- Preferencias de alertas integradas realmente.
- Eliminación de cuenta reforzada.
- Auditoría RLS y preflight de release.

## 1.6.0-rc.3
- Detalle de tarjeta conectado desde Cuentas.
- Corregidos contratos FinanceAccount/destinationAccountId.
- Eliminación de cuenta mediante Edge Function autenticada.
- Limpieza local tras eliminación.
- Nuevas pruebas de contrato.

## 1.5.0-rc.2
- Pantalla detallada para tarjetas de crédito.
- Privacidad y términos accesibles dentro de la app.
- Modelo/base visual para estados offline y errores.
- Guías de accesibilidad y configuración segura de producción.
- Especificación segura de eliminación de cuenta.

## 1.4.0-rc.1
- Filtros avanzados de movimientos por cuenta, categoría y rango de fechas.
- Servicio de resumen de tarjetas de crédito.
- Checklist de privacidad, QA y publicación.
- Preparación de Release Candidate para Android, iOS y Web.

## 1.3.0-beta.1
- Filtros temporales en Reportes.
- Calendario recurrente editable y pausables.
- Gestor de categorías personalizadas.
- Utilización y disponible en tarjetas de crédito.
- Pulido responsive adicional.

## 0.7.0
- Sincronización automática con detección de conflictos.
- Tabla `sync_state` y revisión cloud por usuario.
- PIN de 4–6 dígitos con hash + salt.
- Desbloqueo biométrico en plataformas móviles compatibles.
- Bloqueo automático al salir de la app.
- Exportación CSV de movimientos.
- Documentación de configuración Android/iOS/Web.

## 0.8.0
- Nuevo Centro de Alertas financieras en web y móvil.
- Avisos automáticos cuando un presupuesto alcanza 80% o supera 100%.
- Avisos de pagos e ingresos recurrentes durante los próximos 7 días.
- Avisos de vencimientos de deudas durante los próximos 10 días.
- Priorización visual de alertas informativas, importantes y críticas.
- La lógica de alertas se calcula localmente y no requiere conexión a la nube.
- Base preparada para convertir estas alertas en notificaciones push/locales en una siguiente etapa.

## 0.9.0
- Sincronización incremental basada en eventos locales por registro.
- Detección de conflictos por entidad/registro mediante `sync_changes`.
- Fusión automática cuando dos dispositivos cambian registros diferentes.
- Historial local de hasta 250 cambios con estado sincronizado/pendiente.
- Reporte PDF A4 con resumen, cuentas, categorías y movimientos recientes.
- Notificaciones locales en Android/iOS para alertas importantes y críticas.
- Migración transparente desde el almacenamiento local `v4` al formato `v5`.
- Nueva documentación `docs/V09_SETUP.md` para Supabase y permisos móviles.

## 1.0.0-beta.1
- Onboarding inicial de tres pasos para nuevos usuarios.
- Preferencias configurables para alertas de presupuestos, pagos recurrentes y deudas.
- Métodos de actualización de cuentas y movimientos preparados para edición completa.
- Primer conjunto de pruebas automatizadas para reglas financieras y preferencias.
- Versión del paquete elevada a Beta 1.0.

## 1.1.0-beta.1 — Beta 1.1
- Edición completa de cuentas desde la interfaz.
- Edición completa de movimientos desde la interfaz.
- Confirmaciones de eliminación y protección de cuentas en uso.
- Validadores comunes para formularios y perfil.
- Estados vacíos reutilizables.
- Persistencia de preferencia de tema Claro/Oscuro/Automático.
- Activos fuente iniciales para icono y splash.
- Pruebas unitarias para validadores.
- Documentación de checklist de release Beta 1.1.


## 1.2.0-beta.1
- Planning CRUD completo para presupuestos, metas y deudas.
- Búsqueda y filtros de movimientos.
- Dashboard responsive mejorado.
- Validaciones y confirmaciones destructivas.
