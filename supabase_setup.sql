-- Gold Loan Control V4.0 - Supabase schema
-- Run this in Supabase Dashboard > SQL Editor > New query.
-- RLS ensures each signed-in user can access only their own rows.

create table if not exists public.gold_loans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  loan_no smallint not null check (loan_no in (1,2)),
  loan_name text not null,
  opening_balance numeric(14,2) not null default 0 check (opening_balance >= 0),
  monthly_rate numeric(6,3) not null default 1.170 check (monthly_rate >= 0),
  pawn_date date,
  due_date date,
  last_paid_date date,
  unpaid_interest numeric(14,2) not null default 0 check (unpaid_interest >= 0),
  verified boolean not null default false,
  updated_at timestamptz not null default now(),
  unique(user_id, loan_no)
);

create table if not exists public.gold_loan_payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  loan_no smallint not null check (loan_no in (1,2)),
  paid_date date not null,
  amount numeric(14,2) not null check (amount > 0),
  interest numeric(14,2) not null default 0 check (interest >= 0),
  fees numeric(14,2) not null default 0 check (fees >= 0),
  principal numeric(14,2) not null default 0 check (principal >= 0),
  balance_after numeric(14,2) not null default 0 check (balance_after >= 0),
  note text,
  is_historical boolean not null default false,
  client_order integer not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists gold_loan_payments_user_date_idx
on public.gold_loan_payments(user_id, paid_date);

create table if not exists public.gold_loan_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  monthly_budget numeric(14,2) not null default 70000 check (monthly_budget >= 0),
  updated_at timestamptz not null default now()
);

alter table public.gold_loans enable row level security;
alter table public.gold_loan_payments enable row level security;
alter table public.gold_loan_settings enable row level security;

drop policy if exists "Users manage own loans" on public.gold_loans;
create policy "Users manage own loans"
on public.gold_loans for all
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users manage own loan payments" on public.gold_loan_payments;
create policy "Users manage own loan payments"
on public.gold_loan_payments for all
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users manage own loan settings" on public.gold_loan_settings;
create policy "Users manage own loan settings"
on public.gold_loan_settings for all
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

grant select, insert, update, delete on public.gold_loans to authenticated;
grant select, insert, update, delete on public.gold_loan_payments to authenticated;
grant select, insert, update, delete on public.gold_loan_settings to authenticated;


-- Receipt image storage (private bucket).
alter table public.gold_loan_payments
  add column if not exists receipt_path text;

insert into storage.buckets (id, name, public)
values ('gold-loan-receipts', 'gold-loan-receipts', false)
on conflict (id) do nothing;

drop policy if exists "Users upload own gold loan receipts" on storage.objects;
create policy "Users upload own gold loan receipts"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'gold-loan-receipts'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users read own gold loan receipts" on storage.objects;
create policy "Users read own gold loan receipts"
on storage.objects for select to authenticated
using (
  bucket_id = 'gold-loan-receipts'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users delete own gold loan receipts" on storage.objects;
create policy "Users delete own gold loan receipts"
on storage.objects for delete to authenticated
using (
  bucket_id = 'gold-loan-receipts'
  and (storage.foldername(name))[1] = auth.uid()::text
);
