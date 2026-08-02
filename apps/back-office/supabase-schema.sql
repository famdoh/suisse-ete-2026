-- À exécuter dans Supabase → SQL Editor. Peut être relancé sans risque
-- (tables via "if not exists", policies via "drop policy if exists" avant
-- chaque "create policy" puisque Postgres n'a pas de "create policy if not
-- exists").

-- Ordre d'affichage des espèces (arbres/arbustes/papillons) de l'app
-- flore-faune-camping, géré depuis le back-office. "species_id" correspond
-- à l'identifiant utilisé dans les ancres de flore-faune-camping (ex.
-- "alisier-blanc" pour la carte #act-alisier-blanc).

create table if not exists public.species_order (
  species_id text primary key,
  position smallint not null default 0,
  updated_at timestamptz not null default now()
);

alter table public.species_order enable row level security;

-- Lecture publique : l'app flore-faune-camping lit cet ordre pour tout le monde.
drop policy if exists "species_order_select_all" on public.species_order;
create policy "species_order_select_all"
  on public.species_order
  for select
  to anon
  using (true);

-- Écriture publique : le back-office est protégé par son propre code
-- d'accès côté app (pas d'authentification Supabase — app familiale de
-- confiance, comme les autres mini-apps du voyage).
drop policy if exists "species_order_insert_all" on public.species_order;
create policy "species_order_insert_all"
  on public.species_order
  for insert
  to anon
  with check (true);

drop policy if exists "species_order_update_all" on public.species_order;
create policy "species_order_update_all"
  on public.species_order
  for update
  to anon
  using (true)
  with check (true);

drop policy if exists "species_order_delete_all" on public.species_order;
create policy "species_order_delete_all"
  on public.species_order
  for delete
  to anon
  using (true);
