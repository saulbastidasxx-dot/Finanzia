# Secretos y variables de entorno

Flutter solo debe recibir `SUPABASE_URL` y la clave pública/publishable/anon correspondiente mediante `--dart-define` o CI secrets.

Nunca incluir `SUPABASE_SERVICE_ROLE_KEY` en Flutter, Web, APK/AAB, IPA, repositorio o archivos `.env` versionados.

La service-role solo puede existir en infraestructura backend segura, por ejemplo Edge Functions/Supabase server-side.
