-- À exécuter une fois dans Supabase → SQL Editor.
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
create policy "activity_ratings_select_all"
  on public.activity_ratings
  for select
  to anon
  using (true);

-- Écriture publique : chacun peut ajouter sa propre note (app familiale de confiance,
-- pas d'authentification). L'unicité (activity_id, voter_name) empêche les doublons.
create policy "activity_ratings_insert_all"
  on public.activity_ratings
  for insert
  to anon
  with check (true);

-- Mise à jour publique : permet de changer sa note existante (upsert).
create policy "activity_ratings_update_all"
  on public.activity_ratings
  for update
  to anon
  using (true)
  with check (true);
