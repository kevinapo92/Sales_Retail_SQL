USE walmart ; 
-- How many stores are there in the dataset?
SELECT COUNT(*)
FROM stores ;

-- What are the different store types and how many stores are there in each type?
SELECT Type , COUNT(Type)
FROM stores
GROUP BY Type ;

-- What is the average temperature for each store?
SELECT Store, AVG(Temperature)
FROM features
GROUP BY Store ;

-- What is the average fuel price for each store?
SELECT Store, AVG(Fuel_Price)
FROM features
GROUP BY Store ;

-- How many different types of promotional markdowns (MarkDown1, MarkDown2, etc.) are there?
SELECT SUM(CASE WHEN MarkDown1 != 'NA' THEN 1 ELSE 0 END) AS MarkDown1_Count, 
	   SUM(CASE WHEN MarkDown2 != 'NA' THEN 1 ELSE 0 END) AS MarkDown2_Count, 
       SUM(CASE WHEN MarkDown3 != 'NA' THEN 1 ELSE 0 END) AS MarkDown3_Count,
       SUM(CASE WHEN MarkDown4 != 'NA' THEN 1 ELSE 0 END) AS MarkDown4_Count,
       SUM(CASE WHEN MarkDown5 != 'NA' THEN 1 ELSE 0 END) AS MarkDown5_Count
FROM features; 

-- What is the average fuel price for each week?
SELECT WEEK(Date) AS Week_Date , ROUND(AVG(Fuel_Price),2)
FROM features 
GROUP BY Week_Date ; 

-- What is the average size of stores in each store type?
SELECT Type , AVG(Size)
FROM stores 
GROUP BY Type ; 

-- Which store had the average highest CPI?
SELECT Store , ROUND(AVG(CPI),2) AS avg_CPI
FROM features
GROUP BY Store 
ORDER BY avg_CPI DESC 
LIMIT 1 ; 

-- Which store had the highest temperature?
SELECT Store , ROUND(AVG(Temperature),2) AS avg_Temperature
FROM features
GROUP BY Store 
ORDER BY avg_Temperature DESC 
LIMIT 1 ; 

-- What is the average CPI for each store type?
SELECT Type, ROUND(AVG(CPI) , 2) AS Avg_CPI 
FROM features
INNER JOIN stores
ON features.Store = stores.Store 
GROUP BY Type ; 

-- What is the correlation between temperature, CPI, fuel price?
DROP TABLE IF EXISTS CORRELATIONS;
CREATE TEMPORARY TABLE CORRELATIONS AS 
SELECT 'Temperature' AS Measure , 
	ROUND((COUNT(*) * SUM(Temperature * Temperature) - SUM(Temperature) * SUM(Temperature)) /
    SQRT((COUNT(*) * SUM(Temperature * Temperature) - SUM(Temperature) * SUM(Temperature)) *
         (COUNT(*) * SUM(Temperature * Temperature) - SUM(Temperature) * SUM(Temperature))),3) AS Temperature,
	
    ROUND((COUNT(*) * SUM(Temperature * CPI) - SUM(Temperature) * SUM(CPI)) /
    SQRT((COUNT(*) * SUM(Temperature * Temperature) - SUM(Temperature) * SUM(Temperature)) *
         (COUNT(*) * SUM(CPI * CPI) - SUM(CPI) * SUM(CPI))),3) AS CPI , 
         
	ROUND((COUNT(*) * SUM(Temperature * Fuel_Price) - SUM(Temperature) * SUM(Fuel_Price)) /
    SQRT((COUNT(*) * SUM(Temperature * Fuel_Price) - SUM(Temperature) * SUM(Temperature)) *
         (COUNT(*) * SUM(Fuel_Price * Fuel_Price) - SUM(Fuel_Price) * SUM(Fuel_Price))),3) AS Fuel_Price  
FROM features;

INSERT INTO CORRELATIONS 
SELECT 'CPI' AS Measure , 
	ROUND((COUNT(*) * SUM(CPI * Temperature) - SUM(CPI) * SUM(Temperature)) /
    SQRT((COUNT(*) * SUM(CPI * CPI) - SUM(CPI) * SUM(CPI)) *
         (COUNT(*) * SUM(Temperature * Temperature) - SUM(Temperature) * SUM(Temperature))),3) AS Temperature,
	
	ROUND((COUNT(*) * SUM(CPI * CPI) - SUM(CPI) * SUM(CPI)) /
    SQRT((COUNT(*) * SUM(CPI * CPI) - SUM(CPI) * SUM(CPI)) *
         (COUNT(*) * SUM(CPI * CPI) - SUM(CPI) * SUM(CPI))),3) AS CPI,
         
	ROUND((COUNT(*) * SUM(CPI * Fuel_Price) - SUM(CPI) * SUM(Fuel_Price)) /
    SQRT((COUNT(*) * SUM(CPI * CPI) - SUM(CPI) * SUM(CPI)) *
         (COUNT(*) * SUM(Fuel_Price * Fuel_Price) - SUM(Fuel_Price) * SUM(Fuel_Price))),3) AS Fuel_Price   
FROM features;
    
INSERT INTO CORRELATIONS 
SELECT 'Fuel_Price' AS Measure , 
	ROUND((COUNT(*) * SUM(Fuel_Price * Temperature) - SUM(Fuel_Price) * SUM(Temperature)) /
    SQRT((COUNT(*) * SUM(Fuel_Price * Fuel_Price) - SUM(Fuel_Price) * SUM(Fuel_Price)) *
         (COUNT(*) * SUM(Temperature * Temperature) - SUM(Temperature) * SUM(Temperature))),3) AS Temperature,
	
	ROUND((COUNT(*) * SUM(Fuel_Price * CPI) - SUM(Fuel_Price) * SUM(CPI)) /
    SQRT((COUNT(*) * SUM(Fuel_Price * Fuel_Price) - SUM(Fuel_Price) * SUM(Fuel_Price)) *
         (COUNT(*) * SUM(CPI * CPI) - SUM(CPI) * SUM(CPI))),3) AS CPI,
         
	ROUND((COUNT(*) * SUM(Fuel_Price * Fuel_Price) - SUM(Fuel_Price) * SUM(Fuel_Price)) /
    SQRT((COUNT(*) * SUM(Fuel_Price * Fuel_Price) - SUM(Fuel_Price) * SUM(Fuel_Price)) *
         (COUNT(*) * SUM(Fuel_Price * Fuel_Price) - SUM(Fuel_Price) * SUM(Fuel_Price))),3) AS Fuel_Price   
FROM features;
SELECT * 
FROM  CORRELATIONS ; 

-- What is the maximun CPI in each by week by store?

WITH Table2 AS
(SELECT Store, MAX(Max_Week) AS Max_Store
FROM (
SELECT Store, WEEK(Date) AS Week_Date, MAX(CPI) AS Max_Week
FROM features
GROUP BY Store, WEEK(Date) 
ORDER BY Store, WEEK(Date) ) AS Table1 
GROUP BY Store)
SELECT Table2.Store, Week_Date, Table2.Max_Store
FROM Table2
LEFT JOIN (
SELECT Store, WEEK(Date) AS Week_Date, MAX(CPI) AS Max_Week
FROM features
GROUP BY Store, WEEK(Date) 
ORDER BY Store, WEEK(Date)
) AS Table3
ON Table2.Max_Store = Table3.Max_Week ;

-- What are the features according the type of store?

SELECT Type, AVG(Size),AVG(Temperature),AVG(CPI), AVG(Fuel_Price), AVG(Unemployment), AVG(MarkDown1),AVG(MarkDown2),AVG(MarkDown3),AVG(MarkDown4),AVG(MarkDown5)
FROM features
INNER JOIN stores
ON features.Store = stores.Store 
GROUP BY Type ;

-- Evaluate if the Markdowns had more effects in the holidays 
SELECT IsHoliday,
	    ROUND(AVG(MarkDown1),1) AS Promotion1,
        ROUND(AVG(MarkDown1),2) AS Promotion2,
        ROUND(AVG(MarkDown1),3) AS Promotion3,
        ROUND(AVG(MarkDown1),4) AS Promotion4,
        ROUND(AVG(MarkDown1),5) AS Promotion5
FROM features
GROUP BY IsHoliday ;


-- Evaluate the effects of markdown1  in the  types of stores
SELECT Type, ROUND(SUM(markdown1),2) as Total_Sales_M1, ROUND(AVG(Size),2) AS Average_Size
FROM (SELECT MarkDown1, Type, Size
FROM features
INNER JOIN stores
ON stores.Store = features.Store
WHERE MarkDown1 > 0) AS Table1 
GROUP BY Type
ORDER BY Total_Sales_M1 DESC ;

-- Evaluate the effects of markdown1  in the each stores
SELECT Store, 
	ROUND(SUM(markdown1),2) as Total_Sales_M1,
    ROUND(SUM(markdown2),2) as Total_Sales_M2,
    ROUND(SUM(markdown3),2) as Total_Sales_M3,
    ROUND(SUM(markdown4),2) as Total_Sales_M4,
    ROUND(SUM(markdown5),2) as Total_Sales_M5
FROM features
GROUP BY Store ;

-- Identify how many promotions where place in each week of the year
WITH Table3 AS
(SELECT YEAR(Date) AS Week_year, WEEK(Date) AS Week_Date, 
		sum(outcome1) AS sum_outcome1,
		sum(outcome2) AS sum_outcome2,
        sum(outcome3) AS sum_outcome3,
        sum(outcome4) AS sum_outcome4,
        sum(outcome5) AS sum_outcome5
FROM (
SELECT Date, 
		CASE WHEN MarkDown1 != 'NA' THEN 1 ELSE 0 END AS outcome1,
		CASE WHEN MarkDown2 != 'NA' THEN 1 ELSE 0 END AS outcome2,
		CASE WHEN MarkDown3 != 'NA' THEN 1 ELSE 0 END AS outcome3,
		CASE WHEN MarkDown4 != 'NA' THEN 1 ELSE 0 END AS outcome4,
		CASE WHEN MarkDown5 != 'NA' THEN 1 ELSE 0 END AS outcome5
FROM features ) AS Table2 
GROUP BY Week_year,Week_Date)
SELECT Week_year, Week_Date, (sum_outcome1 + sum_outcome2 + sum_outcome3 + sum_outcome4 + sum_outcome5) AS Total_Promotions 
FROM Table3 
HAVING Total_Promotions > 0
ORDER BY Week_year,  Week_Date, Total_Promotions DESC ; 




