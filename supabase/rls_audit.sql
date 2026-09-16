-- RC10 staging RLS audit
select c.relname,c.relrowsecurity from pg_class c join pg_namespace n on n.oid=c.relnamespace
where n.nspname='public' and c.relname in ('profiles','accounts','transactions','budgets','goals','debts','recurring_payments','sync_state','sync_changes') order by c.relname;
select tablename,policyname,cmd,qual,with_check from pg_policies where schemaname='public'
and tablename in ('profiles','accounts','transactions','budgets','goals','debts','recurring_payments','sync_state','sync_changes') order by tablename;
-- With authenticated disposable users A/B: A creates rows; B must see/update/delete zero A rows and cannot insert/upsert using A user_id. Repeat reversed.
