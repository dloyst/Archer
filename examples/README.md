# Examples

These are annotated sample quivers — what Archer generates and places in your service's `.archer/quivers/` directory.

Each script is self-contained bash. No framework, no runtime dependencies beyond `curl` (and optionally `jq`).

---

## `quivers/precision-health.sh`

**Type:** Precision — single arrows, read-only, fast.

Fires at health/readiness endpoints and expects 200. If anything is wrong with the fortress, this is the first arrow to bounce.

This quiver runs in under 10 seconds. It's the one you'd wire up to run automatically after every deploy.

---

## `quivers/volley-crud.sh`

**Type:** Volley — a sequence targeting one entity through its full lifecycle.

Fires four arrows in order:
1. **POST** — create a test entity using a namespaced ID (`archer_[timestamp]_[random]_listing_001`)
2. **GET** — verify the entity was created
3. **PUT** — update a field
4. **DELETE** — clean up

The namespace ensures test data is predictable, traceable in your logs, and doesn't collide across runs. If the CREATE arrow misses, the volley halts — no orphaned data.

---

## What Archer Generates for Your Service

When you run `/archer prep` against a real repository, Archer generates quivers tailored to *your* endpoints, *your* schemas, and *your* auth pattern. The examples above are generic illustrations.

A real session might produce:

```
.archer/
└── quivers/
    ├── precision-health.sh           # your /health + /readiness endpoints
    ├── volley-listing-crud.sh        # CRUD for your Listing entity
    ├── volley-community-crud.sh      # CRUD for your Community entity
    ├── barrage-listing-read.sh       # 50 GET requests to /api/v1/listings
    └── sustained-listing-write.sh   # 10 POST/s for 60s
```

To get there: clone Archer, open your agent in the Archer directory, and run `/archer prep /path/to/your-service`.
