# triggers

**Type:** Anytime scripts

Used for database triggers (DML/DDL triggers). Anytime scripts are re-run whenever they're changed.

Use `CREATE OR ALTER` to allow triggers to be updated when changed.

Important: If you have triggers that depend on other triggers, ensure they are alphabetically ordered.

## Example

```sql
-- 0001_tr_users_audit.sql
CREATE OR ALTER TRIGGER [dbo].[tr_Users_Audit]
ON [dbo].[Users]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;
    
	INSERT INTO [dbo].[UsersAuditLog] ([UserId], [ChangeType], [OldValues], [NewValues], [ChangedDate], [ChangedBy])
	SELECT
		ISNULL(i.[UserId], d.[UserId]),
		CASE WHEN i.[UserId] IS NOT NULL AND d.[UserId] IS NULL THEN 'INSERT'
			 WHEN i.[UserId] IS NOT NULL AND d.[UserId] IS NOT NULL THEN 'UPDATE'
			 ELSE 'DELETE'
		END,
		NULL, -- Simplified - normally would serialize old values
		NULL, -- Simplified - normally would serialize new values
		GETUTCDATE(),
		SYSTEM_USER
	FROM INSERTED i
	FULL OUTER JOIN DELETED d ON i.[UserId] = d.[UserId];
END;
```