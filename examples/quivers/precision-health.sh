#!/usr/bin/env bash
# ============================================================
# Quiver:  precision-health
# Type:    precision
# Target:  example-service
# Crafted by Archer on 2026-03-27
#
# Purpose: Confirm the fortress is standing.
#          Fires single arrows at health endpoints.
#          Expects 200. Fails loudly on anything else.
# ============================================================

set -euo pipefail

# --- TARGET ---
# Override SERVICE_URL to target a different environment.
# Example: SERVICE_URL=https://my-service.prod.example.com bash precision-health.sh
BASE_URL="${SERVICE_URL:-https://example-service.dev.internal.net}"

# --- AUTH ---
# This service uses Kong API key authentication.
# Set the following before firing:
#   export KONG_API_KEY="your-api-key"
#
# Local: retrieve from your team's secrets store and export.
# CI: add KONG_API_KEY as a pipeline variable (Settings > CI/CD > Variables in GitLab,
#     or as a repository secret in GitHub Actions).
#
# If you're unsure where to find the key, check with your platform team.
if [ -z "${KONG_API_KEY:-}" ]; then
  echo "❌ KONG_API_KEY is not set. Cannot fire arrows."
  echo "   export KONG_API_KEY=\"your-key\" and try again."
  exit 1
fi
AUTH_HEADER="apikey: ${KONG_API_KEY}"

# --- SETUP ---
PASS=0
FAIL=0
START_TIME=$(date +%s)

echo "🏹 Firing quiver: precision-health"
echo "🎯 Target: $BASE_URL"
echo ""

# ============================================================
# Arrow 1: Health
# ============================================================
echo "→ GET /actuator/health"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code} %{time_total}" \
  -H "$AUTH_HEADER" \
  "$BASE_URL/actuator/health")
STATUS=$(echo "$RESPONSE" | awk '{print $1}')
DURATION=$(echo "$RESPONSE" | awk '{printf "%.0f", $2 * 1000}')

if [ "$STATUS" = "200" ]; then
  echo "  ✅ $STATUS (${DURATION}ms)"
  PASS=$((PASS + 1))
else
  echo "  ❌ $STATUS (${DURATION}ms) — expected 200"
  FAIL=$((FAIL + 1))
fi

# ============================================================
# Arrow 2: Readiness
# ============================================================
echo "→ GET /actuator/health/readiness"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code} %{time_total}" \
  -H "$AUTH_HEADER" \
  "$BASE_URL/actuator/health/readiness")
STATUS=$(echo "$RESPONSE" | awk '{print $1}')
DURATION=$(echo "$RESPONSE" | awk '{printf "%.0f", $2 * 1000}')

if [ "$STATUS" = "200" ]; then
  echo "  ✅ $STATUS (${DURATION}ms)"
  PASS=$((PASS + 1))
else
  echo "  ❌ $STATUS (${DURATION}ms) — expected 200"
  FAIL=$((FAIL + 1))
fi

# ============================================================
# Summary
# ============================================================
END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))

echo ""
echo "🎯 Quiver complete."
echo "   Hits: $PASS  Misses: $FAIL  Time: ${TOTAL_TIME}s"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
