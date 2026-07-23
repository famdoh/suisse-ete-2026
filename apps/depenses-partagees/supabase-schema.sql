-- À exécuter dans Supabase → SQL Editor. Peut être relancé sans risque
-- (tables via "if not exists", policies via "drop policy if exists" avant
-- chaque "create policy" puisque Postgres n'a pas de "create policy if not
-- exists").

-- Liste partagée des participants du séjour pouvant payer ou partager une
-- dépense. Alimentée automatiquement (prénom choisi par chacun) et/ou
-- manuellement depuis l'app.

create table if not exists public.expense_members (
  name text primary key,
  created_at timestamptz not null default now()
);

alter table public.expense_members enable row level security;

drop policy if exists "expense_members_select_all" on public.expense_members;
create policy "expense_members_select_all"
  on public.expense_members
  for select
  to anon
  using (true);

drop policy if exists "expense_members_insert_all" on public.expense_members;
create policy "expense_members_insert_all"
  on public.expense_members
  for insert
  to anon
  with check (true);

drop policy if exists "expense_members_delete_all" on public.expense_members;
create policy "expense_members_delete_all"
  on public.expense_members
  for delete
  to anon
  using (true);

-- Dépenses du séjour : qui a payé, combien, pour quel motif, et entre qui
-- la dépense est partagée ("participants" est un instantané des prénoms au
-- moment de la saisie, indépendant d'une future suppression du participant
-- dans expense_members).

create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  payer_name text not null,
  amount numeric(10,2) not null check (amount > 0),
  motif text not null,
  participants jsonb not null default '[]'::jsonb,
  added_by text
);

alter table public.expenses enable row level security;

-- Lecture publique : tout le monde voit toutes les dépenses (nécessaire pour
-- calculer les soldes et les remboursements).
drop policy if exists "expenses_select_all" on public.expenses;
create policy "expenses_select_all"
  on public.expenses
  for select
  to anon
  using (true);

-- Écriture publique : chacun peut ajouter une dépense (app familiale de
-- confiance, pas d'authentification — seul un mot de passe partagé côté
-- app protège l'accès général).
drop policy if exists "expenses_insert_all" on public.expenses;
create policy "expenses_insert_all"
  on public.expenses
  for insert
  to anon
  with check (true);

-- Suppression publique : permet de corriger une erreur de saisie.
drop policy if exists "expenses_delete_all" on public.expenses;
create policy "expenses_delete_all"
  on public.expenses
  for delete
  to anon
  using (true);
