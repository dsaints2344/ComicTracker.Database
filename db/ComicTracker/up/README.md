# up

**Type:** One-time scripts

This is where the bulk of your migration scripts go. These scripts run exactly once and never again.
If a one-time script is modified after it has run, grate will fail (by design, to prevent accidental data loss).

Common use cases:
- Creating tables
- Adding columns
- Removing columns
- Creating indexes
- Inserting reference data
- Migrating data
- Any one-time schema changes

**Important:** Every schema change requires a NEW script. You cannot modify an up script after it has been run.
If you need to correct something, create a new script that makes the correction.


## Naming Convention

Files run in alphabetical order. Use one of these formats:
- **Zero-padded numbers** (recommended): `0001_initial.sql`, `0002_add_users_table.sql`, `0003_add_email_column.sql`
- **Timestamps**: `20210101000000_initial.sql`, `20210101000100_add_users_table.sql`
- **Another format**: Pick what works for your team

## Example


```sql
-- 0001_create_schema.sql
CREATE SCHEMA [app];
GO
```

```sql
-- 0002_create_users_table.sql
CREATE TABLE [app].[Users] (
	[UserId] INT IDENTITY PRIMARY KEY,
	[UserName] NVARCHAR(100) NOT NULL UNIQUE,
	[Email] NVARCHAR(255) NOT NULL,
	[CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
	[DeletedDate] DATETIME2 NULL
);
GO
```

```sql
-- 0003_insert_admin_user.sql
INSERT INTO [app].[Users] ([UserName], [Email])
VALUES ('admin', 'admin@example.com');
GO
```

## Important Notes

**Immutability:** One-time scripts cannot be modified after they have run. If you need to make a correction, create a new script.

**Transaction support:** Use `--transaction` flag with grate to wrap all scripts in a transaction and rollback on failure.
