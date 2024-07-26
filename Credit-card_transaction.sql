-- solve below questions..

	SELECT * FROM credit;
    
-- 1- write a query to print top 5 cities with highest spends and 
--    their percentage contribution of total credit card spends.
		
	WITH CTE1 AS (
        SELECT SUM(amount) AS Total
        FROM credit),
        
        CTE2 AS (
        SELECT city,
        SUM(amount) AS City_Total
        FROM credit
        GROUP BY city)
        
        SELECT city,City_Total,
        ROUND((City_Total/Total)*100,2) AS PERCENTAGE_CONTRIBUTION
        FROM CTE1,CTE2
        ORDER BY PERCENTAGE_CONTRIBUTION DESC
        LIMIT 5;

-- 2- write a query to print highest spend month for each year and 
--    amount spent in that month for each card type.

	WITH CTE1 AS (
        SELECT card_type,
        MONTH(transaction_date) AS mn ,
        YEAR(transaction_date) AS yr, 
        SUM(amount) AS Total
        FROM credit
        GROUP BY card_type, MONTH(transaction_date), YEAR(transaction_date) ),
        
        CTE2 AS (
        SELECT * , 
        DENSE_RANK() OVER(PARTITION BY card_type ORDER BY Total DESC) AS d_rnk
        FROM CTE1)
        
        SELECT * FROM CTE2
        WHERE d_rnk=1;
        
-- 3- write a query to print the transaction details(all columns from the table) for each card type when
	-- it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
	
    WITH CTE1 AS (
        SELECT *,
        SUM(amount) OVER(PARTITION BY card_type ORDER BY transaction_date,transaction_id) as Cumulative_amount
        FROM credit),
        
        CTE2 AS (
        SELECT *,
        DENSE_RANK() OVER(PARTITION BY card_type ORDER BY Cumulative_amount ) AS d_rnk
        FROM CTE1 WHERE Cumulative_amount > 1000000)
        
        SELECT *
        FROM CTE2 WHERE d_rnk=1;
        
-- 4- write a query to find city which had lowest percentage spend for gold card type
			
		WITH CTE1 AS (
            SELECT city,card_type,
            SUM(amount) AS Total,
            SUM(CASE WHEN card_type="Gold" THEN amount END) AS Gold_Total
            FROM credit
            GROUP BY city,card_type)
            
            SELECT city, ROUND((SUM(Gold_total)/SUM(Total))*100,2) AS Percentage_contribution
            FROM CTE1
            GROUP BY city
            HAVING SUM(Gold_total) >0
            ORDER BY Percentage_contribution;
            
-- 5- write a query to print 3 columns: 
--    city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

     WITH CTE1 AS (
			      SELECT city,exp_type, 
            SUM(amount) AS City_Total
            FROM credit
            group by city,exp_type),
            
            CTE2 AS (
            SELECT *,
            DENSE_RANK() OVER(PARTITION BY city ORDER BY City_Total) as Asc_rnk,
			      DENSE_RANK() OVER(PARTITION BY city ORDER BY City_Total DESC) as Desc_rnk
            FROM CTE1)
            
            SELECT city,
            MIN(CASE WHEN Asc_rnk=1 THEN exp_type END) Lowest_exp_type,
			      MAX(CASE WHEN Desc_rnk=1 THEN exp_type END) Highest_exp_type
            FROM CTE2
            GROUP BY city;

-- 6- write a query to find percentage contribution of spends by females for each expense type
	
		      	SELECT exp_type,
            ROUND(SUM(CASE WHEN Gender="F" THEN amount END)/SUM(AMOUNT),2) AS Female_Percentage_contribution
            FROM credit
            GROUP BY exp_type;
            
-- 7- which card and expense type combination saw highest month over month growth in Jan-2014
		
   WITH CTE1 AS (
			      SELECT card_type,exp_type,
            MONTH(transaction_date) AS mn, 
            YEAR(transaction_date) AS yr,
            SUM(amount) AS Total
            FROM credit
            GROUP BY  card_type,exp_type,
            MONTH(transaction_date), 
            YEAR(transaction_date) ),
            
            CTE2 AS (
            SELECT *,
            LAG(TOTAL) OVER(PARTITION BY card_type,exp_type ORDER BY yr,mn) as Previous_Month_Total
            FROM CTE1)
             
            SELECT *,
            Total-Previous_Month_Total As Growth
            FROM CTE2 
            WHERE Previous_Month_Total IS NOT NULL 
            AND mn=1 AND yr=2014
            ORDER BY GROWTH DESC
            LIMIT 1 ;
            
-- 8- during weekends which city has highest total spend to total no of transcations ratio 
			
		WITH CTE1 AS (
            SELECT *,
            WEEKDAY(transaction_date) AS Weekdays
            FROM credit)
            
            SELECT city ,
            SUM(amount)/COUNT(transaction_id) as Ratio
            FROM CTE1 
            WHERE Weekdays in(5,6)
            GROUP BY city 
            ORDER BY Ratio Desc
            LIMIT 1;
            
-- 9- which city took least number of days to reach its 500th transaction after the first transaction in that city
		
        WITH CTE1 AS (
			      SELECT *,
            ROW_NUMBER() OVER(PARTITION BY city ORDER BY transaction_date,transaction_id) as rn
            FROM credit)
            
            SELECT city,
            TIMESTAMPDIFF(DAY,MIN(transaction_date),MAX(transaction_date)) AS Day_Diff
            FROM CTE1
            WHERE rn=1 OR rn=500
            GROUP BY city
            HAVING COUNT(transaction_date)=2
            ORDER BY Day_Diff
            LIMIT 1;
          
