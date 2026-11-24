#!/usr/bin/env bash
# Railway start script for Hasura GraphQL Engine v2 CE (official image, unmodified).
# - The admin secret is always on: empty or shorter than 16 characters -> a random secret
#   nobody knows (the API and console stay locked) and the log says how to fix it.
#   Hasura without an admin secret would give anyone full admin access.
# - Empty or invalid optional JSON settings are dropped instead of failing the start.
# - Waits for Postgres (each probe limited to 3 s) before starting.
# Secret values are never printed.
set -u
log() { echo "[railway] $*"; }
warn() { echo "[railway] WARNING: $*" >&2; }

secret="${HASURA_GRAPHQL_ADMIN_SECRET:-}"
if [ "${#secret}" -lt 16 ]; then
  warn "HASURA_GRAPHQL_ADMIN_SECRET is empty or shorter than 16 characters. The API and console stay locked with a random secret nobody knows; set HASURA_GRAPHQL_ADMIN_SECRET (16+ characters) and redeploy."
  HASURA_GRAPHQL_ADMIN_SECRET="$(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')"
fi
export HASURA_GRAPHQL_ADMIN_SECRET
unset HASURA_GRAPHQL_ADMIN_SECRETS 2>/dev/null || true

for var in HASURA_GRAPHQL_JWT_SECRET HASURA_GRAPHQL_UNAUTHORIZED_ROLE HASURA_GRAPHQL_AUTH_HOOK; do
  if [ -z "${!var:-}" ]; then unset "$var"; fi
done
if [ -n "${HASURA_GRAPHQL_JWT_SECRET:-}" ]; then
  case "$HASURA_GRAPHQL_JWT_SECRET" in
    \{*\}) ;;
    *) warn "HASURA_GRAPHQL_JWT_SECRET is not a JSON object; JWT auth stays off (admin secret still required)"; unset HASURA_GRAPHQL_JWT_SECRET ;;
  esac
fi

case "${PORT:-}" in
  ''|*[!0-9]*) [ -n "${PORT:-}" ] && warn "PORT=${PORT} is not a number; using 8080"; PORT=8080 ;;
esac
if [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then warn "PORT=${PORT} is out of range; using 8080"; PORT=8080; fi
export PORT HASURA_GRAPHQL_SERVER_PORT="$PORT"

url="${HASURA_GRAPHQL_METADATA_DATABASE_URL:-${HASURA_GRAPHQL_DATABASE_URL:-}}"
if [ -z "$url" ]; then
  warn "HASURA_GRAPHQL_METADATA_DATABASE_URL is empty; reference the Postgres service (\${{Postgres.DATABASE_URL}})"
else
  hostport="${url#*@}"; hostport="${hostport%%/*}"; hostport="${hostport%%\?*}"
  host="${hostport%:*}"; port="${hostport##*:}"
  [ "$port" = "$hostport" ] && port=5432
  for i in $(seq 1 180); do
    if timeout 3 bash -c "</dev/tcp/${host}/${port}" 2>/dev/null; then
      log "Postgres is reachable"
      break
    fi
    [ $((i % 10)) -eq 1 ] && log "waiting for Postgres at ${host}:${port} (${i}/180)"
    sleep 2
  done
fi

log "starting Hasura GraphQL Engine on port ${PORT} (admin secret required; console ${HASURA_GRAPHQL_ENABLE_CONSOLE:-false})"
exec "${HGE_BINARY:-graphql-engine}" serve
