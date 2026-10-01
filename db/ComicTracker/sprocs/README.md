# sprocs

**Type:** Anytime scripts

Used for stored procedures. Anytime scripts are re-run whenever they're changed (the script content hash is compared).

Use `CREATE OR ALTER` to allow scripts to be updated when changed.

Important: If you have stored procedures that depend on other stored procedures, ensure they are alphabetically ordered
so dependencies are created first.

## Example

```sql
-- 0001_sp_activity_insert.sql
CREATE OR ALTER PROCEDURE [dbo].[sp_InsertActivity]
	@UserId INT,
	@ActivityType NVARCHAR(50),
	@Description NVARCHAR(MAX) = NULL
AS
BEGIN
	INSERT INTO [dbo].[Activities] ([UserId], [ActivityType], [Description], [ActivityDate])
	VALUES (@UserId, @ActivityType, @Description, GETUTCDATE());
END;
```

```sql
-- 0002_sp_get_user_activities.sql
CREATE OR ALTER PROCEDURE [dbo].[sp_GetUserActivities]
	@UserId INT
AS
BEGIN
	SELECT
		[ActivityId],
		[ActivityType],
		[Description],
		[ActivityDate]
	FROM [dbo].[Activities]
	WHERE [UserId] = @UserId
	ORDER BY [ActivityDate] DESC;
END;
```
