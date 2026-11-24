# Notice

This package deploys **Hasura GraphQL Engine v2 Community Edition** (https://github.com/hasura/graphql-engine), Copyright Hasura, Inc., licensed under the **Apache License 2.0**. The image `hasura/graphql-engine:v2.51.9` is used unmodified as the base. Enterprise-only features (and the separate data-connector agent for non-Postgres databases) are not part of this template.

What is used and how:

- `services/hasura/railway-hasura.sh` is original work for this template; it validates the documented `HASURA_GRAPHQL_*` variables and runs the image's own `graphql-engine serve`.
- Configuration follows upstream `install-manifests/docker-compose/docker-compose.yaml`, `packaging/graphql-engine/Dockerfile` and the v2 server configuration reference (checked 2026-11-24, tag v2.51.9).
- PostgreSQL service definition from Railway's official templates.
- Icon: Dashboard Icons (https://github.com/homarr-labs/dashboard-icons).

Market templates were read for comparison only; no files or text were copied. README and docs text are original.

This is a community template and is not affiliated with or endorsed by Hasura, Inc. Hasura is a trademark of Hasura, Inc.
