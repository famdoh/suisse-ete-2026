# Activités & Loisirs

Catalogue statique des 19 activités et sorties à proximité du Camping
Bella-Tola (Susten, Valais), du plus proche au plus lointain, avec pour
chacune un lien vers son site web officiel. Extraite de l'onglet
« Activités Loisirs » de l'app CampMenu Suisse (renommée « Repas en
Suisse ») pour devenir une app à part entière.

Chacun peut aussi noter les activités de 1 à 3 étoiles, avec le même
système que l'app `planning-activites-semaine` : mêmes identifiants
d'activité, même table Supabase (les notes sont donc partagées entre
les deux apps), et même clé de stockage local pour le prénom du
votant (`planning_activites_voter_suisse_2026`) — sur GitHub Pages, où
les deux apps partagent la même origine, le prénom choisi dans l'une
est donc automatiquement reconnu dans l'autre. Un lien « 🏆 Classement
des activités » pointe vers `../planning-activites-semaine/classement.html`
(classement par note moyenne décroissante, partagé lui aussi).

Une carte (Leaflet/OpenStreetMap) centrée sur le camping situe les 19
activités ; chaque marqueur et chaque carte d'activité ont un lien
« 🗺️ Itinéraire depuis le camping » (Google Maps, calculé à partir du
nom du lieu — pas besoin de coordonnées précises pour la navigation
réelle, seul l'aperçu sur la carte utilise des coordonnées approximatives).

## Dépendances datasource
- datasource/activites.md

## Dépendance externe : Supabase
Les notes sont stockées dans la même table Postgres `activity_ratings`
que l'app `planning-activites-semaine`, interrogée directement depuis
le navigateur via le client `@supabase/supabase-js` (CDN) et la clé
publique `anon`/`publishable`. L'app reste statique : aucun backend ni
build n'est nécessaire.
- Projet Supabase : `hmpiluotdcympkihvnlt` (URL : `https://hmpiluotdcympkihvnlt.supabase.co`)

## Dépendance externe : Leaflet / OpenStreetMap
La carte utilise la librairie Leaflet (CDN unpkg.com) et les tuiles
OpenStreetMap (tile.openstreetmap.org), sans clé API. Comme pour
Supabase, ces requêtes CDN sont bloquées par la CSP d'un Artifact
Claude : la carte (et la notation) ne s'affichent donc que sur le
déploiement GitHub Pages, pas dans l'Artifact.
