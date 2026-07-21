# AGENTS.md

## Purpose

This repository hosts a collection of standalone HTML mini-apps for the
"Suisse Été 2026" trip, published as a static site via GitHub Pages.

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
- `.github/workflows/pages.yml` — GitHub Actions workflow that deploys the
  whole repo root as the Pages site on every push to `main`.
- `.nojekyll` — disables Jekyll processing so files/folders are served
  as-is.

## Rules for adding a new mini-app

1. Create `apps/<app-name>/` (kebab-case slug) and put the app's
   `index.html` inside it. Never put a mini-app's HTML directly at the
   repo root or loose inside `apps/`.
2. Add a card/link for it in the root `index.html` hub page.
3. Publish the app as a Claude Artifact (see below) and, optionally, note
   the artifact URL in a comment or the app's own README for reference.
4. No build step, bundler, or framework — these are self-contained static
   HTML files (inline CSS/JS). Keep it that way unless an app genuinely
   needs otherwise.

## Claude Artifacts

Every mini-app in `./apps` must also be published as a Claude Artifact
(via the Artifact tool), in addition to living in this repo. The repo is
the source of truth and version history; the Artifact gives a
shareable, directly-viewable link. When an app's HTML changes, redeploy
its Artifact from the same file path so the existing Artifact URL is
updated in place rather than creating a new one.

## Deployment

GitHub Pages is served via GitHub Actions (see
`.github/workflows/pages.yml`), deploying the repository root on every
push to `main`. In the repo settings, Pages' source must be set to
"GitHub Actions" (Settings → Pages → Build and deployment → Source).
