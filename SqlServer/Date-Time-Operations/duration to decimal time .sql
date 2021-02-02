CREATE TABLE [dbo].[timetracking](
    [qbsql_id] [int] IDENTITY(1,1) NOT NULL,
    [username_id] [int] NULL,
    [TxnDate] [datetime2](0) NULL,
    [Duration] [varchar](50) NULL,
PRIMARY KEY CLUSTERED ([qbsql_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[timetracking] ON 
GO

INSERT [dbo].[timetracking] ([qbsql_id], [username_id], [TxnDate], [Duration]) VALUES 
(1, 1, CAST(N'2018-02-02T00:00:00.0000000' AS DateTime2), N'PT8H0M'),
(2, 2, CAST(N'2018-02-01T00:00:00.0000000' AS DateTime2), N'PT7H30M'),
(3, 1, CAST(N'2018-02-01T00:00:00.0000000' AS DateTime2), N'PT1H0M'),
(4, 1, CAST(N'2018-02-01T00:00:00.0000000' AS DateTime2), N'PT4H45M5S'),
(5, 1, CAST(N'2018-02-01T00:00:00.0000000' AS DateTime2), N'PT45M'),
(6, 1, CAST(N'2018-02-01T00:00:00.0000000' AS DateTime2), N'PT4H50S')
GO
SET IDENTITY_INSERT [dbo].[timetracking] OFF

/*
    ISO 8601 format for specifing duration is P[n]Y[n]M[n]DT[n]H[n]M[n]S.
    each letter is a designator and each [n] is an int value, except the last [n] that might be a decimal.
    the duration starts with a 'P' (for period), followed by at least one value ([n] + designator).
    each designator describes the number to it's left, so P1D means a period of one day.
    The M designator stands for months, unless the T designator preceeds it, and in that case it stands for minutes.
    For more information, see https://en.wikipedia.org/wiki/ISO_8601#Durations.
*/
    
    ;WITH CTE1 AS
    (
        SELECT  [qbsql_id], 
                [username_id], 
                [TxnDate], 
                [Duration],
                CHARINDEX('P', Duration) As Ppos,
                NULLIF(CHARINDEX('Y', Duration), 0) As Ypos,
                NULLIF(CHARINDEX('M', Duration), 0) As Monpos,
                NULLIF(CHARINDEX('D', Duration), 0) As Dpos,
                NULLIF(CHARINDEX('T', Duration), 0) As Tpos,
                NULLIF(CHARINDEX('H', Duration), 0) As Hpos,
                NULLIF(CHARINDEX('M', Duration, CHARINDEX('T', Duration)), 0) As Minpos,
                NULLIF(CHARINDEX('S', Duration), 0) As Spos
        FROM timetracking
    ), CTE2 AS
    (
        SELECT  [qbsql_id], 
                [username_id], 
                [TxnDate], 
                [Duration],
                Ppos,
                COALESCE(Ypos, Ppos) AS Ypos,
                COALESCE(Monpos, Ypos, Ppos) AS Monpos,
                COALESCE(Dpos, Monpos, Ypos, Ppos) AS Dpos,
                COALESCE(Tpos, Dpos, Monpos, Ypos, Ppos) AS Tpos,
                COALESCE(Hpos, Tpos, Dpos, Monpos, Ypos, Ppos) AS Hpos,
                COALESCE(Minpos, Hpos, Tpos, Dpos, Monpos, Ypos, Ppos) AS Minpos,
                COALESCE(Spos, Minpos, Hpos, Tpos, Dpos, Monpos, Ypos, Ppos) AS Spos
        FROM CTE1
    )

    SELECT  [qbsql_id], 
            [username_id], 
            [TxnDate], 
            [Duration],
            0.0 + 
            CASE WHEN Ppos = 1 AND Tpos = 2 THEN
                CASE WHEN Hpos > Tpos THEN
                    ISNULL(CAST(SUBSTRING([Duration], Tpos+1, Hpos - Tpos-1) as float), 0)
                ELSE 
                    0
                END
                + 
                CASE WHEN Minpos > Hpos THEN
                    ISNULL(CAST(SUBSTRING([Duration], Hpos+1, Minpos - Hpos-1) as float), 0) / 60.0
                ELSE 
                    0
                END 
                +
                CASE WHEN Spos > Minpos THEN
                    ISNULL(CAST(SUBSTRING([Duration], Minpos+1, Spos - Minpos-1) as float), 0) / 60.0 /  60.0
                ELSE 
                    0
                END 
            END AS DurationInHours
    FROM CTE2


/*
  	qbsql_id	username_id 	TxnDate             	Duration   	DurationInHours
    1       	1           	02.02.2018 00:00:00 	PT8H0M     	8
    2       	2           	01.02.2018 00:00:00 	PT7H30M 	7,5
    3       	1           	01.02.2018 00:00:00 	PT1H0M  	1
*/