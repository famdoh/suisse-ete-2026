-- À exécuter dans Supabase → SQL Editor. Peut être relancé sans risque
-- (tables via "if not exists", policies via "drop policy if exists" avant
-- chaque "create policy" puisque Postgres n'a pas de "create policy if not
-- exists").

-- Table des notes (1 à 3 étoiles) données par chaque voyageur à chaque activité.

create table if not exists public.activity_ratings (
  id uuid primary key default gen_random_uuid(),
  activity_id text not null,
  voter_name text not null,
  rating smallint not null check (rating between 1 and 3),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (activity_id, voter_name)
);

alter table public.activity_ratings enable row level security;

-- Lecture publique : tout le monde peut voir toutes les notes (pour calculer la moyenne).
drop policy if exists "activity_ratings_select_all" on public.activity_ratings;
create policy "activity_ratings_select_all"
  on public.activity_ratings
  for select
  to anon
  using (true);

-- Écriture publique : chacun peut ajouter sa propre note (app familiale de confiance,
-- pas d'authentification). L'unicité (activity_id, voter_name) empêche les doublons.
drop policy if exists "activity_ratings_insert_all" on public.activity_ratings;
create policy "activity_ratings_insert_all"
  on public.activity_ratings
  for insert
  to anon
  with check (true);

-- Mise à jour publique : permet de changer sa note existante (upsert).
drop policy if exists "activity_ratings_update_all" on public.activity_ratings;
create policy "activity_ratings_update_all"
  on public.activity_ratings
  for update
  to anon
  using (true)
  with check (true);

-- Table du planning : quelles activités sont affectées à quel jour, partagée
-- entre tous les voyageurs (un seul planning commun, pas un par appareil).
-- "position" fixe l'ordre des activités affichées dans le jour.

create table if not exists public.activity_plan (
  day_date date not null,
  activity_id text not null,
  position smallint not null default 0,
  updated_at timestamptz not null default now(),
  primary key (day_date, activity_id)
);

alter table public.activity_plan enable row level security;

-- Lecture publique : tout le monde voit le planning commun.
drop policy if exists "activity_plan_select_all" on public.activity_plan;
create policy "activity_plan_select_all"
  on public.activity_plan
  for select
  to anon
  using (true);

-- Écriture publique : chacun peut ajouter des activités au planning commun
-- (app familiale de confiance, pas d'authentification).
drop policy if exists "activity_plan_insert_all" on public.activity_plan;
create policy "activity_plan_insert_all"
  on public.activity_plan
  for insert
  to anon
  with check (true);

-- Mise à jour publique : permet de réordonner les activités d'un jour.
drop policy if exists "activity_plan_update_all" on public.activity_plan;
create policy "activity_plan_update_all"
  on public.activity_plan
  for update
  to anon
  using (true)
  with check (true);

-- Suppression publique : permet de retirer une activité ou de réinitialiser
-- le planning commun.
drop policy if exists "activity_plan_delete_all" on public.activity_plan;
create policy "activity_plan_delete_all"
  on public.activity_plan
  for delete
  to anon
  using (true);
