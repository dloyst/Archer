#!/usr/bin/env bash
# ============================================================
# Quiver:  volley-listing-crud
# Type:    volley
# Target:  example-service
# Crafted by Archer on 2026-03-27
#
# Purpose: Full lifecycle test for the Listing entity.
#          Fires a sequence: POST → GET → PUT → DELETE
#          Uses a namespaced ID so test data is predictable
#          and cleanup is guaranteed.
#
# Requires: curl, jq (optional — graceful fallback if missing)
# ============================================================

set -euo pipefail

# --- TARGET ---
BASE_URL="${SERVICE_URL:-https://example-service.dev.internal.net}"

# --- AUTH ---
# Kong API key required.
# Local:  export KONG_API_KEY="your-key"
# CI:     set KONG_API_KEY as a pipeline variable
if [ -z "${KONG_API_KEY:-}" ]; then
  echo "❌ KONG_API_KEY is not set. Cannot fire arrows."
  exit 1
fi
AUTH_HEADER="apikey: ${KONG_API_KEY}"

# --- NAMESPACE ---
# Every run gets a unique prefix so test data never collides
# and is easy to find/clean in your datastore.
ARCHER_NS="archer_$(date +%s)_$(openssl rand -hex 4)"
LISTING_ID="${ARCHER_NS}_listing_001"

# --- HELPERS ---
check_jq() {
  command -v jq &>/dev/null
}

fire() {
  local label="$1"; shift
  local method="$1"; shift
  local path="$1"; shift
  local extra_args=("$@")

  echo "→ $method $path"
  HTTP_CODE=$(curl -s -o /tmp/archer_response.json -w "%{http_code}" \
    -X "$method" \
    -H "Content-Type: application/json" \
    -H "$AUTH_HEADER" \
    "${extra_args[@]}" \
    "$BASE_URL$path")
  DURATION=$(curl -s -o /dev/null -w "%{time_total}" \
    -X "$method" \
    -H "Content-Type: application/json" \
    -H "$AUTH_HEADER" \
    "${extra_args[@]}" \
    "$BASE_URL$path" 2>/dev/null || echo "0")
  DURATION_MS=$(echo "$DURATION" | awk '{printf "%.0f", $1 * 1000}')
  echo "  HTTP $HTTP_CODE (${DURATION_MS}ms)"
  echo "$HTTP_CODE"
}

# ============================================================
echo "🏹 Firing quiver: volley-listing-crud"
echo "🎯 Target: $BASE_URL"
echo "🏷️  Namespace: $ARCHER_NS"
echo ""

PASS=0
FAIL=0

# ============================================================
# Arrow 1: CREATE
# ============================================================
echo "--- Arrow 1/4: CREATE listing ---"
RESPONSE_CODE=$(curl -s -o /tmp/archer_response.json -w "%{http_code}" \
  -X POST \
  -H "Content-Type: application/json" \
  -H "$AUTH_HEADER" \
  -d "{
    \"id\": \"$LISTING_ID\",
    \"address\": \"123 Archer Test Lane\",
    \"price\": 450000,
    \"status\": \"active\"
  }" \
  "$BASE_URL/api/v1/listings")

echo "→ POST /api/v1/listings"
if [ "$RESPONSE_CODE" = "201" ] || [ "$RESPONSE_CODE" = "200" ]; then
  echo "  ✅ $RESPONSE_CODE — listing created"
  PASS=$((PASS + 1))
else
  echo "  ❌ $RESPONSE_CODE — expected 201"
  echo "  Response: $(cat /tmp/archer_response.json 2>/dev/null || echo '(empty)')"
  echo ""
  echo "⚠️  Arrow missed on CREATE. Halting volley to prevent orphaned test data."
  exit 1
fi
echo ""

# ============================================================
# Arrow 2: READ (verify)
# ============================================================
echo "--- Arrow 2/4: READ listing ---"
RESPONSE_CODE=$(curl -s -o /tmp/archer_response.json -w "%{http_code}" \
  -X GET \
  -H "$AUTH_HEADER" \
  "$BASE_URL/api/v1/listings/$LISTING_ID")

echo "→ GET /api/v1/listings/$LISTING_ID"
if [ "$RESPONSE_CODE" = "200" ]; then
  echo "  ✅ $RESPONSE_CODE — listing found"
  if check_jq; then
    RETURNED_ID=$(jq -r '.id // empty' /tmp/archer_response.json 2>/dev/null)
    if [ "$RETURNED_ID" = "$LISTING_ID" ]; then
      echo "  ✓ ID verified"
    fi
  fi
  PASS=$((PASS + 1))
else
  echo "  ❌ $RESPONSE_CODE — expected 200"
  FAIL=$((FAIL + 1))
fi
echo ""

# ============================================================
# Arrow 3: UPDATE
# ============================================================
echo "--- Arrow 3/4: UPDATE listing ---"
RESPONSE_CODE=$(curl -s -o /tmp/archer_response.json -w "%{http_code}" \
  -X PUT \
  -H "Content-Type: application/json" \
  -H "$AUTH_HEADER" \
  -d '{"status": "pending"}' \
  "$BASE_URL/api/v1/listings/$LISTING_ID")

echo "→ PUT /api/v1/listings/$LISTING_ID"
if [ "$RESPONSE_CODE" = "200" ]; then
  echo "  ✅ $RESPONSE_CODE — listing updated"
  PASS=$((PASS + 1))
else
  echo "  ❌ $RESPONSE_CODE — expected 200"
  FAIL=$((FAIL + 1))
fi
echo ""

# ============================================================
# Arrow 4: DELETE (cleanup)
# ============================================================
echo "--- Arrow 4/4: DELETE listing ---"
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X DELETE \
  -H "$AUTH_HEADER" \
  "$BASE_URL/api/v1/listings/$LISTING_ID")

echo "→ DELETE /api/v1/listings/$LISTING_ID"
if [ "$RESPONSE_CODE" = "204" ] || [ "$RESPONSE_CODE" = "200" ]; then
  echo "  ✅ $RESPONSE_CODE — listing deleted"
  PASS=$((PASS + 1))
else
  echo "  ❌ $RESPONSE_CODE — expected 204"
  echo "  ⚠️  Cleanup failed. Test data may remain: $LISTING_ID"
  FAIL=$((FAIL + 1))
fi

# ============================================================
# Summary
# ============================================================
echo ""
echo "🎯 Quiver complete."
echo "   Hits: $PASS  Misses: $FAIL  Namespace: $ARCHER_NS"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
