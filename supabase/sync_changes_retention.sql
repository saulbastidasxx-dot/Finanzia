-- Finanzia RC6: ejecutar del lado servidor.
create or replace function public.prune_sync_changes() returns integer language plpgsql security definer set search_path=public as $$ declare n integer; begin delete from public.sync_changes where changed_at < now() - interval '90 days'; get diagnostics n=row_count; return n; end; $$;
revoke all on function public.prune_sync_changes() from public, anon, authenticated;
