# Back-office

Espace d'administration protégé par un code d'accès, permettant de gérer
certaines configurations et certains contenus des mini-apps du voyage,
d'observer les données saisies par tout le monde et de les exporter en CSV.

**Code d'accès** : `marmotte` (à saisir sur l'écran de verrouillage, comme
pour l'app Dépenses partagées).

## Fonctionnalités

- **Configuration — Ordre des espèces (Flore & Faune)** : réordonner (▲/▼)
  les fiches arbres/arbustes/papillons affichées par l'app
  `flore-faune-camping`, et enregistrer cet ordre dans Supabase (table
  `species_order`). L'app `flore-faune-camping` lit cette table au
  chargement pour afficher ses fiches dans cet ordre (ordre par défaut du
  HTML si aucune donnée n'est enregistrée).
- **Observation & export CSV** : pour chaque table Supabase partagée par les
  mini-apps du voyage, affichage en lecture seule des lignes enregistrées
  (avec rafraîchissement manuel) et bouton d'export au format CSV :
  `expenses`, `expense_members`, `activity_ratings`, `activity_plan`,
  `species_order`.

Ce back-office est le premier cas d'usage d'un espace d'administration
commun aux mini-apps ; il est conçu pour accueillir d'autres configs de
contenu à l'avenir (nouvelle section = nouvelle carte dans la page).

## Dépendances datasource

- Table Supabase `species_order` (créée par
  `apps/back-office/supabase-schema.sql`), également lue par
  `apps/flore-faune-camping` pour l'ordre d'affichage de ses fiches.
- Lecture seule des tables Supabase créées par `apps/depenses-partagees`
  (`expenses`, `expense_members`) et `apps/planning-activites-semaine`
  (`activity_ratings`, `activity_plan`) — ce back-office ne modifie pas
  leur schéma, il fournit uniquement leur `supabase-schema.sql` respectif
  comme source de vérité pour ces tables.
