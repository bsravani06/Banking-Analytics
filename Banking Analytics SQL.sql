CREATE DATABASE banking_analytics;
USE banking_analytics;

SELECT 'Loan Data' AS table_name, COUNT(*) AS total_records
FROM loan_data
UNION ALL
SELECT 'Debit Credit' AS table_name, COUNT(*) AS total_records
FROM debit_credit;

-- Q1: Total Loan Amount Funded
SELECT CONCAT('₹ ',FORMAT(SUM(funded_amount) / 1000000, 2),' M') AS Total_Loan_Amount_Funded
FROM loan_data;

-- Q2: Total Loans
SELECT CONCAT(FORMAT(COUNT(*), 0), ' Loans') AS Total_Loans
FROM loan_data;

-- Q3: Total Collection in Millions
SELECT CONCAT('₹ ',FORMAT(SUM(total_pymnt) / 1000000, 2),' M') AS Total_Collection
FROM loan_data;

-- Q4: Total Interest in Millions
SELECT CONCAT('₹ ',FORMAT(SUM(total_rec_int) / 1000000, 2),' M') AS Total_Interest
FROM loan_data;

-- Q5: Branch-Wise Loan Performance
SELECT branch_name,CONCAT('₹ ',FORMAT(SUM(funded_amount) / 1000000, 2),' M') AS Total_Loan_Funded
FROM loan_data
GROUP BY branch_name
ORDER BY SUM(funded_amount) DESC;

-- Q6: State-Wise Loan Performance in Millions
SELECT state_name,CONCAT('₹ ',FORMAT(SUM(funded_amount) / 1000000, 2),' M') AS Loan_Funded
FROM loan_data
GROUP BY state_name
ORDER BY SUM(funded_amount) DESC;

-- Q7: Religion-Wise Loan Performance
SELECT religion,CONCAT('₹ ',FORMAT(SUM(funded_amount) / 1000000, 2),' M') AS Loan_Funded
FROM loan_data
GROUP BY religion
ORDER BY SUM(funded_amount) DESC;

-- Q8: Product Group-Wise Loan Performance
SELECT purpose_category,CONCAT('₹ ',FORMAT(SUM(funded_amount) / 1000000, 2),' M') AS Loan_Funded
FROM loan_data
GROUP BY purpose_category
ORDER BY SUM(funded_amount) DESC;

-- Q9: Monthly Disbursement Trend (Crores)
SELECT DATE_FORMAT(parsed_date, '%Y-%m') AS Disbursement_Month,ROUND(
	SUM(CAST(funded_amount AS DECIMAL(18,2))) / 10000000,2) AS Total_Funded
FROM (SELECT funded_amount,COALESCE(
            STR_TO_DATE(TRIM(disbursement_date), '%d/%m/%Y'),
            STR_TO_DATE(TRIM(disbursement_date), '%d-%m-%Y')) AS parsed_date
            FROM loan_data) AS d
WHERE parsed_date >= '2016-11-01' AND parsed_date < '2020-03-01'
GROUP BY DATE_FORMAT(parsed_date, '%Y-%m')
ORDER BY Disbursement_Month;

-- Q10: Grade-Wise Loan Analysis
SELECT grade AS Grade,COUNT(*) AS Total_Loans,
    ROUND(SUM(CAST(funded_amount AS DECIMAL(18,2))) / 10000000,2
    ) AS Total_Funded_Cr
FROM loan_data
GROUP BY grade
ORDER BY grade;

-- Q11: Default Loan Count
SELECT COUNT(*) AS Default_Loan_Count
FROM loan_data
WHERE UPPER(TRIM(is_default_loan)) = 'Y';

-- Q12: Delinquent Client Count
SELECT COUNT(DISTINCT client_id) AS Delinquent_Client_Count
FROM loan_data
WHERE UPPER(TRIM(is_delinquent_loan)) = 'Y';

-- Q13: Delinquent Loan Rate
SELECT CONCAT(ROUND(COUNT(CASE
                WHEN UPPER(TRIM(is_delinquent_loan)) = 'Y'
                THEN 1
            END) * 100.0 / COUNT(*),2),' %') AS Delinquent_Loan_Rate
FROM loan_data;

-- Q14: Default Loan Rate
SELECT CONCAT(ROUND(
            COUNT(CASE
                    WHEN UPPER(TRIM(is_default_loan)) = 'Y'
                    THEN 1
                END) * 100.0 / COUNT(*),2),' %') AS Default_Loan_Rate
FROM loan_data;

-- Q15: Loan Status-Wise Loan
SELECT loan_status AS Loan_Status,
    COUNT(*) AS Total_Loans
FROM loan_data
GROUP BY loan_status
ORDER BY Total_Loans DESC;

-- Q16: Age Group-Wise Loan
SELECT
    age_group AS Age_Group,
    COUNT(*) AS Total_Loans
FROM loan_data
GROUP BY age_group
ORDER BY age_group;

-- Q17: No Verified Loans
SELECT
    COUNT(*) AS No_Verified_Loans
FROM loan_data
WHERE LOWER(TRIM(verification_status)) = 'not verified';

-- Q18: Loan Maturity by Term
SELECT
    term AS Loan_Term,
    COUNT(*) AS Total_Loans,
    ROUND(SUM(CAST(funded_amount AS DECIMAL(18,2))) / 10000000,2
    ) AS Total_Funded_Cr
FROM loan_data
GROUP BY term
ORDER BY term;


-- Bank Loan Analytics: Key Performance Indicators (KPIs)
SELECT COUNT(*) AS Total_Loans,
    CONCAT('₹ ',ROUND(
            SUM(CAST(funded_amount AS DECIMAL(18,2))) / 10000000,2),' Cr')
            AS Total_Funded_Amount,
    CONCAT('₹ ',ROUND(
            SUM(CAST(total_pymnt AS DECIMAL(18,2))) / 10000000,2),' Cr')
            AS Total_Collection,
    CONCAT('₹ ',ROUND(
            SUM(CAST(total_rec_int AS DECIMAL(18,2))) / 10000000,2),' Cr')
            AS Total_Interest,
    SUM(
        CASE
            WHEN UPPER(TRIM(is_default_loan)) = 'Y'
            THEN 1 ELSE 0
        END) AS Default_Loans,
    SUM(
        CASE
            WHEN UPPER(TRIM(is_delinquent_loan)) = 'Y'
            THEN 1 ELSE 0
        END) AS Delinquent_Loans,
    CONCAT(ROUND(SUM(
                CASE
                    WHEN UPPER(TRIM(is_default_loan)) = 'Y'
                    THEN 1 ELSE 0
                END) * 100.0 / COUNT(*),2),'%')
                AS Default_Loan_Rate,
    CONCAT(ROUND(SUM(
                CASE
                    WHEN UPPER(TRIM(is_delinquent_loan)) = 'Y'
                    THEN 1 ELSE 0
                END) * 100.0 / COUNT(*),2),'%')
                AS Delinquent_Loan_Rate,
    SUM(
        CASE
            WHEN LOWER(TRIM(verification_status)) = 'not verified'
            THEN 1 ELSE 0
        END) AS Not_Verified_Loans
FROM loan_data;
