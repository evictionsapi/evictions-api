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

The platform fee is $29 when a case starts at the notice, and $70 more if it goes on to filing. A case that starts at filing, because you already served the notice, pays $99 once. Where the [pricing page](https://evictionsapi.com/pricing) lists a flat fee, the attorney’s legal fee for an uncontested case is that flat fee; elsewhere, and for contested work, it is quoted to you first. Court and service costs are separate, and you approve the attorney’s fee and these costs before any work begins. The attorney’s legal fee is paid to the attorney, and none of it goes to Evictions API. The API and test keys are free.

If no attorney is engaged within 5 business days of submission, the platform fee is refunded in full. We do not promise outcomes or how long a case takes.

## Quickstart (test key, fictional state ZZ)

1. Sign up and copy a free test key (`eak_test_…`): https://evictionsapi.com/signup?next=/app/get-started
2. Set environment variables:

```bash
export EVICTIONS_API_URL=https://api.evictionsapi.com
export EVICTIONS_API_KEY=eak_test_...
```

3. Run one of the examples:

| Language | Path | Needs key? | Tested here |
|---|---|---|---|
| curl | [`examples/curl/quickstart.sh`](examples/curl/quickstart.sh) | Yes | **Tested 2026-10-14** against the live API with a test key |
| Node | [`examples/node/quickstart.mjs`](examples/node/quickstart.mjs) | Yes | **Tested 2026-10-14** against the live API with a test key |
| Python | [`examples/python/quickstart.py`](examples/python/quickstart.py) | Yes | **Tested 2026-10-14** against the live API with a test key |
| Public smoke | [`examples/curl/public-smoke.sh`](examples/curl/public-smoke.sh) | No | **Tested 2026-10-14** against the live API |

Test keys are a developer feature for building and testing an integration: a test key works only with the fictional test state **ZZ**, and nothing real is served or filed or reaches a tenant, attorney, or court. With a test key, call `POST /v1/cases/{id}/advance` to move the case through its steps until its state is `closed`.

Live mode uses a real property state. After you submit, we engage a licensed attorney in that state for the case. Nothing is served or filed until that attorney has reviewed it. Live keys are created only by an organization owner, signed in on the site.

## MCP setup

MCP server (Streamable HTTP): `https://evictionsapi.com/mcp`  
Discovery: https://evictionsapi.com/.well-known/mcp.json  
Full guide, with every tool: https://evictionsapi.com/docs/agents ([Markdown](https://evictionsapi.com/docs/agents.md))

The tools that describe the service, pricing and each state need no key. The tools that work with cases need the person’s account: in Claude and ChatGPT the person signs in when the client asks; other clients send `Authorization: Bearer eak_…`. Signing in gives the app the same access as an API key in the mode chosen (a live key for an owner’s real cases, or a test key for developer testing); it is revoked on the API keys page.

### Claude (web and desktop)

1. Open Customize, then Connectors (Team or Enterprise: Organization settings, then Connectors).
2. Add custom connector, paste `https://evictionsapi.com/mcp`. Under Authentication choose **Sign in when needed**, even if Claude suggests No sign-in, and keep the recommended OAuth client.
3. The first time Claude uses a tool that works with cases, it asks you to connect: sign in to Evictions API and approve.

### Claude Code

```bash
claude mcp add --transport http evictions-api https://evictionsapi.com/mcp
```

Then run `/mcp` inside Claude Code, choose `evictions-api` and sign in when it asks. To use a key instead, add `--header "Authorization: Bearer eak_test_..."`.

### ChatGPT

Turn on Developer mode in settings (paid plans), create an app for an MCP server with `https://evictionsapi.com/mcp`, choose OAuth, then sign in to Evictions API and approve.

### Cursor

Put this in `.cursor/mcp.json` (project) or `~/.cursor/mcp.json` (all projects). Leave `headers` out to use only the tools that need no key, and do not commit a real key.

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

### VS Code and other Streamable HTTP clients

See https://evictionsapi.com/docs/agents for VS Code `mcp.json` and the full tool list.

## OpenAPI

[`openapi.json`](openapi.json) was fetched from https://api.evictionsapi.com/v1/openapi.json on 2026-10-14 (OpenAPI 3.1, no key required). Prefer the live URL so you stay current.

## License

MIT for the examples and configs in this repository. Evictions API the product remains © Future Cities LLC.

## Contact

hello@evictionsapi.com  
https://evictionsapi.com/contact
