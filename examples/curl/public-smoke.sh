#!/usr/bin/env bash
# Public endpoints only — no API key. Tested against the live API on 2026-10-06.
set -euo pipefail
BASE="${EVICTIONS_API_URL:-https://api.evictionsapi.com}"

echo "== GET $BASE/v1/health =="
curl -sS -f "$BASE/v1/health"
echo

echo "== GET $BASE/v1/openapi.json (title only) =="
curl -sS -f "$BASE/v1/openapi.json" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["openapi"], d["info"]["title"], len(d["paths"]), "paths")'

echo "OK"
