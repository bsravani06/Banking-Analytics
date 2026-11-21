-- Q1 - Total Credit Transaction Amount
SELECT CONCAT('₹ ',
        FORMAT(SUM(amount) / 1000000, 2),' M') 
        AS Total_Credit_Amount_M
FROM debit_credit
WHERE LOWER(TRIM(transaction_type)) = 'credit';

-- Q2 - Total Debit Transaction Amount (Millions)
SELECT CONCAT('₹ ',
        FORMAT(SUM(amount) / 1000000, 2, 'en_IN'),' M')
        AS Total_Debit_Amount_M
FROM debit_credit
WHERE LOWER(TRIM(transaction_type)) = 'debit';

-- Q3 - Credit to Debit Ratio
SELECT ROUND(
        SUM(CASE
            WHEN LOWER(TRIM(transaction_type)) = 'credit'
            THEN amount ELSE 0
        END)/NULLIF(SUM(CASE
                WHEN LOWER(TRIM(transaction_type)) = 'debit'
                THEN amount ELSE 0
            END),0),4) AS Credit_Debit_Ratio
FROM debit_credit;

-- Q4 - Net Transaction Amount:
SELECT CONCAT(
        CASE
            WHEN SUM(
                CASE
                    WHEN LOWER(TRIM(`transaction_type`)) = 'credit' THEN `amount`
                    WHEN LOWER(TRIM(`transaction_type`)) = 'debit' THEN -`amount`
                    ELSE 0
                END) >= 0 THEN '+₹'
            ELSE '-₹'
        END,
        FORMAT(ABS(SUM(
                CASE
                    WHEN LOWER(TRIM(`transaction_type`)) = 'credit' THEN `amount`
                    WHEN LOWER(TRIM(`transaction_type`)) = 'debit' THEN -`amount`
                    ELSE 0
                END)) / 1000,1,'en_IN'),'K')
                AS Net_Transaction_Amount
FROM `debit_credit`;

-- Q5 - Account Activity Ratio
SELECT ROUND(
        COUNT(customer_id) / NULLIF(SUM(balance), 0) * 1000,4)
        AS Account_Activity_Ratio
FROM debit_credit;

-- Q6: Transactions per Month
SELECT
    MONTH(STR_TO_DATE(transaction_date, '%Y-%m-%d')) AS Month_Number,
    MONTHNAME(STR_TO_DATE(transaction_date, '%Y-%m-%d')) AS Transaction_Month,
    COUNT(*) AS Total_Transactions
FROM debit_credit
WHERE STR_TO_DATE(transaction_date, '%Y-%m-%d') IS NOT NULL
GROUP BY
    MONTH(STR_TO_DATE(transaction_date, '%Y-%m-%d')),
    MONTHNAME(STR_TO_DATE(transaction_date, '%Y-%m-%d'))
ORDER BY Month_Number;

-- Q7: Transaction Amount by Branch
SELECT branch AS Branch,
    TRIM(transaction_type) AS Transaction_Type,
    CONCAT('₹ ', FORMAT(SUM(amount) / 10000000, 2),' Cr') AS Total_Amount_Cr
FROM debit_credit
GROUP BY branch, TRIM(transaction_type)
ORDER BY branch, transaction_type;

-- Q8: Transaction Volume by Bank
SELECT bank_name AS Bank_Name,
    CONCAT('₹ ',FORMAT(SUM(amount) / 10000000, 1),' Cr')
    AS Transaction_Volume_Cr
FROM debit_credit
GROUP BY bank_name
ORDER BY SUM(amount) DESC
LIMIT 6;

-- Q9: Transaction Method Distribution
SELECT
    TRIM(transaction_method) AS Transaction_Method,
    COUNT(*) AS Total_Transactions,
    CONCAT(FORMAT(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM debit_credit), 2),
        '%') AS Transaction_Percentage
FROM debit_credit
GROUP BY TRIM(transaction_method)
ORDER BY COUNT(*) DESC;

-- Q10: Branch Growth (Month-over-Month %)
WITH Monthly_Branch_Amount AS (
    SELECT branch,
        MONTH(STR_TO_DATE(transaction_date, '%Y-%m-%d')) AS Month_No,
        SUM(amount) AS Monthly_Amount
    FROM debit_credit
    WHERE STR_TO_DATE(transaction_date, '%Y-%m-%d') IS NOT NULL
    GROUP BY branch,
        MONTH(STR_TO_DATE(transaction_date, '%Y-%m-%d'))),
Branch_Growth AS (
    SELECT branch, Month_No, Monthly_Amount,
        LAG(Monthly_Amount) OVER (PARTITION BY branch
            ORDER BY Month_No) AS Previous_Month_Amount
    FROM Monthly_Branch_Amount)
SELECT
    branch AS Branch,
    MONTHNAME(STR_TO_DATE(
        CONCAT('2024-', LPAD(Month_No, 2, '0'), '-01'),'%Y-%m-%d'
    )) AS Transaction_Month,
    CONCAT(ROUND((Monthly_Amount - Previous_Month_Amount)
	/ NULLIF(Previous_Month_Amount, 0) * 100,2),'%') AS Growth_Percentage
FROM Branch_Growth
WHERE Previous_Month_Amount IS NOT NULL
ORDER BY branch, Month_No;

-- Q11: High-Risk Transactions
SELECT COUNT(*) AS High_Risk_Transactions
FROM debit_credit
WHERE CAST(amount AS DECIMAL(18,2)) > 4500;

-- Q12: Suspicious Transaction Frequency
SELECT
    MONTH(STR_TO_DATE(transaction_date, '%Y-%m-%d')) AS Month_No,
    MONTHNAME(STR_TO_DATE(transaction_date, '%Y-%m-%d')) AS Transaction_Month,
    COUNT(*) AS Suspicious_Transactions
FROM debit_credit
WHERE LOWER(TRIM(transaction_type)) = 'debit' AND amount > 4750
AND STR_TO_DATE(transaction_date, '%Y-%m-%d') IS NOT NULL
GROUP BY MONTH(STR_TO_DATE(transaction_date, '%Y-%m-%d')),
    MONTHNAME(STR_TO_DATE(transaction_date, '%Y-%m-%d'))
ORDER BY Month_No;

-- FINAL: Debit & Credit Card Analytics KPI Summary
SELECT
    CONCAT('₹ ',FORMAT(
            SUM(CASE
                WHEN LOWER(TRIM(transaction_type)) = 'credit'
                THEN amount ELSE 0
            END) / 1000000,2),' M') AS Total_Credit_Amount,
	CONCAT('₹ ',FORMAT(
            SUM(CASE
                WHEN LOWER(TRIM(transaction_type)) = 'debit'
                THEN amount ELSE 0
            END) / 1000000,2),' M') AS Total_Debit_Amount,
	ROUND(SUM(CASE
            WHEN LOWER(TRIM(transaction_type)) = 'credit'
            THEN amount ELSE 0
        END)/NULLIF(
            SUM(CASE
                WHEN LOWER(TRIM(transaction_type)) = 'debit'
                THEN amount ELSE 0
            END),0),4) AS Credit_Debit_Ratio,
	CONCAT('₹ ',FORMAT(
            SUM(CASE
                WHEN LOWER(TRIM(transaction_type)) = 'credit'
                THEN amount
                WHEN LOWER(TRIM(transaction_type)) = 'debit'
                THEN -amount
                ELSE 0
            END) / 1000,2),' K') AS Net_Transaction_Amount,
	ROUND(COUNT(customer_id) / NULLIF(SUM(balance), 0) * 1000,4
    ) AS Account_Activity_Ratio,
    COUNT(
        CASE
            WHEN CAST(amount AS DECIMAL(18,2)) > 4500
            THEN 1
        END) AS High_Risk_Transactions
FROM debit_credit;