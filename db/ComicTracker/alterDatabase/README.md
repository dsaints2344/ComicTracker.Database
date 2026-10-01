# alterDatabase

**Type:** Anytime scripts

Used for scripts that alter the database configuration itself (rather than the contents of the database).
These scripts will be rerun whenever they are changed.

Common use cases:
- Setting recovery modes
- Enabling query stores
- Configuring database settings
- File groups configuration
- Setting compatibility level

Note: This runs after createDatabase and before runAfterCreateDatabase, so use this for configuration that should
apply to newly created databases.

## Example

```sql
-- 0001_set_recovery_mode.sql
ALTER DATABASE [{{DatabaseName}}] SET RECOVERY FULL;
ALTER DATABASE [{{DatabaseName}}] SET ENABLE_BROKER;
```