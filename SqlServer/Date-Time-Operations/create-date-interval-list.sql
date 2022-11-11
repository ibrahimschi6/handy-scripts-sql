DECLARE	 @StartDate DATE;
DECLARE	 @EndDate DATE;
	

SET @StartDate = '2022-01-01';
SET @EndDate = '2022-11-11';

WITH DateRange(Date) AS
     (
         SELECT
             @StartDate Date
         UNION ALL
         SELECT
             DATEADD(day, 1, Date) Date
         FROM
             DateRange
         WHERE
             Date < @EndDate
     )

     SELECT	Date
     FROM DateRange 
	 OPTION (MaxRecursion 10000);