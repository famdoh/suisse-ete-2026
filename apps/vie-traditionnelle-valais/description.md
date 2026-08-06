# Vie traditionnelle en Valais central

Mini-app pédagogique (adultes et enfants) sur le mode de vie
traditionnel des habitants des villages et des bourgs du secteur du
camping — Loèche/Leuk, Susten, Varone, Salquenen, Erschmatt, Albinen,
Guttet-Feschel, Inden, Sierre et le Val d'Anniviers — pendant les
2000 dernières années, c'est-à-dire avant que l'économie de marché du
20<sup>e</sup> siècle ne remplace le système agro-pastoral autarcique.

Le fil conducteur est le lien entre **environnement géologique et
manières de vivre** : climat intra-alpin très sec, éboulement
préhistorique de Sierre, plaine du Rhône marécageuse, opposition
adret/ubac, cône de l'Illgraben, sources thermales de la Gemmi,
matériaux de construction locaux.

## Contenu

L'app est organisée en six onglets :

1. **🏔️ Le socle** — 8 fiches de géologie, climat et géographie
   expliquant pourquoi on habitait les coteaux et pas la plaine, et
   pourquoi les bisses étaient vitaux.
2. **🌾 Cultures & élevages** — 12 fiches (filtrables Cultures /
   Élevages) : seigle, vigne, prés de fauche, jardin et pomme de
   terre, chanvre et lin, noyers et fruitiers, safran de Mund, vache
   d'Hérens, chèvre col noir, mouton nez noir, cochon et viande
   séchée, mulet et abeilles. Chaque fiche indique le lien au sol, à
   l'altitude et au climat.
3. **🗓️ Le calendrier** — les grandes périodes qui rythmaient l'année
   villageoise, de la veillée d'hiver à la corvée du bisse, la montée
   aux mayens, l'inalpe, la fenaison, la désalpe, les vendanges et la
   cuisson annuelle du pain, plus le calendrier religieux.
4. **🏠 Le village** — organisation et économie : quasi-autarcie, sel
   et fer, consortages, bourgeoisie, raccards et greniers sur
   rondelles de pierre, four banal, dizain de Loèche, service étranger
   et émigration.
5. **📜 2000 ans** — frise historique en 8 étapes, de la province
   romaine de la *Vallis Poenina* à la rupture du 20<sup>e</sup>
   siècle (usine d'aluminium de Chippis en 1908, barrages, deuxième
   correction du Rhône, tourisme).
6. **🎯 Quiz** — 10 questions à choix multiples (réponses mélangées à
   chaque partie), avec explication après chaque réponse et score
   final — pensé pour les enfants de 8 à 13 ans du séjour.

## Choix de conception

- Ancres `#act-<identifiant>` et bouton « 📋 » de copie de lien sur
  chaque fiche et chaque étape de frise ; l'arrivée sur un lien ouvre
  automatiquement le bon onglet puis défile jusqu'à la fiche. Un lien
  `#tab-<nom>` (ex. `#tab-histoire`) ouvre directement un onglet.
- Palette ocre/bois distincte des autres mini-apps, thèmes clair et
  sombre.

## Dépendances datasource

Aucune. Cette app ne consomme ni `datasource/activites.md` ni
`datasource/meteo.json` : son contenu est historique et patrimonial,
figé dans `index.html`, sans Supabase ni dépendance externe (hors
polices Google Fonts, comme les autres apps).

Sources principales (recherche web, août 2026) : Dictionnaire
historique de la Suisse, Parc naturel Pfyn-Finges, commune et centre
du seigle d'Erschmatt (Sortengarten fondé en 1985), documentation sur
les bisses et consortages valaisans, sites de Loèche-les-Bains
(cardinal Schiner, 1501) et de Sierre, travaux de géologie sur
l'éboulement de Sierre et l'Illgraben, documentation sur l'usine
d'aluminium de Chippis (première coulée en 1908) et sur les
corrections du Rhône. Les datations anciennes contestées sont
présentées comme des ordres de grandeur dans l'app.
