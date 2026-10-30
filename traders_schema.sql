-- Independent Traders module for Aurea Vietnam. Applied 2026-10-30.
create table if not exists public.vietnam_trader_operations (
 id uuid primary key default gen_random_uuid(), trade_number text not null unique,
 trade_date date not null, currency text not null default 'USD' check(currency ~ '^[A-Z]{3}$'),
 status text not null default 'draft', details jsonb not null default '{}'::jsonb,
 version integer not null default 0, created_at timestamptz not null default now()
);
alter table public.vietnam_trader_operations enable row level security;
grant select,insert,update,delete on public.vietnam_trader_operations to authenticated;
do $$ begin
if not exists(select 1 from pg_policies where schemaname='public' and tablename='vietnam_trader_operations' and policyname='vietnam_traders_read') then
 create policy vietnam_traders_read on public.vietnam_trader_operations for select to authenticated using(exists(select 1 from public.vietnam_members m where m.user_id=(select auth.uid())));
 create policy vietnam_traders_create on public.vietnam_trader_operations for insert to authenticated with check(exists(select 1 from public.vietnam_members m where m.user_id=(select auth.uid())));
 create policy vietnam_traders_edit on public.vietnam_trader_operations for update to authenticated using(exists(select 1 from public.vietnam_members m where m.user_id=(select auth.uid()))) with check(exists(select 1 from public.vietnam_members m where m.user_id=(select auth.uid())));
 create policy vietnam_traders_delete on public.vietnam_trader_operations for delete to authenticated using(exists(select 1 from public.vietnam_members m where m.user_id=(select auth.uid()) and m.role='admin'));
end if; end $$;
