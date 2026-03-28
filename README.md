# 🏹 Archer

> *Every fortress has walls. Archer finds out how strong they are.*

Archer is an AI agent skill that scouts your service's codebase, understands what it does, and crafts a suite of HTTP request scripts — called **quivers** — for probing, load testing, and validating your deployments.

Point Archer at a repo. It reads the maps (API specs), climbs the walls (parses code), learns the guardian's dialect (auth), and stocks your armory with ready-to-fire scripts. You pull the trigger.

---

## What It Does

1. **Scouts** your repository — OpenAPI spec, controllers, schemas, auth patterns
2. **Proposes** a quiver lineup — smoke tests, CRUD sequences, load tests, stress tests
3. **Crafts** bash scripts and drops them in `.archer/quivers/`
4. **Steps aside** — the scripts run anywhere bash runs, no framework required

```
.archer/
└── quivers/
    ├── precision-health.sh       # smoke: are the health endpoints alive?
    ├── volley-listing-crud.sh    # sequence: POST → GET → PUT → DELETE
    ├── barrage-listing-read.sh   # load: 50 GET requests, report latency
    └── sustained-write.sh        # stress: constant POST rate for 60s
```

Scripts are plain bash + curl. No dependencies. Drop them in any CI pipeline, run them locally, wire them up however you want.

---

## Getting Started

**Requirements:** Any AI agent that reads `CLAUDE.md` (Claude Code, Cursor, etc.)

```bash
# 1. Clone Archer
git clone https://github.com/your-handle/archer ~/Archer

# 2. Open your agent in the Archer directory
cd ~/Archer
claude          # or your agent of choice

# 3. Scout your service
/archer prep ~/Code/my-service
```

Archer will brief you on what it found, propose a quiver lineup, and wait for your go-ahead before crafting anything.

---

## Commands

| Command | What it does |
|---|---|
| `/archer prep [path]` | Scout a repo and build its quiver suite |
| `/archer inspect` | List quivers in the armory |
| `/archer draw [name]` | Preview a quiver without firing |
| `/archer fire [name]` | Execute a quiver locally |
| `/archer add-quiver` | Craft a new custom quiver |
| `/archer export` | Generate pipeline job stubs (GitLab, GitHub Actions, etc.) |

---

## Quiver Types

| Type | Purpose | Example |
|---|---|---|
| **Precision** | Smoke test — is it alive? | `GET /health` → expect 200 |
| **Volley** | CRUD workflow | POST → GET → PUT → DELETE |
| **Barrage** | Load spike | 50 requests, measure P50/P99 |
| **Sustained** | Stress test | 10 RPS for 60 seconds |

---

## Auth

Archer detects your auth pattern and templates it as environment variables in each script. You set the vars; Archer handles the headers.

```bash
export KONG_API_KEY="your-key"
bash .archer/quivers/volley-listing-crud.sh
```

---

## Pipeline Agnostic

Archer generates scripts, not pipeline config. The quivers in `.archer/quivers/` are plain bash — they run anywhere. When you're ready to wire them into your pipeline, run `/archer export` and Archer will generate the right job stubs for your system.

---

## Example Output

```
🏹 Scouting complete.

🏰 Fortress: nc-inventory-api (Spring Boot)
📍 Gates discovered: 12 endpoints
📜 Schemas mapped: Listing, Community, Record
🛡️  Guardian: Kong API key — stored in AWS Secrets Manager as 'odp-api-kong-key'
📋 Campaign scroll: GitLab CI detected

Proposed quivers:
  • precision-health            — smoke: /actuator/health, /actuator/health/readiness
  • volley-listing-crud         — CRUD: POST → GET → PUT → DELETE /api/v1/listings
  • volley-community-crud       — CRUD: POST → GET → PUT → DELETE /api/v1/communities
  • barrage-listing-read        — load: GET /api/v1/listings, 50 arrows
  • sustained-write             — stress: POST /api/v1/listings, 10 RPS / 60s

Shall I proceed?
```

---

## Philosophy

Archer is a craftsman, not a warrior. He prepares the ammunition — simple, honest arrows that fly true. The operator knows the battlefield. Archer stocks the armory.

See `examples/` for annotated sample quivers.

---

## Contributing

PRs welcome. If you've added support for a new framework, auth pattern, or quiver type — open a pull request. Archer grows stronger with every campaign.

## License

MIT
