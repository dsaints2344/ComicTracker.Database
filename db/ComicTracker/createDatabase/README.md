# createDatabase

**Type:** Anytime scripts

Used to provide a custom `CREATE DATABASE` script. If a script is placed here, grate will use it instead of the default
when creating a new database from scratch.

This is useful if you need to customize database creation behavior, such as:
- Setting specific collation
- Configuring file groups
- Setting recovery model
- Applying custom settings

If you don't need custom database creation, you can delete this folder.

## Example

```sql
-- 0001_create_database.sql
CREATE DATABASE [{{DatabaseName}}]
    COLLATE SQL_Latin1_General_CP1_CI_AS;
```
