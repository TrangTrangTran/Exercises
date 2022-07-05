
--check the number of columns
SELECT COUNT(COLUMN_NAME) 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_CATALOG = 'Sample' 
    AND TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'DataCoSupplyChainDataset'
-----check the number of rows
SELECT COUNT(*)
FROM DataCoSupplyChainDataset

ALTER TABLE dbo.DataCoSupplyChainDataset
DROP COLUMN [Customer Email],[Customer Password],[Order Zipcode],[Product Description],[Product Image];


--SALES ANALYSIS
--total sales for all markets
SELECT Market, SUM(Sales) AS SALES
FROM DataCoSupplyChainDataset
GROUP BY Market

--Total sales for all regions
SELECT Market,  [Order Region],cast(SUM(Sales) as int) as SALES
FROM DataCoSupplyChainDataset
GROUP BY Market, [Order Region]
order by Market

--Category
SELECT [Category Name],COUNT([Order Id]) AS Number_of_orders
FROM DataCoSupplyChainDataset
GROUP BY [Category Name]
ORDER BY  Number_of_orders DESC

--comparing sales per category
SELECT DATEPART(year,[shipping date (DateOrders)]) as sale_year,[Category Name] ,SUM(Sales) AS sales_of_orders
FROM DataCoSupplyChainDataset
WHERE [Category Name] IN ('Fishing','Cleats','Camping and Hkiking','Cardio Equipment')
GROUP BY DATEPART(year,[shipping date (DateOrders)]) ,[Category Name]
ORDER BY DATEPART(year,[shipping date (DateOrders)]) ,[Category Name]

----Total sales per product
SELECT [Product Name],SUM(Sales) AS Total_sale, ROUND(SUM(Sales)*100/SUM( SUM(Sales)) OVER(),2) AS Total_Sale_percentage
FROM DataCoSupplyChainDataset
GROUP BY [Product Name]
ORDER BY Total_sale DESC

----trend of sale
SELECT DATEPART(year,[shipping date (DateOrders)]) as sale_year, SUM(Sales)
FROM DataCoSupplyChainDataset
GROUP BY DATEPART(year,[shipping date (DateOrders)])
ORDER BY sale_year

--FRAUD RISK
--Top 10 countries with high fraud risk
SELECT TOP 10
[Order Country], COUNT([Order Status]) AS number_of_suspected_fraud_cases
FROM DataCoSupplyChainDataset
WHERE [Order Status]='SUSPECTED_FRAUD'
GROUP BY [Order Country]
ORDER BY number_of_fraud DESC

--The payment type with high fraud risk
SELECT Type, COUNT([Order Status]) AS number_of_fraud
FROM DataCoSupplyChainDataset
WHERE [Order Status]='SUSPECTED_FRAUD'
GROUP BY Type
ORDER BY number_of_fraud DESC

--DELIVERY STATUS
--yearly difference of shipping canceled case
With cal_cancel as(
SELECT DATEPART(YEAR,[shipping date (DateOrders)]) AS shipping_year, COUNT([Delivery Status]) AS Count_canceled_shipping
FROM DataCoSupplyChainDataset
WHERE [Delivery Status]='Shipping canceled'
GROUP BY DATEPART(YEAR,[shipping date (DateOrders)])
)

SELECT shipping_year, Count_canceled_shipping,Count_canceled_shipping- LAG(Count_canceled_shipping) 
over ( order by shipping_year) as diff_cancel
from cal_cancel

--compare shipping canceled in each month of years
With cal_cancel_month as(
SELECT DATEPART(YEAR,[shipping date (DateOrders)]) AS shipping_year,Month([shipping date (DateOrders)]) AS shipping_month ,
COUNT([Delivery Status]) AS Count_canceled_shipping
FROM DataCoSupplyChainDataset
WHERE [Delivery Status]='Shipping canceled' and DATEPART(YEAR,[shipping date (DateOrders)])<>2018
GROUP BY DATEPART(YEAR,[shipping date (DateOrders)]),DATEPART(Month,[shipping date (DateOrders)])

)
SELECT shipping_month,
SUM(CASE shipping_year WHEN 2015 THEN Count_canceled_shipping END) AS shipping_cancel_2015,
SUM(CASE shipping_year WHEN 2016 THEN Count_canceled_shipping END) AS shipping_cancel_2016,
SUM(CASE shipping_year WHEN 2017 THEN Count_canceled_shipping END) AS shipping_cancel_2017
FROM cal_cancel_month
GROUP BY shipping_month
