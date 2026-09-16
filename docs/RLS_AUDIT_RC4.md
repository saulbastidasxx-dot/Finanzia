# Auditoría RLS — RC4
El schema incluido usa `ON DELETE CASCADE` desde las tablas financieras principales hacia `auth.users`.
Antes de producción: confirma RLS en profiles, accounts, transactions, budgets, goals, debts, recurring_payments, sync_state y sync_changes; prueba aislamiento con dos usuarios de staging; mantén `SUPABASE_SERVICE_ROLE_KEY` solo en backend/Edge Functions.
