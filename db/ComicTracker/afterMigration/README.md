# afterMigration

**Type:** Everytime scripts (run every time grate executes)

Used for tasks you want to perform after all database migrations are complete.
These scripts run at the very end of the migration process, after permissions and all other scripts.

Common use cases:
- Re-enabling replication
- Re-enabling database mail
- Updating statistics
- Rebuilding indexes
- Running maintenance jobs
- Logging migration completion
- Notifications
- Post-migration validation

## Example

```sql
-- 0001_update_statistics.sql
EXEC sp_updatestats;
```

```sql
-- 0002_log_migration_complete.sql
INSERT INTO [dbo].[MigrationLog] ([CompletedTime], [Environment], [Status])
VALUES (GETUTCDATE(), '{{Environment}}', 'SUCCESS');
```
