#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# 1. Workflows aus dem Container exportieren
docker exec -u node n8n-pendler rm -rf /tmp/wf-export
docker exec -u node n8n-pendler n8n export:workflow --all --separate --pretty --output=/tmp/wf-export/
docker cp n8n-pendler:/tmp/wf-export/. "$TMP_DIR/"

# 2. Bereinigen und mit einheitlichen Dateinamen ablegen
mkdir -p workflows
rm -f workflows/*.json

for f in "$TMP_DIR"/*.json; do
  name="$(jq -r '.name' "$f" | tr '[:upper:]' '[:lower:]' | sed 's/ä/ae/g; s/ö/oe/g; s/ü/ue/g; s/ß/ss/g' | sed -E 's/[^a-z0-9]+/_/g; s/^_+|_+$//g')"
  [ -z "$name" ] && name="$(jq -r '.id' "$f")"
  cp "$f" "workflows/${name}.json"
done

# 3. Nur workflows/ stagen
git add workflows/

# 4. Abbrechen, wenn sich nichts geändert hat
if git diff --cached --quiet; then
  echo "Keine Änderungen an den Workflows. Nichts zu pushen."
  exit 0
fi

# 5. Commit und Push
MSG="${1:-Workflow-Update $(date '+%Y-%m-%d %H:%M')}"
git commit -m "$MSG"
git push

echo "Gepusht: $MSG"
