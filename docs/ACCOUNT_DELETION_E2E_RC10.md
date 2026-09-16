# Eliminación de cuenta · E2E RC10
Staging, cuenta desechable: poblar todas las tablas; invocar `delete-account`; exigir HTTP 200; verificar cero filas públicas y ausencia en auth.users; verificar limpieza local; probar retry tras fallo intermedio; verificar OPTIONS/CORS; sin Authorization debe dar 401; método no permitido debe dar 405. No marcar aprobado hasta ejecución real.
