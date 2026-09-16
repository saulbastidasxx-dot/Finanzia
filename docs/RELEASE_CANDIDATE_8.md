# Finanzia Release Candidate 8
Versión `2.1.0-rc.8+21`

## Segundo bloque de auditoría RC6
- PIN: verificador migrado a `flutter_secure_storage`; hash iterado, comparación constante y bloqueo temporal tras intentos fallidos.
- Sincronización automática: errores ya no se silencian; muestra estado pendiente, conflicto/error y reintento.
- Perfil: el cambio de correo usa Supabase Auth cuando existe sesión y solo actualiza el perfil local tras una respuesta correcta.
- Navegación móvil: 5 destinos principales y menú “Más”; escritorio conserva NavigationRail completo.
- Arranque: errores de inicialización ya no dejan spinner indefinido.
- Eliminación de cuenta: conserva datos locales si el backend falla y, tras éxito, elimina PIN/estado sensible y deduplicación de alertas. La Edge Function ahora maneja CORS/OPTIONS y devuelve etapas de fallo sin filtrar mensajes internos.
- Exportación CSV: ya no copia automáticamente rutas internas al portapapeles.

## Pendiente de validación real
Runners Flutter, builds, RLS dos usuarios, eliminación E2E, conflictos multidispositivo y QA de biometría/exportaciones/notificaciones siguen requiriendo CI/dispositivos reales.

## CI de runners faltantes
El workflow genera runners Android/Web en Ubuntu e iOS en macOS cuando no existen todavía en el repositorio, preservando `lib/`, tests y assets. Esto permite que GitHub Actions ejecute builds reales antes de integrar/firmar runners definitivos para publicación.
