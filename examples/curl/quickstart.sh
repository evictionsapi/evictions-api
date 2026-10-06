#!/usr/bin/env bash
# End-to-end test-mode flow (fictional state ZZ).
# Untested in this kit: requires EVICTIONS_API_KEY=eak_test_...
set -euo pipefail

: "${EVICTIONS_API_KEY:?Set EVICTIONS_API_KEY to a test key (eak_test_...)}"
BASE="${EVICTIONS_API_URL:-https://api.evictionsapi.com}"
AUTH="Authorization: Bearer $EVICTIONS_API_KEY"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PDF="${ROOT}/examples/fixtures/authority-sample.pdf"

echo "== resolve ZZ =="
curl -sS -f "$BASE/v1/jurisdictions/resolve?state=ZZ" -H "$AUTH" | python3 -m json.tool | head -40

IDEMP="demo-$(date +%s)-$$"
echo "== create case (Idempotency-Key: $IDEMP) =="
CASE=$(curl -sS -f -X POST "$BASE/v1/cases" \
  -H "$AUTH" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: $IDEMP" \
  -d '{
    "ground": "nonpayment",
    "entryPoint": "notice",
    "property": {
      "line1": "1 Main St",
      "city": "Testville",
      "state": "ZZ",
      "zip": "00000",
      "ownerOfRecord": "Pat Landlord"
    },
    "parties": [
      { "role": "plaintiff", "name": "Pat Landlord" },
      { "role": "defendant", "name": "Terry Tenant" }
    ],
    "lease": { "startDate": "2025-01-01", "monthlyRentCents": 150000 },
    "ledger": [
      { "date": "2026-09-01", "type": "charge", "amountCents": 150000 },
      { "date": "2026-10-01", "type": "charge", "amountCents": 150000 },
      { "date": "2026-10-02", "type": "payment", "amountCents": 50000 }
    ],
    "amountOwedCents": 250000,
    "attestations": {
      "authority": true,
      "notRetaliatory": true,
      "notDiscriminatory": true,
      "servicemember": "no",
      "caresCovered": false
    }
  }' | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])')
echo "case=$CASE"

echo "== upload authority =="
B64=$(base64 < "$PDF" | tr -d '\n')
curl -sS -f -X POST "$BASE/v1/cases/$CASE/documents" \
  -H "$AUTH" \
  -H "Content-Type: application/json" \
  -d "{\"filename\":\"deed.pdf\",\"purpose\":\"authority\",\"contentBase64\":\"$B64\"}" \
  | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("id") or d)'

echo "== validate =="
curl -sS -f -X POST "$BASE/v1/cases/$CASE/validate" -H "$AUTH" | python3 -m json.tool | head -60

echo "== submit =="
curl -sS -f -X POST "$BASE/v1/cases/$CASE/submit" -H "$AUTH" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("state"), d.get("nextAction"))'

echo "== advance until closed (test mode) =="
for i in $(seq 1 40); do
  RESP=$(curl -sS -X POST "$BASE/v1/cases/$CASE/advance" -H "$AUTH")
  STATE=$(printf '%s' "$RESP" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("state") or d.get("error",{}).get("code") or "?")' 2>/dev/null || echo "?")
  echo "  step $i -> $STATE"
  if [ "$STATE" = "closed" ]; then break; fi
  if [ "$STATE" = "nothing_to_advance" ] || [ "$STATE" = "sandbox_only" ]; then
    sleep 1
  fi
  sleep 0.3
done

echo "== final =="
curl -sS -f "$BASE/v1/cases/$CASE" -H "$AUTH" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["id"], d["state"], d.get("nextAction"))'
