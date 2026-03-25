--Question 1: Which broker contributes the highest transaction value (matched_value) in 2023?
SELECT TOP 1 
    b.Broker_ID,
    b.Full_Name,
    SUM(t.Matched_Quantity * t.Matched_Price) AS total_value
FROM Transaction t
JOIN Broker b ON t.Broker_ID = b.Broker_ID
WHERE YEAR(t.Date) = 2023
GROUP BY b.Broker_ID, b.Full_Name
ORDER BY total_value DESC;

--Question 2: Return the customer’s name that  - Opened their account in 2023? - Has the fifth highest transaction value in 2023?
WITH customer_value AS (
    SELECT 
        c.Account_Number,
        c.Full_Name,
        SUM(t.Matched_Quantity * t.Matched_Price) AS total_value,
        DENSE_RANK() OVER (ORDER BY SUM(t.Matched_Quantity * t.Matched_Price) DESC) AS rnk
    FROM Customer c
    JOIN Transaction t ON c.Account_Number = t.Account_Number
    WHERE YEAR(t.Date) = 2023
      AND YEAR(c.Open_Date) = 2023
    GROUP BY c.Account_Number, c.Full_Name
)
SELECT *
FROM customer_value
WHERE rnk = 5;

--Question 3: Return the average sell value and buy value per month of each customer in 2023? 
SELECT 
    c.Account_Number,
    MONTH(t.Date) AS month,
    AVG(CASE WHEN t.Order_Type = '01' 
        THEN t.Matched_Quantity * t.Matched_Price END) AS avg_sell,
    AVG(CASE WHEN t.Order_Type = '02' 
        THEN t.Matched_Quantity * t.Matched_Price END) AS avg_buy
FROM Transaction t
JOIN Customer c ON t.Account_Number = c.Account_Number
WHERE YEAR(t.Date) = 2023
GROUP BY c.Account_Number, MONTH(t.Date)
ORDER BY c.Account_Number, month;

--question 4: Return the customers which have the highest transaction value (matched_value) in 2023 in each Department? 
WITH customer_value AS (
    SELECT 
        b.Department,
        c.Account_Number,
        c.Full_Name,
        SUM(t.Matched_Quantity * t.Matched_Price) AS total_value,
        RANK() OVER (
            PARTITION BY b.Department 
            ORDER BY SUM(t.Matched_Quantity * t.Matched_Price) DESC
        ) AS rnk
    FROM Transaction t
    JOIN Customer c ON t.Account_Number = c.Account_Number
    JOIN Broker b ON c.Broker_ID = b.Broker_ID
    WHERE YEAR(t.Date) = 2023
    GROUP BY b.Department, c.Account_Number, c.Full_Name
)
SELECT *
FROM customer_value
WHERE rnk = 1;

--question 5: Return accumulated revenue (transaction_value) of our company per month in 2023?
WITH monthly AS (
    SELECT 
        MONTH(Date) AS month,
        SUM(Matched_Quantity * Matched_Price) AS revenue
    FROM Transaction
    WHERE YEAR(Date) = 2023
    GROUP BY MONTH(Date)
)
SELECT 
    month,
    revenue,
    SUM(revenue) OVER (ORDER BY month) AS accumulated_revenue
FROM monthly
ORDER BY month;
