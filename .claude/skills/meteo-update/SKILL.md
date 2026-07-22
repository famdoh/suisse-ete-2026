---
name: meteo-update
description: Rafraîchit les prévisions météo (matin/soir, par secteur géographique) utilisées par la mini-app "Planning des activités" du voyage Suisse Été 2026. Utiliser ce skill dès que l'utilisateur demande de mettre à jour, rafraîchir ou régénérer la météo, les prévisions météo, ou le temps qu'il fera, pour le planning des activités ou pour le séjour en Suisse — même s'il ne mentionne pas explicitement Open-Meteo, un fichier JSON, ou le nom du skill. Ne pas utiliser pour une simple question ponctuelle du type "quel temps fait-il à Zermatt demain ?" qui n'implique pas de modifier le dépôt.
---

# Mise à jour de la météo du planning des activités

## Contexte

La mini-app `apps/planning-activites-semaine/` affiche, pour chaque activité
planifiée un jour donné, la météo prévue **du secteur géographique de cette
activité**, en deux points de la journée : matin (9h) et soir (18h). Comme les
apps de ce dépôt sont des fichiers HTML statiques sans backend ni étape de
build (voir `AGENTS.md`), ces prévisions ne peuvent pas être interrogées en
direct depuis le navigateur à chaque visite : elles sont pré-calculées et
embarquées dans le fichier, exactement comme les activités elles-mêmes
(`datasource/activites.md` → tableau `ACTIVITIES` inline). Ce skill est ce qui
maintient cette copie embarquée à jour.

Les données viennent d'[Open-Meteo](https://open-meteo.com/), une API météo
gratuite et sans clé, avec un horizon de prévision de 16 jours. Le séjour dure
du 22 juillet au 1er août 2026 (11 jours) : tant qu'on relance ce skill dans
les 16 jours précédant ou pendant le séjour, la totalité des jours du planning
est couverte par des prévisions réelles.

## Ce que fait le script

`scripts/fetch_meteo.py` (aucune dépendance tierce, seulement la bibliothèque
standard Python) :

1. Interroge Open-Meteo en un seul appel pour les 14 secteurs géographiques
   déjà définis (un par vallée/zone où se trouvent les activités : Leukerbad,
   Zermatt, Val d'Anniviers, Lac Léman, etc. — la liste complète est dans le
   script, variable `SECTEURS`, et doit rester synchronisée avec l'objet
   `SECTEURS` du JS de `apps/planning-activites-semaine/index.html`).
2. Extrait, pour chaque jour du séjour (22/07 → 01/08 par défaut,
   personnalisable via `--start`/`--end`), la température et le code météo
   (norme OMS/WMO) à 9h et 18h.
3. Écrit le résultat dans `datasource/meteo.json` (source de vérité lisible,
   comme les autres fichiers de `datasource/`).
4. Réécrit, **dans `apps/planning-activites-semaine/index.html` uniquement**,
   le bloc JS délimité par les marqueurs `/* METEO_DATA_START ... METEO_DATA_END */`
   (variables `METEO_GENERATED_AT` et `METEO`), sans toucher au reste du
   fichier. Si ces marqueurs sont introuvables (fichier modifié entre-temps),
   le script s'arrête avec une erreur plutôt que de deviner où insérer les
   données.

## Comment l'utiliser

Lancer, depuis la racine du dépôt :

```bash
python3 .claude/skills/meteo-update/scripts/fetch_meteo.py --repo-root .
```

Options utiles :
- `--start YYYY-MM-DD` / `--end YYYY-MM-DD` — si les dates du séjour changent,
  ou pour ne rafraîchir qu'une partie de la période (par défaut : dates du
  séjour 2026-07-22 → 2026-08-01, cohérentes avec `TRIP_START`/`TRIP_END` dans
  `index.html`).

Après l'exécution, le script imprime les deux fichiers modifiés. Vérifier
rapidement le diff (`git diff --stat`) : seuls `datasource/meteo.json` et le
bloc `METEO_DATA_START/END` de `index.html` doivent changer.

## À faire après avoir régénéré les données

En suivant le workflow standard de ce dépôt (voir `AGENTS.md`) :

1. Redéployer l'Artifact Claude de `planning-activites-semaine` depuis
   `apps/planning-activites-semaine/index.html`, pour que le lien Artifact
   existant reflète les nouvelles prévisions.
2. Committer `datasource/meteo.json` et `apps/planning-activites-semaine/index.html`
   ensemble (ils doivent rester synchronisés — ne jamais committer l'un sans
   l'autre).
3. Une fois poussé sur `main`, rappeler à l'utilisateur le lien GitHub Pages
   de l'app et qu'il faut ~1 min avant que le déploiement soit visible.

## Si la liste des secteurs ou des activités change

Si une nouvelle activité est ajoutée dans `datasource/activites.md` /
`apps/planning-activites-semaine/index.html` (tableau `ACTIVITIES`), il faut
lui assigner un `secteur` (un id de la liste `SECTEURS`) — ou créer un nouveau
secteur avec ses coordonnées si l'activité est dans une zone géographique pas
encore couverte. Dans ce cas, ajouter le nouveau secteur à la fois dans
`SECTEURS` du script Python **et** dans l'objet `SECTEURS` du JS de
`index.html` (nom affiché), puis relancer le script pour peupler ses
prévisions. Les deux listes de secteurs doivent toujours rester identiques
(mêmes ids) — c'est ce qui permet à `sectorWeather()` côté JS de retrouver la
météo d'une activité via `METEO[activite.secteur]`.
