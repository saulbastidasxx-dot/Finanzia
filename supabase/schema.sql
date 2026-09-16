-- Finanzia v0.5 · PostgreSQL/Supabase schema
create extension if not exists pgcrypto;
create table if not exists profiles (id uuid primary key references auth.users(id) on delete cascade, name text not null default '', currency text not null default 'USD', created_at timestamptz not null default now());
create table if not exists accounts (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, name text not null, type text not null check(type in ('bank','cash','creditCard','savings')), opening_balance numeric(14,2) not null default 0, credit_limit numeric(14,2), created_at timestamptz not null default now());
create table if not exists transactions (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, type text not null check(type in ('income','expense','transfer')), amount numeric(14,2) not null check(amount>0), category text not null, description text not null default '', account_id uuid not null references accounts(id) on delete cascade, destination_account_id uuid references accounts(id) on delete set null, occurred_at timestamptz not null default now());
create table if not exists budgets (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, category text not null, monthly_limit numeric(14,2) not null check(monthly_limit>=0));
create table if not exists goals (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, name text not null, target numeric(14,2) not null, current_amount numeric(14,2) not null default 0, target_date date);
create table if not exists debts (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, name text not null, balance numeric(14,2) not null, apr numeric(8,4) not null default 0, minimum_payment numeric(14,2) not null default 0, due_date date);
create table if not exists recurring_payments (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, name text not null, category text not null, account_id uuid not null references accounts(id) on delete cascade, amount numeric(14,2) not null, day_of_month int not null check(day_of_month between 1 and 31), is_expense boolean not null default true, active boolean not null default true);

alter table profiles enable row level security; alter table accounts enable row level security; alter table transactions enable row level security; alter table budgets enable row level security; alter table goals enable row level security; alter table debts enable row level security; alter table recurring_payments enable row level security;
do $$ declare t text; begin foreach t in array array['profiles','accounts','transactions','budgets','goals','debts','recurring_payments'] loop execute format('drop policy if exists own_rows on %I',t); execute format('create policy own_rows on %I for all using (auth.uid() = %s) with check (auth.uid() = %s)',t,case when t='profiles' then 'id' else 'user_id' end,case when t='profiles' then 'id' else 'user_id' end); end loop; end $$;

-- v0.6: crear perfil automáticamente al registrarse.
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin
  insert into public.profiles(id,name,currency) values(new.id,coalesce(new.raw_user_meta_data->>'name',''),'USD') on conflict(id) do nothing;
  return new;
end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

-- v0.7: estado de sincronización por usuario para detectar cambios y conflictos.
create table if not exists sync_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  revision bigint not null default 0,
  updated_at timestamptz not null default now()
);
alter table sync_state enable row level security;
drop policy if exists own_rows on sync_state;
create policy own_rows on sync_state for all using (auth.uid()=user_id) with check (auth.uid()=user_id);

-- v0.9: sincronización incremental registro por registro.
alter table accounts add column if not exists updated_at timestamptz not null default now();
alter table transactions add column if not exists updated_at timestamptz not null default now();
alter table budgets add column if not exists updated_at timestamptz not null default now();
alter table goals add column if not exists updated_at timestamptz not null default now();
alter table debts add column if not exists updated_at timestamptz not null default now();
alter table recurring_payments add column if not exists updated_at timestamptz not null default now();

create table if not exists sync_changes (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  entity text not null,
  entity_id text not null,
  action text not null check(action in ('upsert','delete','replace')),
  device_id text not null,
  changed_at timestamptz not null default now()
);
create index if not exists sync_changes_user_changed_idx on sync_changes(user_id,changed_at);
alter table sync_changes enable row level security;
drop policy if exists own_rows on sync_changes;
create policy own_rows on sync_changes for all using (auth.uid()=user_id) with check (auth.uid()=user_id);
