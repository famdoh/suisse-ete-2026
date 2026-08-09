# Planning des activités

Planificateur de semaine mobile-first pour répartir les activités touristiques sur chaque journée du séjour (22 juillet - 1er août 2026). Le planning est **partagé entre tous les voyageurs** (stocké dans Supabase, voir ci-dessous) ; un cache localStorage permet un premier affichage instantané et un usage hors-ligne dégradé. Le front repolle le planning toutes les 10 secondes pour refléter les changements faits par les autres voyageurs sans recharger la page.

Chacun peut aussi noter les activités de 1 à 3 étoiles ; la moyenne des notes de tous les voyageurs s'affiche pour chaque activité (dans le sélecteur d'activités et dans le planning des jours). L'identité du votant est un simple prénom saisi une fois et mémorisé sur l'appareil (pas d'authentification).

Chaque activité affectée à un jour a sa propre ancre et un bouton pour copier un lien direct vers cette carte (voir « Ancres et partage de lien vers une activité » dans `AGENTS.md`).

Une deuxième page, `classement.html`, accessible via le lien « 🏆 Classement des activités » sur la page principale, liste toutes les activités triées par moyenne de note décroissante, avec le détail des votes de chaque voyageur ayant noté.

## Dépendances datasource
- datasource/activites.md

## Dépendance externe : Supabase
Les notes et le planning partagé sont stockés dans des tables Postgres d'un même projet Supabase, interrogées directement depuis le navigateur via le client `@supabase/supabase-js` (CDN) et la clé publique `anon`/`publishable`, avec des policies RLS. L'app reste statique : aucun backend ni build n'est nécessaire.
- `activity_ratings` : notes 1-3 étoiles par activité/voyageur. **Table globale**, partagée avec l'app `activites-loisirs` — définie dans le schéma global `datasource/supabase-schema.sql`, pas dans celui de cette app.
- `activity_plan` : affectation des activités aux jours (`day_date`, `activity_id`, `position`), partagée par tous les voyageurs — c'est la source de vérité du planning, lue au chargement puis toutes les 10s, et écrite à chaque ajout/retrait/réordonnancement. Propre à cette app.
- Schémas SQL à exécuter dans le SQL Editor Supabase, dans cet ordre : `datasource/supabase-schema.sql` (global), puis `apps/planning-activites-semaine/supabase-schema.sql`
- Projet Supabase : `hmpiluotdcympkihvnlt` (URL : `https://hmpiluotdcympkihvnlt.supabase.co`)
