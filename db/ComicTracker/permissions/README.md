# permissions

**Type:** Everytime scripts (run every time grate executes)

Used for granting and revoking permissions. These scripts run on every migration, which ensures that permissions
are always in the desired state (idempotent).

This folder runs after all other scripts, so it's guaranteed that all database objects exist when permissions are applied.

Common use cases:
- Granting SELECT/INSERT/UPDATE/DELETE on tables
- Granting EXECUTE on stored procedures
- Granting permissions on schemas
- Revoking outdated permissions

Important: If you have permissions that depend on other permissions being granted first, ensure they are alphabetically
ordered so dependencies are in the correct order.

## Example

```sql
-- 0001_grant_app_permissions.sql
-- Grant permissions for the application user
GRANT EXECUTE ON SCHEMA::[dbo] TO [appuser];
GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[Users] TO [appuser];
GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[Activities] TO [appuser];
GRANT EXECUTE ON [dbo].[sp_InsertActivity] TO [appuser];
GO
```

```sql
-- 0002_grant_readonly_permissions.sql
-- Grant read-only permissions for reporting user
GRANT SELECT ON SCHEMA::[dbo] TO [readonlyuser];
GO
```
