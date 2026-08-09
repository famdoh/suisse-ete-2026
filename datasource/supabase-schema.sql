-- Schéma Supabase GLOBAL du séjour « Suisse Été 2026 ».
--
-- Ce fichier définit les tables partagées par plusieurs mini-apps, qui
-- n'appartiennent donc à aucune app en particulier. Les tables utilisées par
-- une seule app restent dans son propre
-- `apps/<nom-app>/supabase-schema.sql`.
--
-- Ordre d'exécution pour (re)créer un environnement complet :
--   1. ce fichier (tables globales) ;
--   2. puis chaque `apps/<nom-app>/supabase-schema.sql`.
--
-- À exécuter dans Supabase → SQL Editor, ou directement via le MCP Supabase
-- (voir « Convention Supabase » dans AGENTS.md). Peut être relancé sans
-- risque : tables via "if not exists", policies via "drop policy if exists"
-- avant chaque "create policy" puisque Postgres n'a pas de
-- "create policy if not exists".

-- ---------------------------------------------------------------------------
-- activity_ratings — notes 1 à 3 étoiles données par chaque voyageur à chaque
-- activité touristique de `datasource/activites.md`.
--
-- Table globale : partagée par `planning-activites-semaine` (sélecteur
-- d'activités, planning du jour et page `classement.html`) et par
-- `activites-loisirs` (catalogue), qui utilisent les mêmes `activity_id` et
-- la même clé localStorage pour le prénom du votant. Une note saisie dans une
-- app est donc immédiatement visible dans l'autre.
-- ---------------------------------------------------------------------------

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
