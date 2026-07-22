#!/usr/bin/env python3
"""Fetch Open-Meteo forecasts for the trip's activity sectors and regenerate:
- datasource/meteo.json (source of truth, human/agent readable)
- the embedded METEO block in apps/planning-activites-semaine/index.html

Usage: python3 fetch_meteo.py [--repo-root PATH] [--start YYYY-MM-DD] [--end YYYY-MM-DD]

No third-party dependencies (uses urllib from the standard library) so it can
run in any environment with outbound HTTPS access, no API key required
(Open-Meteo is free/open for non-commercial use).
"""
import argparse
import datetime
import json
import re
import sys
import urllib.request
import urllib.error

SECTEURS = [
    {"id": "susten-finges", "nom": "Susten / Bois de Finges", "lat": 46.2988, "lng": 7.6365},
    {"id": "leukerbad", "nom": "Leukerbad", "lat": 46.3850, "lng": 7.6220},
    {"id": "sierre-st-leonard", "nom": "Sierre / St-Léonard", "lat": 46.2564, "lng": 7.4256},
    {"id": "anniviers", "nom": "Val d'Anniviers", "lat": 46.2460, "lng": 7.5850},
    {"id": "tourtemagne", "nom": "Vallée de Tourtemagne", "lat": 46.2220, "lng": 7.6650},
    {"id": "zermatt", "nom": "Zermatt", "lat": 46.0207, "lng": 7.7491},
    {"id": "aletsch", "nom": "Aletsch Arena", "lat": 46.4000, "lng": 8.1330},
    {"id": "leman", "nom": "Lac Léman", "lat": 46.3600, "lng": 6.9000},
    {"id": "kandersteg", "nom": "Kandersteg", "lat": 46.4952, "lng": 7.6715},
    {"id": "nendaz", "nom": "Nendaz", "lat": 46.1853, "lng": 7.2927},
    {"id": "crans-montana", "nom": "Crans-Montana", "lat": 46.3100, "lng": 7.4758},
    {"id": "sion", "nom": "Sion", "lat": 46.2331, "lng": 7.3606},
    {"id": "diablerets", "nom": "Diablerets / Glacier 3000", "lat": 46.3569, "lng": 7.2156},
    {"id": "saviese", "nom": "Savièse", "lat": 46.2453, "lng": 7.3456},
]

DEFAULT_START = "2026-07-22"
DEFAULT_END = "2026-08-01"
FORECAST_DAYS = 16  # Open-Meteo's max forecast horizon


def fetch_forecast():
    lat = ",".join(str(s["lat"]) for s in SECTEURS)
    lng = ",".join(str(s["lng"]) for s in SECTEURS)
    url = (
        "https://api.open-meteo.com/v1/forecast"
        "?latitude={lat}&longitude={lng}"
        "&hourly=temperature_2m,weathercode"
        "&timezone=Europe%2FZurich"
        "&forecast_days={days}"
    ).format(lat=lat, lng=lng, days=FORECAST_DAYS)
    req = urllib.request.Request(url, headers={"User-Agent": "suisse-ete-2026-meteo-skill/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.load(resp)
    except urllib.error.URLError as e:
        print("Erreur en contactant Open-Meteo : {}".format(e), file=sys.stderr)
        sys.exit(1)
    if not isinstance(data, list):
        # Single-location responses aren't wrapped in a list; normalize.
        data = [data]
    if len(data) != len(SECTEURS):
        print(
            "Réponse inattendue d'Open-Meteo : {} secteurs demandés, {} reçus".format(
                len(SECTEURS), len(data)
            ),
            file=sys.stderr,
        )
        sys.exit(1)
    return data


def extract_forecast(raw, start_date, end_date):
    """Build {secteur_id: {date: {matin: {t, c}, soir: {t, c}}}} limited to [start,end]."""
    forecast = {}
    for secteur, loc in zip(SECTEURS, raw):
        times = loc["hourly"]["time"]
        temps = loc["hourly"]["temperature_2m"]
        codes = loc["hourly"]["weathercode"]
        by_hour = {}
        for t, temp, code in zip(times, temps, codes):
            by_hour[t] = (temp, code)

        day_map = {}
        cur = start_date
        while cur <= end_date:
            date_str = cur.isoformat()
            matin = by_hour.get(date_str + "T09:00")
            soir = by_hour.get(date_str + "T18:00")
            if matin is not None or soir is not None:
                entry = {}
                if matin is not None:
                    entry["matin"] = {"t": round(matin[0]), "c": matin[1]}
                if soir is not None:
                    entry["soir"] = {"t": round(soir[0]), "c": soir[1]}
                day_map[date_str] = entry
            cur += datetime.timedelta(days=1)
        forecast[secteur["id"]] = day_map
    return forecast


def write_datasource_json(repo_root, forecast, generated_at):
    path = repo_root + "/datasource/meteo.json"
    payload = {
        "generated_at": generated_at,
        "source": "Open-Meteo (api.open-meteo.com), heures locales Europe/Zurich",
        "secteurs": SECTEURS,
        "forecast": forecast,
    }
    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
        f.write("\n")
    return path


def update_index_html(repo_root, forecast, generated_at):
    path = repo_root + "/apps/planning-activites-semaine/index.html"
    with open(path, "r", encoding="utf-8") as f:
        html = f.read()

    js_forecast = json.dumps(forecast, ensure_ascii=False, separators=(",", ":"))
    block = (
        "/* METEO_DATA_START - généré par .claude/skills/meteo-update, ne pas éditer à la main */\n"
        "  var METEO_GENERATED_AT = {gen};\n"
        "  var METEO = {data};\n"
        "  /* METEO_DATA_END */"
    ).format(gen=json.dumps(generated_at), data=js_forecast)

    pattern = re.compile(
        r"/\* METEO_DATA_START.*?/\* METEO_DATA_END \*/", re.DOTALL
    )
    if not pattern.search(html):
        print(
            "Marqueurs METEO_DATA_START/END introuvables dans {} — "
            "le bloc METEO doit déjà exister dans le <script> pour être mis à jour.".format(path),
            file=sys.stderr,
        )
        sys.exit(1)
    html = pattern.sub(block, html, count=1)
    with open(path, "w", encoding="utf-8") as f:
        f.write(html)
    return path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--start", default=DEFAULT_START)
    parser.add_argument("--end", default=DEFAULT_END)
    args = parser.parse_args()

    start_date = datetime.date.fromisoformat(args.start)
    end_date = datetime.date.fromisoformat(args.end)

    raw = fetch_forecast()
    forecast = extract_forecast(raw, start_date, end_date)
    generated_at = datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds")

    json_path = write_datasource_json(args.repo_root, forecast, generated_at)
    html_path = update_index_html(args.repo_root, forecast, generated_at)

    print("Météo mise à jour :")
    print(" - {}".format(json_path))
    print(" - {}".format(html_path))


if __name__ == "__main__":
    main()
