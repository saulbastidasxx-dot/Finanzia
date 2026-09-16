# Finanzia Release Candidate 3
Versión `1.6.0-rc.3+16`

RC3 conecta el detalle de tarjeta desde Cuentas, corrige contratos `FinanceAccount`/`destinationAccountId`, añade eliminación de cuenta mediante Edge Function autenticada y limpia datos locales tras una eliminación exitosa.

Despliega `supabase/functions/delete-account/index.ts` como `delete-account`. La `SUPABASE_SERVICE_ROLE_KEY` debe existir solo como secreto del backend. Confirma `ON DELETE CASCADE` en las FK o elimina filas dependientes explícitamente.

Antes de 1.0 ejecuta `flutter pub get`, `flutter analyze`, `flutter test` y builds release de Web/Android; iOS debe validarse en macOS/Xcode. Prueba la eliminación con una cuenta de staging.
