# Database Migration Project

This project contains SQL database migration scripts managed by **grate**, a SQL scripts migration runner.
See the [grate documentation](https://grate-devs.github.io/grate/) for complete reference.

## Quick Start

With Docker Desktop running:

```bash
cp .env.example .env                      # once; set your own SA password if you like
docker compose up --build migrations      # starts SQL Server, waits for it, runs all migrations
```

SQL Server is then available at `localhost,1434` (user `sa`, password from `.env`), with the `ComicTracker`
database created and migrated. See [Running with Docker](#running-with-docker) for details, or
[Running Migrations from the host](#running-migrations-from-the-host) to run grate without a container.

## Project Structure

This project uses a `.csproj` file to organize SQL migration scripts:

```
db/
└── ComicTracker/      (Database folder)
    ├── up/                                     (One-time scripts - main migrations)
    ├── functions/                              (Anytime scripts - rerun if changed)
    ├── views/                                  (Anytime scripts - rerun if changed)
    ├── sprocs/                                 (Anytime scripts - rerun if changed)
    ├── triggers/                               (Anytime scripts - rerun if changed)
    ├── indexes/                                (Anytime scripts - rerun if changed)
    ├── permissions/                            (Everytime scripts - always run)
    ├── afterMigration/                         (Everytime scripts - always run)
    ├── beforeMigration/                        (Everytime scripts - always run)
    ├── alterDatabase/                          (Anytime scripts - database configuration)
    ├── runAfterCreateDatabase/                 (Anytime scripts - after fresh create)
    ├── runBeforeUp/                            (Anytime scripts - before one-time scripts)
    ├── runFirstAfterUp/                        (One-time scripts - out-of-order)
    └── runAfterOtherAnyTimeScripts/            (Anytime scripts - final cleanup)
.github/workflows/
├── ci.yml                                      (Validates migrations, publishes the image)
└── deploy.yml                                  (Manual deploy to a cloud database)
Dockerfile                                      (Migration runner image: grate + db/ scripts)
compose.yaml                                    (Local SQL Server + migrations)
.env.example                                    (Example settings for compose - copy to .env)
README.md                                       (This file)
```

## Migration Folder Guide

grate processes folders in a fixed order. Each folder type behaves differently:

### **One-time Scripts** (run exactly once)

#### `up/`

The main migration folder. Contains DDL (schema changes) and DML (data changes).

- Scripts run exactly ONCE and never again
- Cannot be modified after running (prevents accidental data loss)
- If you need to fix something, create a NEW script
- **Naming:** Use zero-padded numbers: `0001_initial.sql`, `0002_add_users_table.sql`

See [up/ folder](./db/ComicTracker/up/README.md) for examples and guidelines.

#### `runFirstAfterUp/`

For out-of-order one-time scripts that must run after `up` but before anytime scripts.

See [runFirstAfterUp/ folder](./db/ComicTracker/runFirstAfterUp/README.md) for details.

### **Anytime Scripts** (rerun when changed)

#### `functions/`, `views/`, `sprocs/`, `triggers/`, `indexes/`

These scripts are re-run whenever their content changes (hash mismatch).

- **Create or Alter:** Always use `CREATE OR ALTER` for updateability
- **Dependencies:** Order scripts alphabetically if there are dependencies
- Useful for iterative development

See each folder's README for examples:
- [functions/](./db/ComicTracker/functions/README.md)
- [views/](./db/ComicTracker/views/README.md)
- [sprocs/](./db/ComicTracker/sprocs/README.md)
- [triggers/](./db/ComicTracker/triggers/README.md)
- [indexes/](./db/ComicTracker/indexes/README.md)

#### `beforeMigration/`

Runs before any migrations. Use for:
- Backups
- Pre-migration checks
- Disabling constraints

See [beforeMigration/ folder](./db/ComicTracker/beforeMigration/README.md) for examples.

#### `alterDatabase/`

Database configuration (not data). Use for:
- Recovery mode
- Query store settings
- Compatibility levels

See [alterDatabase/ folder](./db/ComicTracker/alterDatabase/README.md) for examples.

#### `createDatabase/`

Custom `CREATE DATABASE` script. This folder is intentionally **not** in the repo: when it exists, grate runs its
scripts *instead of* its default `CREATE DATABASE`, so an empty folder (or one holding only a README) means the
database is never created on a fresh server.

Only add it when you need custom creation (collation, file groups, ...), and always with a real script:

```sql
-- db/ComicTracker/createDatabase/0001_create_database.sql
CREATE DATABASE [{{DatabaseName}}]
    COLLATE SQL_Latin1_General_CP1_CI_AS;
```

#### `runAfterCreateDatabase/`

Only runs if the database is freshly created. Use for:
- Creating user accounts
- Default schemas
- Initial configuration

See [runAfterCreateDatabase/ folder](./db/ComicTracker/runAfterCreateDatabase/README.md) for examples.

#### `runBeforeUp/`

Runs before `up` scripts. Use for:
- Preparation work
- Temporary tables
- Prerequisites

See [runBeforeUp/ folder](./db/ComicTracker/runBeforeUp/README.md) for examples.

#### `runAfterOtherAnyTimeScripts/`

Runs after all other anytime scripts. Use for:
- Re-enabling constraints
- Index rebuilds
- Final cleanup

See [runAfterOtherAnyTimeScripts/ folder](./db/ComicTracker/runAfterOtherAnyTimeScripts/README.md) for examples.

### **Everytime Scripts** (always run)

#### `permissions/`

Runs on every migration to keep permissions in desired state (idempotent).

```sql
GRANT EXECUTE ON SCHEMA::[dbo] TO [appuser];
GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[Users] TO [appuser];
```

See [permissions/ folder](./db/ComicTracker/permissions/README.md) for examples.

#### `afterMigration/`

Runs after all migrations. Use for:
- Replication re-enabling
- Statistics updates
- Post-migration validation

See [afterMigration/ folder](./db/ComicTracker/afterMigration/README.md) for examples.

## Running with Docker

`compose.yaml` defines two services:

| Service | What it does |
| --- | --- |
| `sqlserver` | SQL Server 2025 on `localhost,1434` (`SQL_HOST_PORT`); data is kept in the `sqlserver-data` volume |
| `migrations` | Builds the migration image (`Dockerfile`: grate 2.1.6 + `db/ComicTracker`), waits for SQL Server to be healthy, applies pending scripts, then exits (0 = success) |

Settings come from `.env` (copy `.env.example`): `MSSQL_SA_PASSWORD`, `SQL_HOST_PORT`, `GRATE_ENVIRONMENT`.

```bash
docker compose up -d --wait sqlserver        # start SQL Server (no-op if already running)
docker compose run --rm --build migrations   # apply new/changed scripts
docker compose logs sqlserver                # SQL Server logs
docker compose down                          # stop, keep the data
docker compose down -v                       # stop and delete the database (next run starts fresh)
```

Re-run `migrations` after adding or changing scripts; `--build` bakes the current `db/` folder into the image.

> **Apple Silicon:** SQL Server images are amd64-only. Docker Desktop runs them through Rosetta, so keep
> *Settings → General → Use Rosetta for x86_64/amd64 emulation on Apple Silicon* enabled.

### Using from another service

The migration container exits when it's done, so other services (e.g. a future ComicTracker API) can wait for it:

```yaml
services:
  api:
    # ...
    depends_on:
      migrations:
        condition: service_completed_successfully
```

Outside this repo, use the published image instead of building it:
`image: ghcr.io/dsaints2344/comictracker-database:<tag>`, with the same environment variables as in `compose.yaml`.

## Environment Setup

These are for running grate from the host (`./Deploy.ps1`); the Docker setup above doesn't need them.

### Required Environment Variables

Set these before running migrations:

```bash
# Connection string to the database
export ConnectionStrings__ComicTracker="Server=localhost;Database=MyDatabase;Integrated Security=true;"

# Environment name (affects which environment-specific scripts run)
export GrateEnvironment=LOCAL  # or DEV, STAGING, PRODUCTION
```

### Optional Environment Variables

```bash
export GrateSchemaName=grate           # defaults to 'grate'
export CommandTimeout=60               # command timeout in seconds
export AdminCommandTimeout=300         # admin command timeout in seconds
export Transaction=false               # run in transaction mode
export DryRun=false                    # log what would run but don't execute
```

Create or update `.envrc` with the required values above, and customize it as needed for your environment.

## Running Migrations from the host

### Start SQL Server in Docker (local)

```bash
docker compose up -d --wait sqlserver
```

The matching connection string for `.envrc` (password from `.env`):

```bash
export ConnectionStrings__ComicTracker='Data Source=localhost,1434;Initial Catalog=ComicTracker;User Id=sa;Password=<MSSQL_SA_PASSWORD>;TrustServerCertificate=True'
```

### Local Development

```pwsh
./Deploy.ps1
```

With parameters:

```pwsh
./Deploy.ps1 -Environment "LOCAL" -ConnectionString "Server=localhost;Database=MyDB;Integrated Security=true;" -Version "1.0.0"
```

### Environment-Specific Scripts

Create scripts with environment qualifiers to run only in specific environments.
The filename must contain a literal `.env.` segment:

```
0001_data_seed.sql                        # Always runs
0002_seed_data.env.DEV.sql                # Only in DEV environment
0003_test_data.env.LOCAL.sql              # Only in LOCAL environment
0004_production_config.env.PRODUCTION.sql # Only in PRODUCTION environment
```

## Configuration

grate is primarily configured via command-line arguments.
For reusable argument sets, use response files (`.rsp`) as documented here:
[Response Files](https://grate-devs.github.io/grate/response-files/)

Example `grate_settings.rsp`:

```text
--connectionstring Server=localhost;Database=MyDatabase;Integrated Security=true;
--files ./db/ComicTracker
--environment LOCAL
--version 1.0.0
```

Run with:

```pwsh
grate @./grate_settings.rsp
```

See [grate configuration options](https://grate-devs.github.io/grate/configuration-options/) for full CLI argument reference.

## Packaging for Distribution

To package this project as a NuGet package:

```pwsh
nuget pack
```

This creates a `.nupkg` file that can be:
- Deployed to NuGet feed
- Used in CI/CD pipelines
- Shared across environments

## CI/CD

[`ci.yml`](./.github/workflows/ci.yml) runs on every pull request and on pushes to `main`:

1. **Validate:** starts SQL Server with `compose.yaml`, runs all migrations against a fresh database, then runs
   them a second time to prove a re-run is a clean no-op.
2. **Publish** (`main` only): builds the image for `linux/amd64` and `linux/arm64` and pushes it to GitHub
   Container Registry as `ghcr.io/dsaints2344/comictracker-database`, tagged with:
   - the GitVersion SemVer (e.g. `0.1.0`), which is also the version grate records in the database
   - `sha-<short commit>`
   - `latest`

The package appears under the repository's **Packages**. Its visibility is set in the package settings; it can stay
private, since the deploy workflow authenticates with the repository's `GITHUB_TOKEN`.

## Deploying to a cloud database

[`deploy.yml`](./.github/workflows/deploy.yml) is started manually (**Actions → Deploy database → Run workflow**)
with a target environment (`DEV` or `PRODUCTION`) and an image tag published by CI. It runs the image on a
GitHub-hosted runner with `CREATE_DATABASE=false`, the same `-dnc` behavior `Deploy.ps1` uses outside LOCAL.

One-time setup for each target:

1. **Create the database.** Any SQL Server reachable over the internet works. For example, Azure SQL with the
   free serverless offer:

   ```bash
   az group create -n comictracker-rg -l eastus
   az sql server create -g comictracker-rg -n <server-name> -l eastus \
     --admin-user <admin-user> --admin-password '<admin-password>'
   az sql db create -g comictracker-rg -s <server-name> -n ComicTracker \
     --edition GeneralPurpose --compute-model Serverless --family Gen5 --capacity 2 \
     --use-free-limit --free-limit-exhaustion-behavior AutoPause
   ```

2. **Let GitHub's runners connect.** Hosted runners don't have fixed IPs. Either allow the published
   [GitHub Actions IP ranges](https://api.github.com/meta) in the database firewall, or add a workflow step that opens
   a firewall rule for the runner's IP before the migration and removes it afterwards.
3. **Add a GitHub Environment** named `DEV` or `PRODUCTION` (**Settings → Environments**) with the secret
   `DB_CONNECTION_STRING`, e.g.
   `Server=tcp:<server-name>.database.windows.net,1433;Database=ComicTracker;User Id=<user>;Password=<password>;Encrypt=True`.
   Add required reviewers to `PRODUCTION` so production migrations need an approval.
4. **Run the Deploy database workflow** with the environment and an image tag from CI.

The environment name is also passed to grate, so `*.env.DEV.sql` / `*.env.PRODUCTION.sql` scripts run only there.

## Common Patterns

### Adding a New Table

1. Create `db/ComicTracker/up/0NNN_create_my_table.sql`
2. Run `./Deploy.ps1`

### Adding a Stored Procedure

1. Create `db/ComicTracker/sprocs/0NNN_sp_my_procedure.sql`
2. Use `CREATE OR ALTER PROCEDURE` (not `CREATE PROCEDURE`)
3. Run `./Deploy.ps1` - it will update automatically

### Adding a View

1. Create `db/ComicTracker/views/0NNN_v_my_view.sql`
2. Use `CREATE OR ALTER VIEW`
3. Run `./Deploy.ps1` - it will update automatically

### Setting Up Permissions

Edit `permissions/` folder scripts to grant/revoke access:

```sql
GRANT EXECUTE ON [dbo].[sp_MyProcedure] TO [appuser];
GRANT SELECT, INSERT, UPDATE ON [dbo].[MyTable] TO [appuser];
```

These run on every migration, so permissions are always in desired state.

## Troubleshooting

### Script Already Ran (and can't be modified)

You modified a one-time script in the `up` folder after it ran. Solution: Create a NEW script that makes the correction.

```sql
-- Incorrect: 0001_create_users.sql (already ran, can't modify)

-- Correct: Create new migration
-- 0002_fix_users_table.sql
ALTER TABLE [dbo].[Users] ADD [NewColumn] INT;
```

### Scripts Not Running

Check:
1. Environment variables are set correctly
2. Database connection is accessible
3. Script file naming (alphabetical order matters)
4. Script content hash (for anytime scripts)

Use `--dryrun` to see what would run:

```pwsh
grate --dryrun --connectionstring "..." --files "./db/ComicTracker"
```

### Roll Back a Migration

grate doesn't support rollback (by design - how would you undo a DROP COLUMN?).

Instead:
1. Back up database before running migrations
2. Use transaction mode: `grate --transaction ...`
3. Create a corrective script (new migration) if you need to fix something

## References

- [grate Documentation](https://grate-devs.github.io/grate/)
- [Getting Started Guide](https://grate-devs.github.io/grate/getting-started/)
- [Configuration Options](https://grate-devs.github.io/grate/configuration-options/)
- [Script Types](https://grate-devs.github.io/grate/script-types/)
- [Environment-Specific Scripts](https://grate-devs.github.io/grate/environment-scripts/)
- [Token Replacement](https://grate-devs.github.io/grate/token-replacement/)
