# indexes

**Type:** Anytime scripts

Used for database indexes and index maintenance. Anytime scripts are re-run whenever they're changed.

Use this folder for:
- Creating new indexes
- Modifying existing index definitions
- Dropping obsolete indexes
- Maintaining index statistics
- Creating columnstore indexes or special index types

## Example

```sql
-- 0001_ix_users_email.sql
CREATE NONCLUSTERED INDEX [IX_Users_Email]
ON [dbo].[Users] ([Email])
INCLUDE ([UserId], [IsActive])
WHERE [DeletedDate] IS NULL;
```

```sql
-- 0002_ix_activities_userid_date.sql
CREATE NONCLUSTERED INDEX [IX_Activities_UserId_Date]
ON [dbo].[Activities] ([UserId], [ActivityDate] DESC)
INCLUDE ([ActivityType], [Description]);
```