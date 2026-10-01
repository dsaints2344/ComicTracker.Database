# Database Migration Project

This project contains SQL database migration scripts managed by **grate**, a SQL scripts migration runner.
See the [grate documentation](https://grate-devs.github.io/grate/) for complete reference.

## Quick Start

See [Environment Setup](#environment-setup) section below, then run:

```pwsh
./Deploy.ps1
```

This installs grate as a local tool and runs all migrations.

## Project Structure

This project uses a `.csproj` file to organize SQL migration scripts:

```
db/
├── ComicTracker/      (Database folder)
│   ├── up/                                     (One-time scripts - main migrations)
│   ├── functions/                              (Anytime scripts - rerun if changed)
│   ├── views/                                  (Anytime scripts - rerun if changed)
│   ├── sprocs/                                 (Anytime scripts - rerun if changed)
│   ├── triggers/                               (Anytime scripts - rerun if changed)
│   ├── indexes/                                (Anytime scripts - rerun if changed)
│   ├── permissions/                            (Everytime scripts - always run)
│   ├── afterMigration/                         (Everytime scripts - always run)
│   ├── beforeMigration/                        (Everytime scripts - always run)
│   ├── createDatabase/                         (Anytime scripts - custom database creation)
│   ├── alterDatabase/                          (Anytime scripts - database configuration)
│   ├── runAfterCreateDatabase/                 (Anytime scripts - after fresh create)
│   ├── runBeforeUp/                            (Anytime scripts - before one-time scripts)
│   ├── runFirstAfterUp/                        (One-time scripts - out-of-order)
│   └── runAfterOtherAnyTimeScripts/            (Anytime scripts - final cleanup)
├── README.md                                   (This file)
└── .env.example                                (Example environment variables)
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

Custom `CREATE DATABASE` script (uses default if omitted).

See [createDatabase/ folder](./db/ComicTracker/createDatabase/README.md) for details.

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

## Environment Setup

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

## Running Migrations

### Start SQL Server in Docker (local)

Use the helper script to create/start a local SQL Server container with defaults aligned to `.envrc` (localhost:1434):

```pwsh
./scripts/StartSqlServerDocker.ps1
```

With custom values:

```pwsh
./scripts/StartSqlServerDocker.ps1 -ContainerName "grate-sql-dev" -HostPort 1435 -SqlPassword "MyStrong!Passw0rd"
```

The script prints a ready-to-copy `export ConnectionStrings__...` line when the container is up.

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
