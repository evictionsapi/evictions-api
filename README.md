# Evictions API — public examples

Hand your eviction paperwork to your AI agent. A licensed attorney reviews it before anything is served or filed.

**Evictions API** (operated by Future Cities LLC) is a REST API and MCP server for starting and tracking a residential eviction case in any US state or DC. Evictions API is not a law firm and does not give legal advice.

- Site: https://evictionsapi.com
- API: https://api.evictionsapi.com/v1
- Docs: https://evictionsapi.com/docs
- Agents / MCP: https://evictionsapi.com/docs/agents
- OpenAPI (live): https://api.evictionsapi.com/v1/openapi.json
- `llms.txt`: https://evictionsapi.com/llms.txt

This repository holds the OpenAPI document, copy-and-paste examples, and MCP client configs. The product source code is private.

## Fees (real cases)

Platform fee: **$29** when a case starts at the notice stage; **$99** in total through filing (the $29 is credited). A case that starts at filing pays $99 once. The attorney’s legal fee and court and service costs are separate: they are quoted before any work begins and you approve them first. The legal fee is paid to the attorney. The API and test mode are free.

If no attorney is engaged within 5 business days of submission, the platform fee is refunded in full. We do not promise outcomes or how long a case takes.

## Quickstart (test mode, fictional state ZZ)

1. Sign up and copy a free test key (`eak_test_…`): https://evictionsapi.com/signup?next=/app/get-started
2. Set environment variables:

```bash
export EVICTIONS_API_URL=https://api.evictionsapi.com
export EVICTIONS_API_KEY=eak_test_...
```

3. Run one of the examples:

| Language | Path | Needs key? | Tested here |
|---|---|---|---|
| curl | [`examples/curl/quickstart.sh`](examples/curl/quickstart.sh) | Yes | **Untested** (needs your key) |
| Node | [`examples/node/quickstart.mjs`](examples/node/quickstart.mjs) | Yes | **Untested** (needs your key) |
| Python | [`examples/python/quickstart.py`](examples/python/quickstart.py) | Yes | **Untested** (needs your key) |
| Public smoke | [`examples/curl/public-smoke.sh`](examples/curl/public-smoke.sh) | No | **Tested 2026-10-06** against the live API |

Test mode uses the fictional state **ZZ**. Nothing is served or filed, and nothing reaches a real tenant, attorney, or court. In test mode a built-in sandbox reviewer and adapters move the case; call `POST /v1/cases/{id}/advance` until the state is `closed`.

Live mode uses a real property state. After you submit, we engage a licensed attorney in that state for the case. Nothing is served or filed until that attorney has reviewed it. Live keys are created only by an organization owner, signed in on the site.

## MCP setup

MCP server (Streamable HTTP): `https://evictionsapi.com/mcp`  
Discovery: https://evictionsapi.com/.well-known/mcp.json  
Full guide: https://evictionsapi.com/docs/agents

Tools that describe the service, pricing, and each state need no key. Tools that work with cases need `Authorization: Bearer eak_…`.

### Claude Desktop / Claude web

Customize → Connectors → Add custom connector → URL `https://evictionsapi.com/mcp`. For case tools, add header `Authorization` = `Bearer eak_test_...`.

### Claude Code

```bash
claude mcp add --transport http evictions-api https://evictionsapi.com/mcp \
  --header "Authorization: Bearer eak_test_..."
```

### Cursor

Put this in `.cursor/mcp.json` (project) or `~/.cursor/mcp.json` (all projects). Do not commit a real key.

```json
{
  "mcpServers": {
    "evictions-api": {
      "url": "https://evictionsapi.com/mcp",
      "headers": {
        "Authorization": "Bearer eak_test_..."
      }
    }
  }
}
```

### VS Code / other Streamable HTTP clients

See https://evictionsapi.com/docs/agents for VS Code `mcp.json`, ChatGPT (no-key tools only), and the tool list.

## OpenAPI

[`openapi.json`](openapi.json) was fetched from https://api.evictionsapi.com/v1/openapi.json on 2026-10-06 (OpenAPI 3.1, no key required). Prefer the live URL so you stay current.

## License

MIT for the examples and configs in this repository. Evictions API the product remains © Future Cities LLC.

## Contact

hello@evictionsapi.com  
https://evictionsapi.com/contact
