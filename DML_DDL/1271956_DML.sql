--3 (DELETE Query)
DELETE FROM RONI WHERE Age=24

--4(UPDATE QUERY)
UPDATE RONI SET Name='ARIF' WHERE Age=26

--7(JOIN)
USE WorksDB
GO
SELECT * FROM (SELECT DonationID,ProjectID FROM Donation 
GROUP BY ProjectID,DonationID
HAVING ProjectID='104') t
JOIN Donation d ON d.DonationID=t.DonationID
JOIN Doner d1 ON d.DonerID=d1.DonerID
JOIN Project p ON p.ProjectID=t.ProjectID
--8(sub query)
USE WorksDB
GO
SELECT t.DonationID, d.DonerFName+' '+d.DonerLName, p.ProjectName,p.ProjectDes FROM 
(SELECT * FROM Donation WHERE DonationID IN
(select DonationID from Donation  D
join Doner do ON d.DonerID=do.DonerID
WHERE do.DonerFName='Victor')) t
JOIN Doner d ON t.DonerID=d.DonerID
JOIN Project p ON t.ProjectID=p.ProjectID

--call procedure
EXEC sp_helptext vw_WorkDetailes

--show clustered index

EXEC sp_helpindex Doner

--show nonclustered index

EXEC sp_helpindex Project

--call table value funcation

SELECT * FROM  dbo.fnProjectWiseDonationInfo(104)

--call sclar value funcation

SELECT  dbo.fnGetProjectWiseDonationAmount(104)

--15(Error)
BEGIN TRY
INSERT INTO Project VALUES
(101,'SSolar Scholars','Powering School With solar panel'),
(102,'Creek CleanUp','Cleaning up litter and pollutants from creek'),
(103,'Land Trust','Purchasing and preserving land in the watershed'),
(104,'Forest Asia','Planting tree in Asia')
END TRY
BEGIN CATCH
SELECT ERROR_MESSAGE() ErrorMessage,
ERROR_NUMBER() ErrorNumber,
ERROR_SEVERITY() ErrorSeverity,
ERROR_STATE() ErrorState
END CATCH


--17(SEARCH CASE)
USE WorksDB
GO
SELECT DonerID,SUM(DonationAmount) as DonationAmount,
CASE
	WHEN SUM(DonationAmount)<=1500
	THEN 'MINIMUM AMOUNT'
	WHEN SUM(DonationAmount)<=2000
	THEN 'AVEREGE AMOUNT'
	ELSE 'MAXIMUM AMOUNT'
END AS STATUS	
FROM Donation
GROUP BY DonerID

--18(simple CASE)

USE WorksDB
GO
SELECT DonerID,DonationAmount,
CASE DonerID
	WHEN 1 THEN 'YOUR AMOUNT MINIMUM'
	WHEN 2 THEN 'YOUR AMOUNT AVERAGE'
	WHEN 3 THEN 'YOUR AMOUNT MAXIMUM'
	END AS STATUS
FROM Donation


--19(CTE)
USE WorksDB
GO
WITH DonatioDetiles
as
(SELECT DISTINCT D.DonerID,P.ProjectID,P.ProjectName,D.DonationAmount FROM Donation d
join Project p ON d.ProjectID=p.ProjectID
GROUP BY D.DonerID,P.ProjectID,P.ProjectName,D.DonationAmount)

SELECT d.DonerID,d1.DonerFName+''+d1.DonerLName as DonerName,d.ProjectID,
d.ProjectName,d.DonationAmount FROM DonatioDetiles d
JOIN Doner d1 on d.DonerID=d1.DonerID

--20(CURSOR)
DECLARE @DonerID int
DECLARE @DonerFName Varchar(20)
DECLARE @DonerLName varchar(15)
DECLARE @RowCount int
set @RowCount=0;
DECLARE DonerDetailes_Cusor CURSOR
 FOR SELECT * FROM Doner
 OPEN DonerDetailes_Cusor
 FETCH NEXT FROM DonerDetailes_Cusor INTO @DonerID,@DonerFName,@DonerLName
 WHILE @@FETCH_STATUS<>-1
 BEGIN
 SET @RowCount =@RowCount+1;
  FETCH NEXT FROM DonerDetailes_Cusor INTO @DonerID,@DonerFName,@DonerLName
 END
 CLOSE DonerDetailes_Cusor
 DEALLOCATE DonerDetailes_Cusor
 PRINT CONVERT(VARCHAR,@RowCount,101)+'ROWS INSERTED'

 --21(COVERT)
 DECLARE @EndDate smalldatetime
 set @EndDate='01-jun-2019 10:00 am' 
 select CONVERT(date,@EndDate) AS Newdate

 --22(CAST)
 DECLARE @StartDate smalldatetime
 set @StartDate='01-jun-2019 10:00 am' 
 select CAST(@StartDate AS DATE) AS Newdate

 --23(IIF)
 USE WorksDB
 GO
 SELECT DonerID,SUM(DonationAmount) as DonationAmount,
 IIF(SUM(DonationAmount)>0,'AVERAGE','ZERO')
 FROM Donation
 GROUP BY DonerID

 --24(CHOSSE)

 USE WorksDB
 GO
 SELECT DonerID,ProjectID,DonationAmount,
 CHOOSE(DonerID,'MINIMUM','MAXIMUM','AVERAGE')
 FROM Donation
 WHERE DonationAmount>1000


 --25(ISNULL)
 USE WorksDB
 GO
 SELECT DonationAmount,
 ISNULL(DonationAmount,'00:00') AS NewAmount
 FROM Donation

 --26(COALESCE)
 USE WorksDB
 GO
 SELECT DonationAmount,
 COALESCE(DonationAmount,'00:00') AS NewAmount
 FROM Donation

 --27(RANK)
USE WorksDB
GO
SELECT 
RANK() OVER(ORDER BY DonerID) Rank,
DENSE_RANK() OVER(ORDER BY ProjectID) DenseRank,
ROW_NUMBER() OVER(PARTITION BY DonationID ORDER BY DonationAmount ) RowNumber,
DonerID,ProjectID,DonationID
FROM Donation


--28(merge)

USE WorksDB
GO
CREATE TABLE Candidate(
ID int not null,
Name Varchar(20) not null
)
INSERT INTO Candidate VALUES
(1,'HASAN'),
(2,'MAHMUD')
CREATE TABLE Person(
Name Varchar(20) not null,
Age int not null
)
INSERT INTO Person VALUES
('HASAN',25),
('MAHMUD',26)
CREATE TABLE Student(
ID int primary key not null,
Name Varchar(20) not null,
Age int not null
)
MERGE INTO Student s USING
(SELECT c.ID,c.Name,p.Age FROM Candidate c
join Person p on c.Name=p.Name) as s1
on s.ID=s1.ID
WHEN MATCHED THEN UPDATE SET s.Name=s1.Name,s.Age=s1.Age
WHEN NOT MATCHED THEN INSERT (ID,Name,Age) values (s1.ID,s1.Name,s1.Age);

--(OTHER FUNCATION)

--SELECT INTO
USE WorksDB
GO
SELECT * INTO ProjectName FROM Project

--  GROUPING SETS

USE WorksDB
GO
SELECT DonationID,DonerID,COUNT(*) AS TotalDoner FROM Donation
GROUP BY GROUPING SETS( (DonationID),(DonerID),()) ORDER BY DonationID,DonerID

--WITH ROLLUP
USE WorksDB
GO
SELECT DonationID,DonerID,COUNT(*) AS TotalDoner FROM Donation
GROUP BY DonationID,DonerID WITH ROLLUP

--WITH CUBE
USE WorksDB
GO
SELECT DonationID,DonerID,COUNT(*) AS TotalDoner FROM Donation
GROUP BY DonationID,DonerID WITH CUBE

/*--SEQUENCE
USE WorksDB
GO
INSERT INTO Project values
(next value for se_sequence, 'FRIST ROW INSERTED')*/

--DATE FUNCATION
SELECT ISDATE('01-02-2019')

SELECT MONTH('01-02-2019 18:01:31')

SELECT DATEPART(YEAR,'01-02-2019')

SELECT DATEFROMPARTS(2022,11,29)

SELECT EOMONTH('01-02-2019')

SELECT DAY('01-02-2019')

SELECT DATEADD(DAY,5,'01-02-2019')

SELECT DATEDIFF(DAY,'2022-11-26','2022-11-29')

SELECT DATEDIFF(MONTH,'2022-10-26','2022-11-29')

SELECT DATEDIFF(YEAR,'2021-11-26','2022-11-29')

