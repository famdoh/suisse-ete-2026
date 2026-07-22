# AGENTS.md

## Objectif

Ce dépôt héberge une collection de mini-applications HTML autonomes pour
le séjour « Suisse Été 2026 », publiées sous forme de site statique via
GitHub Pages. Chaque application créée dans le cadre de ce projet vise à
organiser le voyage en Suisse qui se déroule du 22 juillet au 1er août
2026.

Chaque mini-app doit tenir compte du contexte de voyage suivant :

- **Localisation** : le séjour se déroule au Camping Bella-Tola,
  Waldstrasse 57, 3952 Susten, Valais, Suisse — près de Loèche
  (Leuk), dans la région de la forêt de Finges (Pfyn) / vallée du
  Rhône.
- **Voyageurs** : 4 adultes et 4 enfants (entre 8 et 13 ans).

## Architecture

- `index.html` (racine du dépôt) — la page d'accueil. Elle liste toutes
  les mini-apps du dossier `./apps` avec un lien et une courte
  description. Mettre à jour ce fichier à chaque ajout, renommage ou
  suppression d'une app.
- `apps/<nom-app>/` — un dossier par mini-app. Le nom du dossier est le
  slug de l'app (kebab-case, ex. `menus-camping-suisse`).
  - `apps/<nom-app>/index.html` est l'app elle-même, accessible à
    `https://<user>.github.io/<repo>/apps/<nom-app>/`.
  - Tout fichier de support de cette app (markdown source, données,
    images) vit dans le même dossier, jamais à la racine du dépôt.
  - `apps/<nom-app>/description.md` — fichier de métadonnées obligatoire
    pour l'app, contenant au minimum son nom et une courte description
    (voir ci-dessous).
- `datasource/` — sources de données communes à toutes les apps.
  - `datasource/activites.md` — liste des activités touristiques à
    proximité du camping que les mini-apps peuvent proposer au
    voyageur. Toute app proposant des activités touristiques doit les
    puiser dans ce fichier.
- `.github/workflows/pages.yml` — workflow GitHub Actions qui déploie
  l'ensemble du dépôt comme site Pages à chaque push sur `main`.
- `.nojekyll` — désactive le traitement Jekyll pour que les
  fichiers/dossiers soient servis tels quels.

## Règles pour ajouter une nouvelle mini-app

1. Créer `apps/<nom-app>/` (slug kebab-case) et y placer le fichier
   `index.html` de l'app. Ne jamais placer le HTML d'une mini-app
   directement à la racine du dépôt ni en vrac dans `apps/`.
2. Ajouter un fichier `description.md` dans le même dossier avec les
   métadonnées de l'app : au minimum son nom et une courte description,
   et — si l'app consomme une datasource partagée (ex.
   `datasource/activites.md`) — une mention explicite de cette
   dépendance, par exemple :

   ```markdown
   # <Nom de l'app>

   <Une ou deux phrases décrivant ce que fait l'app.>

   ## Dépendances datasource
   - datasource/activites.md
   ```

3. Ajouter une carte/lien pour cette app dans la page d'accueil
   `index.html` à la racine, avec deux liens : un vers l'app (`apps/<nom-app>/`)
   et un vers son Artifact Claude.
4. Publier l'app en tant qu'Artifact Claude (voir ci-dessous) et noter
   son URL dans un fichier `apps/<nom-app>/ARTIFACT.md`, pour pouvoir la
   reporter dans le hub `index.html` et la redéployer au même chemin
   par la suite.
5. Aucune étape de build, ni bundler, ni framework — ce sont des
   fichiers HTML autonomes (CSS/JS inline). Garder cette approche sauf
   si une app en a réellement besoin autrement.

## Faire évoluer une mini-app existante

Toute demande d'évolution/mise à jour et de régénération d'une app
existante doit :

1. Lire d'abord `apps/<nom-app>/description.md`, pour connaître les
   contraintes et dépendances de cette app (y compris toute datasource
   qu'elle consomme).
2. Prendre en compte les fichiers pertinents de `datasource/` (ex.
   `activites.md`) lorsque l'app concerne des activités touristiques,
   afin que l'app reste cohérente avec les données partagées.
3. Mettre à jour `description.md` si l'évolution change la description
   de l'app ou ses dépendances datasource.
4. Une fois le changement poussé sur `main`, réafficher à l'utilisateur
   le lien GitHub Pages de l'app pour consultation :
   `https://famdoh.github.io/suisse-ete-2026/apps/<nom-app>/`, en
   précisant que le déploiement prend environ 1 minute, donc attendre
   ~1mn avant d'ouvrir le lien.

## Artifacts Claude

Chaque mini-app de `./apps` doit également être publiée en tant
qu'Artifact Claude (via l'outil Artifact), en plus de vivre dans ce
dépôt. Le dépôt est la source de vérité et l'historique de versions ;
l'Artifact offre un lien partageable et directement consultable.
Lorsque le HTML d'une app change, redéployer son Artifact depuis le
même chemin de fichier afin que l'URL de l'Artifact existant soit mise
à jour sur place plutôt que d'en créer un nouveau.

## Workflow Git

Tous les changements effectués lors d'une session doivent être
directement mergés sur la branche `dev` (pas de pull request
nécessaire).

## Déploiement

GitHub Pages est servi via GitHub Actions (voir
`.github/workflows/pages.yml`), qui déploie la racine du dépôt à chaque
push sur `main`. Dans les réglages du dépôt, la source de Pages doit
être configurée sur « GitHub Actions » (Settings → Pages → Build and
deployment → Source).
