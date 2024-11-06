 /*
 /*
Created By: Kendall Ruber
Bringing data from an Excel files into SQL Server Management Studio and setting up constraints.
*/

-- Step 1: Create a new database to upload your datasets into

USE [master]
GO
CREATE DATABASE [Red30Tech]

-- Step 2: Switch to using the new database you just created
USE [Red30Tech] 

-- Step 3: Upload the datasets as tables into SSMS
-- Follow along with demo in video. Ensure you close out and reopen SSMS when completed. Make sure that you run USE [Red30Tech] again if you exit and re-enter SSMS!

-- Step 4:  Add Primary Key Constraints

  --- SET PK FOR ONLINE RETAIL SALES
  -- First, Make cols Non-Nullable
  ALTER TABLE dbo.OnlineRetailSales$
  ALTER COLUMN OrderNum float NOT NULL
  GO
  
  -- Identify OrderNum as the Primary Key of this table
  ALTER TABLE dbo.OnlineRetailSales$ add primary key (OrderNum) 
  GO
  
  --- SET PK FOR SESSION INFO 
  -- First, Make cols Non-Nullable
  ALTER TABLE dbo.SessionInfo$
  ALTER COLUMN [Start Date] datetime NOT NULL
  GO 

  ALTER TABLE dbo.SessionInfo$
  ALTER COLUMN [End Date] datetime NOT NULL
  GO

  ALTER TABLE dbo.SessionInfo$
  ALTER COLUMN [Session Name] nvarchar(255) NOT NULL
  GO 
  
  -- Identify Start Date, End Date, and Session name as the Primary Key of this table
  ALTER TABLE dbo.SessionInfo$ add primary key ([Start Date],[End Date],[Session Name]) 
  GO

  --- SET PK FOR SPEAKER INFO
  -- First, Make cols Non-Nullable
  ALTER TABLE dbo.SpeakerInfo$
  ALTER COLUMN [Name] nvarchar(255) NOT NULL
  GO 

  ALTER TABLE dbo.SpeakerInfo$
  ALTER COLUMN [Session Name] nvarchar(255) NOT NULL
  GO

  -- Identify Name and Session Name as the Primary Key of this table
  -- Some session topics are duplicates of each other but they are delivered by different speakers
  ALTER TABLE dbo.SpeakerInfo$ add primary key ([Name],[Session Name]) 
  GO
  
  --- SET PK FOR CONFERENCE ATTENDEES
  -- First, Make cols Non-Nullable
  ALTER TABLE dbo.ConventionAttendees$
  ALTER COLUMN [Email] nvarchar(255)  NOT NULL
  GO
  
  -- Identify Email as the Primary Key of this table
  ALTER TABLE dbo.ConventionAttendees$ add primary key (Email) 
  GO
  
  --- SET PK FOR INVENTORY
  -- First, Make cols Non-Nullable
  ALTER TABLE dbo.Inventory$
  ALTER COLUMN ProdNumber nvarchar(255) NOT NULL
  GO

  ALTER TABLE dbo.Inventory$
  ALTER COLUMN ProdName nvarchar(255) NOT NULL
  GO
  
  -- Identify ProdNumber and ProdName as the composite Primary Key of this table
  ALTER TABLE dbo.Inventory$ add primary key ([ProdNumber],[ProdName])
  GO
  
  --- SET PK FOR EMPLOYEE DIRECTORY
  -- First, Make cols Non-Nullable
  ALTER TABLE dbo.EmployeeDirectory$
  ALTER COLUMN EmployeeID nvarchar(255) NOT NULL
  GO
  
  -- Identify EmployeeID as the composite Primary Key of this table
  ALTER TABLE dbo.EmployeeDirectory$ add primary key ([EmployeeID])
  GO
  
  -- NOTE: You may need to refresh your connection to see this change under the Keys section. If that does not work, you may need to exit out of SSMS and re-enter. 
  -- Make sure that you run USE [Red30Tech] again if you exit and re-enter SSMS!

-- You're ready to start querying!
*/

-- SELECT * FROM Red30Tech.dbo.ConventionAttendees$
-- SELECT * FROM Red30Tech.dbo.EmployeeDirectory$
-- SELECT * FROM Red30Tech.dbo.Inventory$
-- SELECT * FROM Red30Tech.dbo.OnlineRetailSales$
-- SELECT * FROM Red30Tech.dbo.SessionInfo$
-- SELECT * FROM Red30Tech.dbo.SpeakerInfo$

/*
SELECT *, (select AVG([Order Total]) from [Red30Tech].[dbo].[OnlineRetailSales$]) as avg_total
FROM [Red30Tech].[dbo].[OnlineRetailSales$]
where [Order Total] >= (select AVG([Order Total]) from [Red30Tech].[dbo].[OnlineRetailSales$])
*/

/*
--subquery
SELECT [Speaker Name], [Session Name], [Start Date], [End Date], [Room Name]
FROM Red30Tech.dbo.SessionInfo$
WHERE [Speaker Name] IN 
(SELECT Name FROM Red30Tech.dbo.SpeakerInfo$ WHERE Organization = 'Two Trees Olive Oil')

--join
SELECT s.[Speaker Name], s.[Session Name], s.[Start Date], s.[End Date], s.[Room Name]
FROM Red30Tech.dbo.SessionInfo$ s
INNER JOIN (SELECT Name FROM Red30Tech.dbo.SpeakerInfo$ WHERE Organization = 'Two Trees Olive Oil') as sp
ON s.[Speaker Name] = sp.Name
*/

/*
SELECT [First Name], [Last Name], [State], [Email], [Phone Number]
FROM Red30Tech.dbo.ConventionAttendees$ c
WHERE NOT EXISTS
(SELECT CustState FROM Red30Tech.dbo.OnlineRetailSales$ o
WHERE c.State = o.CustState)
*/

/*
SELECT [ProdCategory], [ProdNumber], [ProdName], [In Stock] FROM Red30Tech.dbo.Inventory$
where [In Stock] < (select AVG([In Stock]) from Red30Tech.dbo.Inventory$)
*/

/*
With CTE AS (select AVG([Order Total]) as AvgTotal from Red30Tech.dbo.OnlineRetailSales$)
SELECT * FROM Red30Tech.dbo.OnlineRetailSales$, CTE --adding a comma between two tables after FROM clause means it is a Cross Join
where [Order Total] >= AvgTotal
*/

/*
With CTE AS
(SELECT Manager, Count(EmployeeID) as DirectReport FROM Red30Tech.dbo.EmployeeDirectory$
Group by Manager)
select e.[First Name], e.[Last Name], e.Title, e.EmployeeID, CTE.DirectReport
from Red30Tech.dbo.EmployeeDirectory$ e inner join CTE on e.EmployeeID = CTE.Manager
where CTE.Manager = 42
*/

/*
with AvgStock AS (select AVG([In Stock]) as AverageStock from Red30Tech.dbo.Inventory$)
SELECT [ProdCategory], [ProdNumber], [ProdName], [In Stock] FROM Red30Tech.dbo.Inventory$, AvgStock
where [In Stock] < AverageStock
*/

/*
With CTERow As (
SELECT Row_number() Over (Partition by CustName order by OrderDate Desc) as OrderRowNum, *
FROM Red30Tech.dbo.OnlineRetailSales$
)
select * from CTERow where OrderRowNum = 1
*/

/*
with CTERowNum as (
select row_number() over(partition by ProdCategory order by [Order Total] desc) as TotalRowNum
, OrderNum, OrderDate, CustName, ProdCategory, ProdName, [Order Total]
from Red30Tech.dbo.OnlineRetailSales$
where CustName = 'Boehm Inc.'
)
select * from CTERowNum
Where TotalRowNum <= 3
order by ProdCategory, TotalRowNum
*/

/*
SELECT [Start Date], [Session Name],
lag([Session Name]) over(order by [Start Date]) as PreviousSession,
lead([Session Name]) over(order by [Start Date]) as NextSession
FROM Red30Tech.dbo.SessionInfo$
where [Room Name] = 'Room 102'
order by [Start Date]
*/

/*
SELECT OrderDate, sum(Quantity) as TotalQuantity,
lag(sum(Quantity)) over(order by OrderDate) as PreviousOrder,
lag(sum(Quantity), 2) over(order by OrderDate) as Previous2ndOrder,
lag(sum(Quantity), 3) over(order by OrderDate) as Previous3rdOrder,
lag(sum(Quantity), 4) over(order by OrderDate) as Previous4thOrder,
lag(sum(Quantity), 5) over(order by OrderDate) as Previous5thOrder
FROM Red30Tech.dbo.OnlineRetailSales$
Where ProdCategory = 'Drones'
group by OrderDate
Order by OrderDate
*/

/*
SELECT rank() over(order by [Last Name]) as NameRank,
dense_rank() over(order by [Last Name]) as NameDenseRank,*
FROM Red30Tech.dbo.EmployeeDirectory$
order by [Last Name]
*/

/*
with CTEReg as (
SELECT dense_rank() over(partition by [State] order by [Registration Date]) as TopReg,
[Registration Date], [First Name], [Last Name], [State]
FROM Red30Tech.dbo.ConventionAttendees$
)
select * from CTEReg 
where TopReg <= 3
order by 5, 2

with CTEReg as (
SELECT rank() over(partition by [State] order by [Registration Date]) as TopReg,
[Registration Date], [First Name], [Last Name], [State]
FROM Red30Tech.dbo.ConventionAttendees$
)
select * from CTEReg 
where TopReg <= 3
order by 5, 2
*/