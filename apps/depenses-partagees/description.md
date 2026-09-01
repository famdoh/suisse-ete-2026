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
l'app ; sans date renseignée, la date d'ajout est affichée à la place. La
liste des dépenses est triée par **date croissante** (cette même date —
manuelle si renseignée, sinon date d'ajout —, du plus ancien au plus
récent), dans le même ordre que l'export CSV.

## Devise de saisie et devise d'affichage (CHF / EUR)
Chaque dépense peut être **saisie en CHF ou en EUR** (sélecteur à côté du
champ montant, dans le formulaire d'ajout/modification) : c'est la devise
dans laquelle la dépense a réellement été payée qui est enregistrée
(colonne `currency` de la table `expenses`, `CHF` par défaut). Les
dépenses enregistrées avant l'introduction de ce champ restent donc
interprétées en CHF, sans conversion rétroactive.

Indépendamment de cette devise de saisie, un sélecteur CHF/EUR en haut de
la carte « Résumé » choisit la devise d'**affichage** pour le total, les
soldes, les remboursements suggérés et la liste des dépenses ; le choix
est mémorisé sur l'appareil (localStorage, clé
`depenses_partagees_currency_suisse_2026`). Quand la devise d'affichage
diffère de la devise de saisie d'une dépense, le montant réellement saisi
reste rappelé dans le détail de la ligne. En interne, tous les calculs de
soldes/totaux ramènent chaque dépense à son équivalent CHF, seule unité
commune du grand livre.

La conversion CHF ↔ EUR (affichage comme saisie) utilise un **taux fixe et
approximatif** (1 CHF ≈ 1,06 EUR), représentatif de la période du séjour
plutôt qu'un taux du jour précis ou dynamique — conformément au besoin,
aucun appel à un service de change externe n'est fait.

## Export CSV
Le bouton « ⬇️ Exporter en CSV » (sous la liste des dépenses) télécharge
l'ensemble des dépenses (motif, montant et devise tels que saisis,
montant en CHF, montant converti en EUR avec le même taux fixe, payeur,
participants, date de la dépense, prénom de la personne qui l'a saisie),
triées de la plus ancienne à la plus récente, dans un fichier
`depenses-suisse-2026-<date>.csv` (séparateur `;`, encodage UTF-8 avec
BOM pour une ouverture correcte dans Excel).

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
dans les autres. Il sert uniquement à identifier qui ajoute une dépense
(champ `added_by`) et à débloquer le formulaire d'ajout. Ce prénom de
connexion n'est **jamais** ajouté automatiquement à la liste des payeurs
(`expense_members`) ni utilisé pour pré-remplir le payeur d'une dépense :
les deux sont des actions manuelles distinctes — ajouter un prénom à la
liste des payeurs se fait via le champ « Ajouter un prénom », et choisir
qui a payé se fait en le sélectionnant explicitement dans la liste
déroulante du formulaire (aucune option n'est sélectionnée par défaut) —
ceci pour éviter que des variantes du prénom de connexion (fautes de
frappe, casse différente) ne viennent polluer la liste des payeurs ou se
retrouver associées à des dépenses.

## Protection par mot de passe
Un mot de passe unique, valable pour tous les voyageurs, protège l'accès à
l'app entière : un écran de verrouillage s'affiche tant que le mot de
passe correct n'a pas été saisi sur l'appareil (mémorisé ensuite en
localStorage, clé `depenses_partagees_unlocked_suisse_2026`). C'est une
barrière simple côté client (pas une sécurité applicative forte), cohérente
avec le reste du dépôt qui est un site statique public — elle évite
seulement qu'un visiteur tombant sur le lien par hasard consulte ou modifie
les dépenses du groupe.

## RIB pour les remboursements
En bas de page, une carte « RIB pour les remboursements » (ancre
`#rib`) affiche les coordonnées bancaires de Nathalie & Romain (IBAN,
code banque, code guichet, n° de compte, clé RIB, BIC, domiciliation),
à utiliser par les autres participants pour régler les remboursements
suggérés par « Qui doit combien à qui ». Coordonnées statiques
inscrites en dur dans le HTML, non stockées en base. Un bouton
« 📋 Copier le lien vers le RIB » copie dans le presse-papiers l'URL de
la page suivie de `#rib`, pour partager un lien direct vers cette
carte ; comme le reste de la page est masqué tant que le mot de passe
n'est pas saisi, l'ouverture d'un tel lien déclenche un défilement
automatique vers la carte une fois l'accès déverrouillé.

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
- `expenses` : chaque dépense (`payer_name`, `amount`, `currency`
  — `CHF` ou `EUR`, défaut `CHF` —, `motif`, `participants` en jsonb,
  `added_by`), source de vérité utilisée pour calculer les soldes et les
  remboursements.
- Schéma SQL à exécuter dans le SQL Editor Supabase :
  `apps/depenses-partagees/supabase-schema.sql`
- Projet Supabase : `hmpiluotdcympkihvnlt`
  (URL : `https://hmpiluotdcympkihvnlt.supabase.co`)
