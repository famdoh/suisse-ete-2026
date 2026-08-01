# Dépenses partagées

Chacun note ses dépenses du séjour (montant, motif, qui a payé, entre qui
elle est partagée) ; l'app calcule en temps réel le solde de chaque
participant et propose, en fin de séjour, le nombre minimal de
remboursements pour que tout le monde soit à l'équilibre (« qui doit
combien à qui »). Chaque dépense peut être modifiée ou supprimée après
coup (bouton « Modifier »/« Supprimer » sur chaque ligne), pour corriger
une erreur de saisie. Une date (optionnelle, entre le 22 juillet et le
1er août 2026) peut être associée manuellement à une dépense pour noter
le jour réel où elle a eu lieu, indépendamment de la date de saisie dans
l'app ; sans date renseignée, la date d'ajout est affichée à la place.
Les dépenses et la liste des participants sont
**partagées entre tous les voyageurs** (stockées dans Supabase, voir
ci-dessous) ; un cache localStorage permet un premier affichage instantané
et un usage hors-ligne dégradé. Le front repolle toutes les 10 secondes
pour refléter les ajouts faits par les autres voyageurs sans recharger la
page. Si l'enregistrement d'une dépense en base échoue (ex. connexion
coupée, incident serveur), elle reste visible localement avec le repère
« ⏳ en attente de synchronisation » et chaque repoll retente d'abord de
l'envoyer vers Supabase avant de rafraîchir la liste depuis le serveur —
pour ne jamais écraser une dépense saisie mais pas encore confirmée par le
serveur.

## Identification
L'identité de chacun est un simple prénom saisi une fois et mémorisé sur
l'appareil (pas d'authentification), avec la **même clé de stockage local**
que les apps `planning-activites-semaine` et `activites-loisirs`
(`planning_activites_voter_suisse_2026`) : sur GitHub Pages, où les apps
partagent la même origine, le prénom choisi dans l'une est donc reconnu
dans les autres. Ce prénom est utilisé pour pré-remplir le payeur d'une
nouvelle dépense et est automatiquement ajouté à la liste des
participants du séjour.

## Protection par mot de passe
Un mot de passe unique, valable pour tous les voyageurs, protège l'accès à
l'app entière : un écran de verrouillage s'affiche tant que le mot de
passe correct n'a pas été saisi sur l'appareil (mémorisé ensuite en
localStorage, clé `depenses_partagees_unlocked_suisse_2026`). C'est une
barrière simple côté client (pas une sécurité applicative forte), cohérente
avec le reste du dépôt qui est un site statique public — elle évite
seulement qu'un visiteur tombant sur le lien par hasard consulte ou modifie
les dépenses du groupe.

## Dépendances datasource
Aucune — cette app ne consomme aucun fichier de `datasource/`.

## Dépendance externe : Supabase
Les dépenses et la liste des participants sont stockées dans des tables
Postgres du même projet Supabase que les autres mini-apps, interrogées
directement depuis le navigateur via le client `@supabase/supabase-js`
(CDN) et la clé publique `anon`/`publishable`, avec des policies RLS.
L'app reste statique : aucun backend ni build n'est nécessaire.
- `expense_members` : liste partagée des prénoms pouvant payer ou
  partager une dépense.
- `expenses` : chaque dépense (`payer_name`, `amount`, `motif`,
  `participants` en jsonb, `added_by`), source de vérité utilisée pour
  calculer les soldes et les remboursements.
- Schéma SQL à exécuter dans le SQL Editor Supabase :
  `apps/depenses-partagees/supabase-schema.sql`
- Projet Supabase : `hmpiluotdcympkihvnlt`
  (URL : `https://hmpiluotdcympkihvnlt.supabase.co`)
