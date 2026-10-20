# 🚗 Pendler-Assistent

> **Ein proaktiver Multi-Modaler Entscheidungs-Workflow für die tägliche Pendlermobilität.**  
> *Kein Navi, sondern dein automatisierter Berater vor der Abfahrt.*

---

## 📌 Übersicht & Philosophie

Der **Pendler-Assistent** ist kein Ersatz für Echtzeit-Navigations-Apps wie Google Maps. Während Google Maps exzellent darin ist, dich *während* der Fahrt per Live-GPS zu leiten, beantwortet dieser Workflow eine vorgelagerte Frage: **Wie und wann sollte ich heute überhaupt losfahren?**

Jeden Morgen (z. B. um 06:30 Uhr oder dynamisch angepasst an deinen Kalender) analysiert der Workflow Wetter, ÖPNV-Lage, Straßensperrungen und Spritpreise. Auf Basis deiner persönlichen Präferenzen erhältst du eine konkrete Handlungsempfehlung direkt auf dein Smartphone oder Smart Home.

---

## 🛠️ Systemarchitektur & Datenquellen

| Bereich | Datenquelle / Tool | Anmerkung & Details |
| :--- | :--- | :--- |
| **Routing (Auto)** | **OpenRouteService** / **OSRM** | Berechnung der Fahrtzeit, Distanz und Wegstrecke *(kostenlose Tier-Limits beachten)* |
| **ÖPNV & Bahn** | **GTFS / GTFS-Realtime** (z.B. DELFI) | Zuverlässiger für Regionalverkehr & Verspätungen *(Fallback: DB Marketplace API)* |
| **Kraftstoffpreise** | **Tankerkönig API** | Aktuelle Spritpreise entlang der Route *(Preis-Logger für Historie erforderlich)* |
| **Wetter** | **Open-Meteo API** | Regen, Schnee, Glatteis und Unwetterwarnungen auf der Route |
| **Meldungen (Auto)**| **Autobahn-API** | Offizielle Daten zu Autobahnsperrungen, Baustellen und Warnungen |
| **Kalender** | **CalDAV / Google Calendar** | Ermittlung des ersten Termins zur dynamischen Weck- und Abfahrtszeit |
| **Datenbank** | **SQLite / PostgreSQL** | Speicherung der Historie für Langzeitauswertungen & Preis-Analysen |
| **Benachrichtigung** | **Telegram Bot / Smart Home** | Push-Nachricht oder Visuelles Feedback (z. B. Home Assistant) |

---

## 🎯 Funktionsumfang & Logik

### 1. Multi-Modaler Routenvergleich (Auto vs. ÖPNV)
* **Auto:** Routenberechnung via OpenRouteService. Berechnung von Fahrtzeit, Treibstoffkosten und CO₂-Emissionen basierend auf deinen hinterlegten Fahrzeug-Konfigurationswerten (z. B. Verbrauch `l/100km`, Kraftstoffart, CO₂-Faktor).
* **ÖPNV:** Abruf der aktuellen Fahrpläne & Echtzeit-Verspätungen. Ermittlung der CO₂-Bilanz und Gesamtreisezeit von Tür zu Tür.

### 2. Gezielter Spritpreis-Vergleich & Trend
* **Keine leeren Versprechungen:** Da APIs nur Echtzeitpreise liefern, baut der integrierte **Preis-Logger** von Tag 1 an eine eigene Historie in der Datenbank auf.
* **Ergebnis:** Ermittlung der günstigsten Tankstellen entlang deiner Route sowie Analyse, an welchen Wochentagen/Uhrzeiten das Tanken statistisch am günstigsten ist.

### 3. Transparente Entscheidungslogik
Der Workflow nutzt eine **Regelkette mit Punktesystem (Scoring)** basierend auf deinen gewichteten Prioritäten:
* **Sicherheit/Wetter:** Bei Glatteis- oder Unwetterwarnung erhält die Bahn einen hohen Bonus.
* **Pünktlichkeit:** Hat der Zug `> 10 Minuten` Verspätung und der erste Termin drängt, wird das Auto bevorzugt.
* **Kosten & CO₂:** Ist das Auto auf der Strecke deutlich teurer oder umweltschädlicher, punktet der ÖPNV.

### 4. Robustheit & Fehlerbehandlung (Graceful Degradation)
Fällt eine externe API (z. B. Wetter oder ÖPNV-Echtzeit) aus, bricht der Workflow nicht ab. Stattdessen wird die Entscheidung mit den verfügbaren Daten getroffen und ein Hinweis in der Benachrichtigung ergänzt:
> ⚠️ *Hinweis: ÖPNV-Echtzeitdaten aktuell nicht verfügbar. Entscheidung basiert auf Regelfahrplan.*

---

## ⚖️ Abgrenzung: Workflow vs. Google Maps

| Kriterium | Google Maps | Pendler-Assistent |
| :--- | :--- | :--- |
| **Fokus** | Navigation während der Fahrt (Turn-by-Turn) | Entscheidung **vor** der Abfahrt |
| **Interaktion** | Reaktiv (du öffnest die App) | Proaktiv (meldet sich automatisch) |
| **Entscheidungsregeln** | Inflexibel (Standard-Routing) | 100 % individuell anpassbar |
| **Daten-Verknüpfung** | Nur Karten & Verkehr | Auto, ÖPNV, Wetter, Kalender, Spritpreis, CO₂ |
| **Datenhistorie** | Kaum/Keine Langzeitauswertung | Volle Kontrolle über eigene Historie (SQL) |
| **Live-Traffic (Landstraße)**| ✅ Sehr präzise (Millionen Livedaten) | ❌ Nur offizielle Sperrungen/Baustellen |

---

## 🚀 Roadmap & Risikomanagement

- [x] Konzept & Architektur-Draft
- [ ] **Phase 1: Fundament & Daten-Logger**
  - [ ] Datenbank-Schema aufsetzen (SQLite/Postgres)
  - [ ] Tankerkönig- & Wetter-Logger starten (Historie aufbauen)
- [ ] **Phase 2: ÖPNV- & Route-Prototyping (Höchstes Risiko)**
  - [ ] GTFS-Realtime / DB-API Anbindung testen & Ausfallsicherheit prüfen
  - [ ] OpenRouteService für Auto-Routen integrieren
- [ ] **Phase 3: Decision Engine & Notifier**
  - [ ] Scoring-Logik & Regelkette implementieren
  - [ ] Telegram-Bot Anbindung & Fallback-Handling umsetzen
