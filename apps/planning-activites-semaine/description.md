# Planning des activités

Planificateur de semaine mobile-first pour répartir les activités touristiques sur chaque journée du séjour (22 juillet - 1er août 2026). Le planning est **partagé entre tous les voyageurs** (stocké dans Supabase, voir ci-dessous) ; un cache localStorage permet un premier affichage instantané et un usage hors-ligne dégradé. Le front repolle le planning toutes les 10 secondes pour refléter les changements faits par les autres voyageurs sans recharger la page.

Chaque activité affichée (dans le planning d'un jour et dans le sélecteur d'ajout) montre la météo prévue du secteur géographique où elle se trouve, matin (9h) et soir (18h), pour la date du jour concerné. Ces prévisions sont pré-calculées (voir le skill `meteo-update`) et embarquées dans le fichier, comme le reste des données de l'app.

Chacun peut aussi noter les activités de 1 à 3 étoiles ; la moyenne des notes de tous les voyageurs s'affiche pour chaque activité (dans le sélecteur d'activités et dans le planning des jours). L'identité du votant est un simple prénom saisi une fois et mémorisé sur l'appareil (pas d'authentification).

Une deuxième page, `classement.html`, accessible via le lien « 🏆 Classement des activités » sur la page principale, liste toutes les activités triées par moyenne de note décroissante, avec le détail des votes de chaque voyageur ayant noté.

## Dépendances datasource
- datasource/activites.md
- datasource/meteo.json (prévisions météo par secteur géographique, régénéré par le skill `meteo-update` — voir `.claude/skills/meteo-update/SKILL.md`)

## Dépendance externe : Supabase
Les notes et le planning partagé sont stockés dans des tables Postgres d'un même projet Supabase, interrogées directement depuis le navigateur via le client `@supabase/supabase-js` (CDN) et la clé publique `anon`/`publishable`, avec des policies RLS. L'app reste statique : aucun backend ni build n'est nécessaire.
- `activity_ratings` : notes 1-3 étoiles par activité/voyageur.
- `activity_plan` : affectation des activités aux jours (`day_date`, `activity_id`, `position`), partagée par tous les voyageurs — c'est la source de vérité du planning, lue au chargement puis toutes les 10s, et écrite à chaque ajout/retrait/réordonnancement.
- Schéma SQL à exécuter dans le SQL Editor Supabase : `apps/planning-activites-semaine/supabase-schema.sql`
- Projet Supabase : `hmpiluotdcympkihvnlt` (URL : `https://hmpiluotdcympkihvnlt.supabase.co`)
