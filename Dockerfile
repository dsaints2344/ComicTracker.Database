# Migration runner image: grate + this repo's SQL scripts.
# Runs to completion (applies pending scripts, then exits) - see compose.yaml.
#
# The base image's ENTRYPOINT is driven by environment variables:
#   APP_CONNSTRING   connection string (required)
#   ENVIRONMENT      grate environment, e.g. LOCAL, DEV, PRODUCTION (default LOCAL)
#   CREATE_DATABASE  create the database if missing (default true)
#   TRANSACTION      run all scripts in a single transaction (default false)
#   VERSION          version recorded in grate's Version table (baked in at build time)
FROM erikbra/grate:2.1.6

ARG VERSION=0.0.0-local
ENV VERSION=${VERSION}

# Run as non-root; the base image's /output (grate logs) is root-owned
RUN adduser -D -u 1001 grate && chown -R grate /output

COPY --chown=grate db/ComicTracker/ /db/

USER grate
