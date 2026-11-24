# Hasura GraphQL Engine 2.51 (Postgres): composer spec

Listing name: **Hasura GraphQL Engine 2.51 (Postgres)**
Description (71 chars): Instant GraphQL and REST APIs on Postgres, console behind admin secret.
Category: Other. Icon: `https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/hasura.svg`
Repository: `baranberkay96/hasura-railway` (this folder is the repo root).

## Services

| Service | Source | Public | Volume | Healthcheck |
|---|---|---|---|---|
| Hasura | repo `/services/hasura` (`FROM hasura/graphql-engine:v2.51.9@sha256:70fba12a…0baf`, released 2026-11-19, Ubuntu 24.04) | domain → 8080 | none | `/healthz`, 600 s |
| Postgres | `ghcr.io/railwayapp-templates/postgres-ssl:18.6@sha256:4fc833b4…c863` | no | `/var/lib/postgresql/data` | — |

No required inputs.

## Start sequence (`railway-hasura.sh`)

1. `HASURA_GRAPHQL_ADMIN_SECRET` under 16 characters (incl. empty) → random secret nobody knows + log hint (never open).
2. Empty optional variables (`HASURA_GRAPHQL_JWT_SECRET`, `HASURA_GRAPHQL_UNAUTHORIZED_ROLE`, `HASURA_GRAPHQL_AUTH_HOOK`) are unset; a JWT secret that is not a JSON object is dropped with a warning.
3. Invalid `PORT` → 8080; `HASURA_GRAPHQL_SERVER_PORT=$PORT`.
4. Waits up to 6 min for Postgres (`timeout 3` per probe).
5. `exec graphql-engine serve`.

## Improvements over market templates

Market (2026-11): "Hasura" 3 active: `:latest`, a literal admin secret and Postgres password written into the template, no healthcheck. "Hasura" 4 active: `:latest`, two Postgres services (separate metadata DB), query logs on. Third: `:latest`, no admin secret at all (open admin API).

- Pinned v2.51.9 by digest; one Postgres 18 for metadata and data (as requested); healthcheck `/healthz`.
- Admin secret generated and enforced; console and admin API locked; dev mode and telemetry off; console assets local.
- Postgres wait, graceful shutdown/draining, IPv4+IPv6 listener.

## Resources

See "Measured" below. Prices: RAM $10/GB-month, vCPU $20/month, volume $0.15/GB-month. Minimum plan: Trial.

## Verification checklist

1. Both services SUCCESS; `/healthz` 200.
2. `/v1/graphql` without secret → access denied; with `x-hasura-admin-secret` → 200.
3. Create a table via `/v2/query` (run_sql), track it via `/v1/metadata`, insert and query through GraphQL.
4. Console `/console` loads and asks for the admin secret.
5. Redeploy: metadata and data kept.
6. `HASURA_GRAPHQL_ADMIN_SECRET=abc` → SUCCESS with warning; `abc` rejected.

## Open questions

- None known.
