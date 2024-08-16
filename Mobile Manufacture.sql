-- Displaying all the tables

select * from DIM_CUSTOMER
select * from DIM_DATE
select * from DIM_LOCATION
select * from DIM_MANUFACTURER
select * from DIM_MODEL
select * from FACT_TRANSACTIONS

-- Listing all the states with customers who have purchased cellphones from 2005 to the present.

select State, COUNT(City) [CNT] from FACT_TRANSACTIONS a
join DIM_LOCATION b
on a.IDLocation = b.IDLocation
where YEAR(Date) between 2005 and YEAR(GETDATE())
group by state
order by CNT desc

-- Identifying the state in the US that has purchased the most Samsung cell phones.

select State, COUNT(state) [CNT] from (
select a.IDModel, b.State, D.Manufacturer_Name from FACT_TRANSACTIONS a
join DIM_LOCATION b
on a.IDLocation = b.IDLocation
JOIN DIM_MODEL C
ON a.IDModel = C.IDModel
JOIN DIM_MANUFACTURER D
ON C.IDManufacturer = D.IDManufacturer
where b.Country = 'US' and D.Manufacturer_Name = 'Samsung' ) as x
GROUP BY State
order by CNT desc

-- Displaying the number of transactions for each model, per zip code, per state.

select IDModel, ZipCode, State, COUNT(IDModel) [CNT] from FACT_TRANSACTIONS a
join DIM_LOCATION b
on a.IDLocation = b.IDLocation
GROUP BY IDModel, ZipCode, State
ORDER BY CNT DESC

-- Finding the cheapest cellphone and displaying the price.

SELECT TOP 1 * FROM DIM_MODEL A
JOIN DIM_MANUFACTURER B
ON A.IDManufacturer = B.IDManufacturer
ORDER BY Unit_price

-- Calculating the average price for each model among the top 5 manufacturers by sales quantity, ordered by average price.

select IDModel, AVG(TotalPrice) [Avg Price] from (
SELECT a.IDModel, IDManufacturer, Quantity, TotalPrice FROM FACT_TRANSACTIONS a
join DIM_MODEL b
on a.IDModel = b.IDModel
WHERE IDManufacturer IN (select top 5 IDManufacturer from (
SELECT IDManufacturer, SUM(Quantity) [SUM_QTY] FROM FACT_TRANSACTIONS a
join DIM_MODEL b
on a.IDModel = b.IDModel
GROUP BY IDManufacturer
) as x
order by SUM_QTY desc) ) as y
GROUP BY IDModel
order by [Avg Price]

-- Listing the names of customers and the average amount spent in 2009, where the average is higher than 500.

select a.IDCustomer,b.Customer_Name, AVG(TotalPrice) [AVG] from FACT_TRANSACTIONS A
join DIM_CUSTOMER b
on A.IDCustomer = b.IDCustomer
where YEAR(Date) = 2009
GROUP BY a.IDCustomer, b.Customer_Name
HAVING AVG(TotalPrice) > 500
order by AVG desc

-- Identifying any model that was in the top 5 in terms of quantity sold simultaneously in 2008, 2009, and 2010.

WITH X AS (
    SELECT TOP 5 IDModel, SUM(Quantity) AS QTY 
    FROM FACT_TRANSACTIONS
    WHERE YEAR(Date) = 2008
    GROUP BY IDModel
    ORDER BY QTY DESC
),
Y AS (
    SELECT TOP 5 IDModel, SUM(Quantity) AS QTY 
    FROM FACT_TRANSACTIONS
    WHERE YEAR(Date) = 2009
    GROUP BY IDModel
    ORDER BY QTY DESC
),
Z AS (
    SELECT TOP 5 IDModel, SUM(Quantity) AS QTY 
    FROM FACT_TRANSACTIONS
    WHERE YEAR(Date) = 2010
    GROUP BY IDModel
    ORDER BY QTY DESC
)
SELECT X.IDModel
FROM X
JOIN Y ON X.IDModel = Y.IDModel
JOIN Z ON Y.IDModel = Z.IDModel

-- Finding the manufacturer with the 2nd highest sales in 2009 and the manufacturer with the 2nd highest sales in 2010.

select * from (
select YEAR(Date) [Date],b.IDManufacturer, SUM(TotalPrice) [Price],
RANK() over (order by SUM(TotalPrice) desc) as Rankings
from FACT_TRANSACTIONS a
join DIM_MODEL b
on a.IDModel = b.IDModel
where YEAR(a.Date) = 2009
group by YEAR(Date), b.IDManufacturer ) as x
where Rankings = 2
union
select * from (
select YEAR(Date) [Date],b.IDManufacturer, SUM(TotalPrice) [Price],
RANK() over (order by SUM(TotalPrice) desc) as Rankings
from FACT_TRANSACTIONS a
join DIM_MODEL b
on a.IDModel = b.IDModel
where YEAR(a.Date) = 2010
group by YEAR(Date), b.IDManufacturer ) as x
where Rankings = 2

-- Displaying manufacturers that sold cellphones in 2010 but not in 2009.

select distinct b.IDManufacturer from FACT_TRANSACTIONS a
join DIM_MODEL b
on a.IDModel = b.IDModel
where YEAR(Date) = 2010 and IDManufacturer not in (select distinct b.IDManufacturer from FACT_TRANSACTIONS a
join DIM_MODEL b
on a.IDModel = b.IDModel
where YEAR(Date) = 2009)
