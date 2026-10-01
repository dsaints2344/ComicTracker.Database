# beforeMigration

**Type:** Everytime scripts (run every time grate executes)

Used for tasks you want to perform prior to any database migrations. These scripts run before any of the other migration
steps occur.

Common use cases:
- Database backups
- Disable replication
- Custom logging of migration start
- Health checks
- Cleanup of temporary objects

## Example

```sql
-- 0001_log_migration_start.sql
INSERT INTO [dbo].[MigrationLog] ([StartTime], [Environment])
VALUES (GETUTCDATE(), '{{Environment}}');
```
