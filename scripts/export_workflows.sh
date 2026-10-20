#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

docker exec -u node n8n-pendler rm -rf /tmp/wf-export
docker exec -u node n8n-pendler n8n export:workflow --all --separate --pretty --output=/tmp/wf-export/
docker cp n8n-pendler:/tmp/wf-export/. "$TMP_DIR/"

mkdir -p workflows
rm -f workflows/*.json

for f in "$TMP_DIR"/*.json; do
  name="$(jq -r '.name' "$f" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g; s/^_+|_+$//g')"
  cp "$f" "workflows/${name}.json"
done

echo "Export fertig:"
ls -1 workflows/
