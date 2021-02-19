CREATE TABLE [dbo].[Customers](
	[Id] [nvarchar](200) NOT NULL,
	[Userfullname] [nvarchar](max) NULL,
	[Emailaddress] [nvarchar](max) NULL,
	[Description] [nvarchar](500) NULL,
	[Status] [nvarchar](50) NULL,
	[Date] [datetime] NULL

 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO




CREATE PROCEDURE [dbo].[spGetCustomers]
	@Status		NVARCHAR(50),
	@Id	NVARCHAR(50),
	@Name NVARCHAR(350),
	@Surname NVARCHAR(350),
	@Email  NVARCHAR(350),
	@StartDate varchar(50),
	@EndDate varchar(50),
	@Skip     INT=0, 
	@Top INT=10
AS 
BEGIN

SET NOCOUNT ON;

DECLARE @WhereStatement NVARCHAR(4000)
DECLARE @SelectStatement NVARCHAR(4000)
DECLARE @SelectCountStatement NVARCHAR(4000)

SET @SelectCountStatement = 'SELECT Count(*) FROM [CustomerDB].[dbo].[Customers]'

SET @WhereStatement = ' WHERE (1=1) '

if (@Status <> '*' and @Status <> '' and @Status is not null)
	SET @WhereStatement = @WhereStatement+'and Status =''' +@Status+ ''' '

if (@Id <> '*' and @Id <> '' and @Id is not null)
	SET @WhereStatement = @WhereStatement+'and Id =''' +@Id+ ''' '

if (@Email <> '*' and @Email <> '' and @Email is not null)
	SET @WhereStatement = @WhereStatement+'and lower(Emailaddress) like ''%' +lower(@Email)+ '%'' '


if (@Name <> '*' and @Name <> '' and @Name is not null) or 
	(@Surname <> '*' and @Surname <> '' and @Surname is not null) 	
	Begin
	SET @WhereStatement = @WhereStatement+'and Upper(Userfullname) like ''%' +ISNULL(Upper(@Name),'')+ '%'+ISNULL(Upper(@Surname),'')+'%'' '

	End
	
If (@StartDate Is Not Null and @StartDate<>'01/01/0001 00:00:00 +00:00') AND (@EndDate Is Not Null and @EndDate<>'01/01/0001 00:00:00 +00:00')
    SET @WhereStatement = @WhereStatement + ' and (Date BETWEEN '''+ @StartDate +''' AND '''+@EndDate+''')'

SET @SelectCountStatement = @SelectCountStatement+ @WhereStatement


SET @SelectStatement = '
		SELECT *,('+@SelectCountStatement+') as TotalCount
		FROM [CustomerDB].[dbo].[Customers] '
		+ @WhereStatement
		+ ' ORDER BY Date Desc '
		+' OFFSET '+Cast(@Skip as nvarchar)+' ROW'
		+' FETCH NEXT '+ CAST( @Top as nvarchar)+ ' ROWS ONLY;'
		
	EXEC SP_EXECUTESQL @SelectStatement

END

GO


