# functions

**Type:** Anytime scripts

Used for scalar functions, table-valued functions, and other database functions.
Anytime scripts are re-run whenever they're changed (the script content hash is compared with the database).

Important: If you have functions that depend on other functions, ensure they are alphabetically ordered
so dependencies are created first.

## Example

```sql
-- 0001_fn_format_name.sql
CREATE OR ALTER FUNCTION [dbo].[fn_FormatName] (@FirstName NVARCHAR(100), @LastName NVARCHAR(100))
	RETURNS NVARCHAR(201)
AS
BEGIN
	RETURN CONCAT(LTRIM(RTRIM(@FirstName)), ' ', LTRIM(RTRIM(@LastName)));
END;
```

```sql
-- 0002_fn_calculate_age.sql
CREATE OR ALTER FUNCTION [dbo].[fn_CalculateAge] (@BirthDate DATE)
	RETURNS INT
AS
BEGIN
	RETURN DATEDIFF(YEAR, @BirthDate, CAST(GETDATE() AS DATE))
		   - CASE WHEN MONTH(@BirthDate) > MONTH(GETDATE())
				  OR (MONTH(@BirthDate) = MONTH(GETDATE()) AND DAY(@BirthDate) > DAY(GETDATE()))
				  THEN 1 ELSE 0 END;
END;
```