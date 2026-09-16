# Finanzia v0.9 - configuración adicional

## Supabase
Ejecuta `supabase/schema.sql` en el SQL Editor. La sección v0.9 agrega `updated_at` y `sync_changes`, necesarios para sincronización incremental y detección de conflictos por registro.

## Notificaciones móviles
La v0.9 usa `flutter_local_notifications` para mostrar avisos locales de alertas importantes cuando Finanzia evalúa el Centro de Alertas.

### Android
En Android 13+ agrega `POST_NOTIFICATIONS` al `AndroidManifest.xml` si el proyecto generado por Flutter no lo incluye:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### iOS
La app solicita permisos de alertas, badge y sonido al activar avisos desde el Centro de Alertas.

> En esta versión los avisos se emiten al refrescar las alertas dentro de la app. La ejecución programada en segundo plano queda para la beta posterior.

## Reporte PDF
`pdf` genera un reporte A4 con patrimonio, ingresos, gastos, ahorro, cuentas, categorías y movimientos recientes. En web se descarga desde el navegador; en móvil/escritorio se guarda en documentos de la app.
