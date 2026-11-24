# Deploy and Host Hasura GraphQL Engine with Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/hasura-graphql-engine-251-postgres?referralCode=20H68q)

Hasura GraphQL Engine gives you an instant, real-time GraphQL API, and REST endpoints, over a PostgreSQL database, with role-based permissions, event triggers, scheduled triggers and remote schemas. This template runs Hasura v2.51 Community Edition with PostgreSQL 18 and an admin secret that is always on.

## About Hosting Hasura GraphQL Engine

Hasura is a stateless Haskell server. It reads your Postgres schema and serves queries, mutations and subscriptions, enforcing row- and column-level permissions per role. Its own configuration, called metadata (tracked tables, relationships, permissions, triggers, actions), is stored in the `hdb_catalog` schema; this template keeps it in the same Postgres database as your data, which is also connected as the `default` source.

Without an admin secret, anyone who finds a Hasura URL has full admin access. This template generates `HASURA_GRAPHQL_ADMIN_SECRET`, protects the web console and admin API with it, and refuses to start open: an empty or short secret is replaced by a random one and the log explains the fix.

## Common Use Cases

- A GraphQL and REST backend for web and mobile apps on top of Postgres
- Real-time features with GraphQL subscriptions (live queries over WebSockets)
- Run webhooks on database changes (event triggers) or on a schedule (cron triggers)
- Unify existing REST/GraphQL services behind one API with actions and remote schemas

## Dependencies for Hasura GraphQL Engine Hosting

- Hasura GraphQL Engine v2.51.9 CE (`hasura/graphql-engine`, pinned by digest)
- PostgreSQL 18 (Railway's `postgres-ssl` image) for metadata and data

### Deployment Dependencies

- Hasura v2 documentation: https://hasura.io/docs/2.0/index/
- Server configuration reference: https://hasura.io/docs/2.0/deployment/graphql-engine-flags/reference/
- Source and releases: https://github.com/hasura/graphql-engine

### Implementation Details

| Service | What it does | Public |
|---|---|---|
| Hasura | GraphQL (`/v1/graphql`), REST, console (`/console`), port 8080 | yes |
| Postgres | Metadata (`hdb_catalog`) and your data (`default` source) | no |

**First login**

1. Open `https://{your-domain}/console`.
2. Enter the `HASURA_GRAPHQL_ADMIN_SECRET` from the Hasura service's Variables tab.
3. Create tables in the Data tab (or track existing ones), then set permissions per role.

**Calling the API.** Admin and server-side calls send the header `x-hasura-admin-secret: {secret}` to `https://{your-domain}/v1/graphql`. Never ship the admin secret to browsers or apps.

**End-user auth.** Set `HASURA_GRAPHQL_JWT_SECRET` to a JSON config (for example `{"type":"HS256","key":"{32+ random characters}"}` or a JWKS URL from your auth provider) so apps can send user tokens; permissions then apply per role. `HASURA_GRAPHQL_UNAUTHORIZED_ROLE` (for example `anonymous`) allows unauthenticated requests with that role's permissions. Both are empty by default, so only the admin secret works.

**Migrations and metadata as code.** Use the Hasura CLI with `--endpoint https://{your-domain} --admin-secret {secret}` to export or apply metadata and migrations.

**Production settings.** Dev mode is off, telemetry off, console assets served from the image. To turn the console off, set `HASURA_GRAPHQL_ENABLE_CONSOLE=false` and use the CLI console instead.

**More databases.** Add other Postgres databases as sources in the console (Data, Connect database) with their connection URLs.

**Scaling.** Hasura is stateless: raise the replica count of the Hasura service. All replicas share the metadata in Postgres.

**Versions.** The image is pinned in `services/hasura/Dockerfile` (`HASURA_IMAGE`, tag and digest). To upgrade within v2, use a newer v2 tag and digest and redeploy; Hasura migrates its catalog on start. Back up Postgres first.

**Resources.** Measured idle: Hasura about 0.2 GB RAM, Postgres about 0.1 GB. Runs on Trial, Hobby and Pro.

### Why Deploy Hasura GraphQL Engine on Railway?

Railway runs Hasura and Postgres together with private networking, a generated admin secret and a persistent database volume, so you have a secured GraphQL backend in minutes and pay only for what it uses.
