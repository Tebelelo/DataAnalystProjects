USE
  Portfolio
GO

-----------------------------------------------------------------------------------------
SELECT * FROM dbo.[Premier_League(2022-2023)]
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
--EXPLORATORY DATA ANALYSIS

--01 Which 5 games recorded the most attendence
SELECT TOP 5 Home_Team,Away_Team, attendance
FROM dbo.[Premier_League(2022-2023)]
WHERE attendance != 'Nan' 
ORDER BY attendance DESC

--02 Which 5 games recorded the lowest attendence
SELECT TOP 5 Home_Team,Away_Team, attendance
FROM dbo.[Premier_League(2022-2023)]
WHERE attendance != 'Nan' 
ORDER BY attendance ASC

--03 The highest goals scored by a home team
SELECT TOP 5 Home_Team, Away_Team,Goals_Home,Away_Goals
FROM dbo.[Premier_League(2022-2023)]
ORDER BY Goals_Home DESC

--04 Which away team recorded the highest possession
SELECT TOP 1 date, Home_Team, Away_Team,home_possessions, away_possessions
FROM dbo.[Premier_League(2022-2023)]
ORDER BY away_possessions DESC 

--05 What different times is premier league matches played?
SELECT DISTINCT(clock)
FROM dbo.[Premier_League(2022-2023)]

-- 06 Which team have the most cleansheets at Home?
SELECT Home_Team, Away_Team, Goals_Home, Away_Goals
FROM dbo.[Premier_League(2022-2023)]
WHERE Away_Goals = '0' 
ORDER BY Home_Team
 
 --- Goals v Shots
 SELECT Goals_Home, home_Shots, Away_Goals,away_shots
 FROM dbo.[Premier_League(2022-2023)]
 
 -----------------------------------------------------------------------------------------------------------
 --DATA CLEANING
 ---------------------------------------------------------
----Standardize Data types format
--checking data type of each table
SELECT 
   TABLE_CATALOG,
   TABLE_SCHEMA,
   TABLE_NAME, 
   COLUMN_NAME, 
   DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Premier_League(2022-2023)'
  
  --replacing unnecessary strings
   UPDATE dbo.[Premier_League(2022-2023)]
   SET date = PARSENAME(REPLACE(date, 'th',''),1)

   UPDATE dbo.[Premier_League(2022-2023)]
   SET date = PARSENAME(REPLACE(date, 'st',''),1) 

   UPDATE dbo.[Premier_League(2022-2023)]
   SET date = PARSENAME(REPLACE(date, 'nd',''),1) 

   UPDATE dbo.[Premier_League(2022-2023)]
   SET date = PARSENAME(REPLACE(date, 'rd',''),1) 

   UPDATE dbo.[Premier_League(2022-2023)]
   SET date = PARSENAME(REPLACE(date, 'Augu','August'),1) 

   UPDATE dbo.[Premier_League(2022-2023)]
   SET attendance = REPLACE(attendance,',','') 
    
--Changing data type of date
ALTER TABLE dbo.[Premier_League(2022-2023)]
ALTER COLUMN date DATE

--Changing clock data type to TIME
 UPDATE dbo.[Premier_League(2022-2023)]
 SET clock = PARSENAME(REPLACE(clock,'pm', ''),1)

 UPDATE dbo.[Premier_League(2022-2023)]
 SET clock = PARSENAME(REPLACE(clock,'p', ''),1)

ALTER TABLE dbo.[Premier_League(2022-2023)]
ALTER COLUMN clock TIME

--Goals_Home to INT
ALTER TABLE dbo.[Premier_League(2022-2023)]
ALTER COLUMN Goals_Home INT

--Away_Goals to INT
ALTER TABLE dbo.[Premier_League(2022-2023)]
ALTER COLUMN Away_Goals INT

-- Possessions to float
ALTER TABLE dbo.[Premier_League(2022-2023)]
ALTER COLUMN home_possessions FLOAT

ALTER TABLE dbo.[Premier_League(2022-2023)]
ALTER COLUMN away_possessions FLOAT

-----------------------------------------------------------------
--Replacing and populating incorrect entries

--Home Team means the game is hosted at their stadium
SELECT a.stadium,a.Home_Team,a.Away_Team,b.stadium 
FROM dbo.[Premier_League(2022-2023)] a 
INNER JOIN dbo.[Premier_League(2022-2023)] b
ON a.Home_Team = b.Home_Team AND a.Away_Team <> b.Away_Team
WHERE a.stadium = 'Nan'

---Populating the stadium
UPDATE a 
SET a.stadium = b.stadium
FROM dbo.[Premier_League(2022-2023)] a 
INNER JOIN dbo.[Premier_League(2022-2023)] b
ON a.Home_Team = b.Home_Team AND a.Away_Team <> b.Away_Team
WHERE a.stadium = 'Nan'

--Populating attendance with 0 where is Nan
UPDATE dbo.[Premier_League(2022-2023)]
SET attendance = '0'
WHERE attendance = 'Nan'

---Changing attendance data type to INT
ALTER TABLE dbo.[Premier_League(2022-2023)]
ALTER COLUMN attendance INT

---Populating attendance with means of their respective columns where is attendance 0
SELECT a.attendance,a.Home_Team,a.Away_Team ,b.attendance
FROM dbo.[Premier_League(2022-2023)] a
INNER JOIN dbo.[Premier_League(2022-2023)] b
ON a.Home_Team = b.Home_Team 
WHERE a.attendance = 0 

UPDATE a
SET a.attendance = AttendanceAve
FROM 
 dbo.[Premier_League(2022-2023)] a
 INNER JOIN 
  (
   SELECT b.Home_Team,AVG(b.attendance) AS AttendanceAve
   FROM dbo.[Premier_League(2022-2023)] b
   GROUP BY b.Home_Team
  ) table2
ON table2.Home_Team = a.Home_Team 
WHERE a.attendance = 0
------------------------------------------------------------------------
---DUPLICATES
--checking duplicates
WITH RowNumCTE AS (
          SELECT*,ROW_NUMBER()OVER (
		       PARTITION BY Home_Team,
			                Goals_Home,
							Away_Team,
							Away_Goals
							ORDER BY date
		  ) AS row_num
FROM dbo.[Premier_League(2022-2023)]
)

SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY Home_Team
 
 ---There is no duplicates
	--

 ---------------------------------------------------------------------------
 --Deleting  unneccessary columns

ALTER TABLE dbo.[Premier_League(2022-2023)]
DROP COLUMN  links

