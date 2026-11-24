# Hasura GraphQL Engine v2.51.9 Community Edition (Apache-2.0), official image unmodified
# (Ubuntu 24.04), pinned by index digest, plus a start script that keeps the admin secret
# always on and waits for Postgres.
ARG HASURA_IMAGE=hasura/graphql-engine:v2.51.9@sha256:70fba12ae0967b75f33cdc5b67280a264777a46e8dfcd89859a1c4ff1fe80baf
FROM ${HASURA_IMAGE}

COPY --chmod=0755 railway-hasura.sh /usr/local/bin/railway-hasura.sh

ENV PORT=8080
CMD ["/usr/local/bin/railway-hasura.sh"]
