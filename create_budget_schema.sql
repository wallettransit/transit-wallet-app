create table public.budgets (
    budget_id           uuid primary key default gen_random_uuid(),
    passenger_id          uuid not null references public.users(id),
    amount_kobo           bigint not null check (amount_kobo > 0),
    period_start           date not null,
    period_end             date not null,
    highest_threshold_notified  int not null default 0,   -- 0, 50, 80, or 100 — enforces alert idempotency
    is_active              boolean not null default true,
    created_at             timestamptz not null default now()
);
create index idx_budgets_passenger_active on public.budgets(passenger_id) where is_active;

-- Spend is always computed live, never stored redundantly:
create or replace function public.fn_budget_progress(p_budget_id uuid)
returns table (spent_kobo bigint, pct_used numeric)
language sql security definer set search_path = public
as $$
    select
        coalesce(sum(t.amount_kobo), 0) as spent_kobo,
        round(coalesce(sum(t.amount_kobo), 0)::numeric
              / nullif((select amount_kobo from public.budgets where budget_id = p_budget_id), 0) * 100, 1) as pct_used
    from public.transactions t
    join public.wallets w on w.id = t.from_wallet_id
    join public.budgets b on b.budget_id = p_budget_id
    where w.user_id = b.passenger_id
      and t.type = 'ride_payment'
      and t.status = 'completed'
      and t.created_at::date between b.period_start and b.period_end;
$$;

grant execute on function public.fn_budget_progress(uuid) to authenticated;
