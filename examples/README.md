# Examples

All end-to-end examples use a **test key** and the fictional state **ZZ**. They need a free test key from https://evictionsapi.com/signup?next=/app/get-started.

```bash
export EVICTIONS_API_URL=https://api.evictionsapi.com
export EVICTIONS_API_KEY=eak_test_...
```

| Script | Needs key | Status |
|---|---|---|
| `curl/public-smoke.sh` | No | Tested 2026-10-06 on the live API |
| `curl/quickstart.sh` | Yes | Untested in this kit |
| `node/quickstart.mjs` | Yes | Untested in this kit |
| `python/quickstart.py` | Yes | Untested in this kit |

`fixtures/authority-sample.pdf` is a tiny placeholder used only as the required authority upload with a test key.
