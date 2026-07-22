# Planning des activités

Planificateur de semaine mobile-first pour répartir les activités touristiques sur chaque journée du séjour (22 juillet - 1er août 2026). Le planning de l'utilisateur est mémorisé automatiquement et retrouvé à chaque visite.

Chacun peut aussi noter les activités de 1 à 3 étoiles ; la moyenne des notes de tous les voyageurs s'affiche pour chaque activité (dans le sélecteur d'activités et dans le planning des jours). L'identité du votant est un simple prénom saisi une fois et mémorisé sur l'appareil (pas d'authentification).

## Dépendances datasource
- datasource/activites.md

## Dépendance externe : Supabase
Les notes sont stockées dans une table Postgres `activity_ratings` d'un projet Supabase, interrogée directement depuis le navigateur via le client `@supabase/supabase-js` (CDN) et la clé publique `anon`/`publishable`, avec des policies RLS restreignant l'accès à cette seule table. L'app reste statique : aucun backend ni build n'est nécessaire.
- Schéma SQL à exécuter dans le SQL Editor Supabase : `apps/planning-activites-semaine/supabase-schema.sql`
- Projet Supabase : `hmpiluotdcympkihvnlt` (URL : `https://hmpiluotdcympkihvnlt.supabase.co`)
