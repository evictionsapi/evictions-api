#!/usr/bin/env python3
"""End-to-end test-mode flow (fictional state ZZ).

Untested in this kit: requires EVICTIONS_API_KEY=eak_test_...
Stdlib only (urllib). Run: python3 examples/python/quickstart.py
"""
from __future__ import annotations

import base64
import json
import os
import sys
import time
import uuid
import urllib.error
import urllib.request
from pathlib import Path

KEY = os.environ.get("EVICTIONS_API_KEY")
if not KEY:
    sys.exit("Set EVICTIONS_API_KEY to a test key (eak_test_...)")
BASE = os.environ.get("EVICTIONS_API_URL", "https://api.evictionsapi.com")
ROOT = Path(__file__).resolve().parents[2]
PDF = (ROOT / "examples/fixtures/authority-sample.pdf").read_bytes()


def api(method: str, path: str, body: dict | None = None) -> dict:
    headers = {
        "Authorization": f"Bearer {KEY}",
        "Accept": "application/json",
    }
    data = None
    if body is not None:
        headers["Content-Type"] = "application/json"
        data = json.dumps(body).encode()
        if method == "POST" and path == "/v1/cases":
            headers["Idempotency-Key"] = str(uuid.uuid4())
    req = urllib.request.Request(f"{BASE}{path}", data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=60) as res:
            raw = res.read().decode()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        detail = e.read().decode()
        raise SystemExit(f"{method} {path} -> {e.code}: {detail}") from e


resolved = api("GET", "/v1/jurisdictions/resolve?state=ZZ")
print("resolve ZZ served=", resolved.get("served"), "handling=", resolved.get("handling"))

created = api(
    "POST",
    "/v1/cases",
    {
        "ground": "nonpayment",
        "entryPoint": "notice",
        "property": {
            "line1": "1 Main St",
            "city": "Testville",
            "state": "ZZ",
            "zip": "00000",
            "ownerOfRecord": "Pat Landlord",
        },
        "parties": [
            {"role": "plaintiff", "name": "Pat Landlord"},
            {"role": "defendant", "name": "Terry Tenant"},
        ],
        "lease": {"startDate": "2025-01-01", "monthlyRentCents": 150000},
        "ledger": [
            {"date": "2026-09-01", "type": "charge", "amountCents": 150000},
            {"date": "2026-10-01", "type": "charge", "amountCents": 150000},
            {"date": "2026-10-02", "type": "payment", "amountCents": 50000},
        ],
        "amountOwedCents": 250000,
        "attestations": {
            "authority": True,
            "notRetaliatory": True,
            "notDiscriminatory": True,
            "servicemember": "no",
            "caresCovered": False,
        },
    },
)
print("created", created["id"], created.get("state"))

api(
    "POST",
    f"/v1/cases/{created['id']}/documents",
    {
        "filename": "deed.pdf",
        "purpose": "authority",
        "contentBase64": base64.b64encode(PDF).decode(),
    },
)
print("authority uploaded")

validation = api("POST", f"/v1/cases/{created['id']}/validate")
print("validate", validation.get("ok", validation))

submitted = api("POST", f"/v1/cases/{created['id']}/submit")
print("submitted", submitted.get("state"), submitted.get("nextAction"))

state = submitted.get("state")
for i in range(40):
    try:
        advanced = api("POST", f"/v1/cases/{created['id']}/advance")
        state = advanced.get("state", state)
    except SystemExit as e:
        print("advance error", e)
        break
    print(f"advance {i + 1} ->", state)
    if state == "closed":
        break
    time.sleep(0.3)

final = api("GET", f"/v1/cases/{created['id']}")
print("final", final["id"], final.get("state"), final.get("nextAction"))
