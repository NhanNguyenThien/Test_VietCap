--Câu 1
SELECT TOP 1 
    b.Broker_ID,
    b.Full_Name,
    SUM(t.Matched_Quantity * t.Matched_Price) AS total_value
FROM Transaction t
JOIN Broker b ON t.Broker_ID = b.Broker_ID
WHERE YEAR(t.Date) = 2023
GROUP BY b.Broker_ID, b.Full_Name
ORDER BY total_value DESC;

--Câu 2
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

--câu 3
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

--câu 4
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

--câu 5
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