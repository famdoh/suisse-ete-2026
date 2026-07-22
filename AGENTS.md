# AGENTS.md

## Purpose

This repository hosts a collection of standalone HTML mini-apps for the
"Suisse Été 2026" trip, published as a static site via GitHub Pages.
Every app built in this project exists to help organize the Switzerland
trip taking place from July 22 to August 1, 2026.

Every mini-app must take the following trip context into account:

- **Location**: the stay takes place at Camping Bella-Tola, Waldstrasse
  57, 3952 Susten, Valais, Switzerland — near Leuk/Loèche, in the Pfyn
  ("Finges") forest / Rhône valley area.
- **Travelers**: 4 adults and 4 children (aged 8 to 13).

## Architecture

- `index.html` (repo root) — the hub page. It lists every mini-app in
  `./apps` with a link and a short description. Update this file whenever
  an app is added, renamed, or removed.
- `apps/<app-name>/` — one folder per mini-app. The folder name is the
  app's slug (kebab-case, e.g. `menus-camping-suisse`).
  - `apps/<app-name>/index.html` is the app itself, so it's reachable at
    `https://<user>.github.io/<repo>/apps/<app-name>/`.
  - Any supporting files for that app (source markdown, data, images)
    live in the same folder, not at the repo root.
  - `apps/<app-name>/description.md` — required metadata file for the
    app, containing at least its name and a short description (see
    below).
- `datasource/` — shared data sources common to all apps.
  - `datasource/activites.md` — list of tourist activities near the
    campsite that mini-apps can propose to the traveler. Any app
    proposing tourist activities must source them from this file.
- `.github/workflows/pages.yml` — GitHub Actions workflow that deploys the
  whole repo root as the Pages site on every push to `main`.
- `.nojekyll` — disables Jekyll processing so files/folders are served
  as-is.

## Rules for adding a new mini-app

1. Create `apps/<app-name>/` (kebab-case slug) and put the app's
   `index.html` inside it. Never put a mini-app's HTML directly at the
   repo root or loose inside `apps/`.
2. Add a `description.md` file in the same folder with the app's
   metadata: at minimum its name and a short description, and — if the
   app consumes a shared datasource (e.g. `datasource/activites.md`) —
   an explicit mention of that dependency, e.g.:

   ```markdown
   # <App Name>

   <One or two sentence description of what the app does.>

   ## Datasource dependencies
   - datasource/activites.md
   ```

3. Add a card/link for it in the root `index.html` hub page.
4. Publish the app as a Claude Artifact (see below) and, optionally, note
   the artifact URL in a comment or the app's own README for reference.
5. No build step, bundler, or framework — these are self-contained static
   HTML files (inline CSS/JS). Keep it that way unless an app genuinely
   needs otherwise.

## Evolving an existing mini-app

Any request to evolve/update and regenerate an existing app must:

1. Read `apps/<app-name>/description.md` first, to know that app's
   constraints and dependencies (including any datasource it consumes).
2. Take the relevant files in `datasource/` (e.g. `activites.md`) into
   account when the app relates to tourist activities, so the app stays
   consistent with the shared data.
3. Update `description.md` if the evolution changes the app's
   description or its datasource dependencies.

## Claude Artifacts

Every mini-app in `./apps` must also be published as a Claude Artifact
(via the Artifact tool), in addition to living in this repo. The repo is
the source of truth and version history; the Artifact gives a
shareable, directly-viewable link. When an app's HTML changes, redeploy
its Artifact from the same file path so the existing Artifact URL is
updated in place rather than creating a new one.

## Git Workflow

All changes made during a session must be merged directly into the
`dev` branch (no pull request required).

## Deployment

GitHub Pages is served via GitHub Actions (see
`.github/workflows/pages.yml`), deploying the repository root on every
push to `main`. In the repo settings, Pages' source must be set to
"GitHub Actions" (Settings → Pages → Build and deployment → Source).
