# views

**Type:** Anytime scripts

Used for database views. Anytime scripts are re-run whenever they're changed (the script content hash is compared).

Important: If you have views that depend on other views, ensure they are alphabetically ordered
so dependencies are created first.

## Example

```sql
-- 0001_v_active_users.sql
CREATE OR ALTER VIEW [dbo].[v_ActiveUsers]
AS
SELECT
	[UserId],
	[UserName],
	[Email],
	[CreatedDate]
FROM [dbo].[Users]
WHERE [IsActive] = 1
	AND [DeletedDate] IS NULL;
```

```sql
-- 0002_v_user_activity_summary.sql
CREATE OR ALTER VIEW [dbo].[v_UserActivitySummary]
AS
SELECT
	u.[UserId],
	u.[UserName],
	COUNT(a.[ActivityId]) AS [TotalActivities],
	MAX(a.[ActivityDate]) AS [LastActivityDate]
FROM [dbo].[v_ActiveUsers] u
LEFT JOIN [dbo].[Activities] a ON u.[UserId] = a.[UserId]
GROUP BY u.[UserId], u.[UserName];
```
