CREATE TABLE CUSTOMERS  (
CUST_ID INT PRIMARY KEY,
CUST_AGE INT,
GENDER VARCHAR(10),
ANNUAL_INCOME FLOAT,
TOTAL_SPEND FLOAT,
YEARS_AS_CUSTOMER INT,
NUMBER_OF_PURCHASES INT,
AVERAGE_TRANSACTION_AMOUNT FLOAT,
NUMBER_OF_RETURNS INT,
NUM_OF_SUPPORT_CONTACTS INT,
SATISFACTION_SCORE INT,
LAST_PURCHASE_DAYS_AGO INT,
EMAIL_OPT_IN BOOLEAN,
PROMOTION_RESPONSE VARCHAR(20),
TARGET_CHURN BOOLEAN);

ALTER TABLE CUSTOMERS CHANGE COLUMN CUST_ID CUSTOMER_ID INT ,
CHANGE COLUMN CUST_AGE AGE INT,
CHANGE COLUMN NUMBER_OF_PURCHASES NUM_OF_PURCHASES INT ;

ALTER TABLE CUSTOMERS MODIFY COLUMN EMAIL_OPT_IN VARCHAR(10);
alter table customers modify column TARGET_CHURN varchar(10);

DESC CUSTOMERS ;
-- count total records
SELECT count(*) FROM CUSTOMERS; 
-- view 10 rows
select * from customers limit 10 ;
-- Check missing values (NULLs)
select 
sum(case when customer_id is null then 1 else 0 end) as missing_data
from customers ;
-- now we can check the all attributes if there any values are null or not
SELECT 
    SUM(CASE WHEN CUSTOMER_ID IS NULL THEN 1 ELSE 0 END) AS Missing_CUST_ID,
    SUM(CASE WHEN AGE IS NULL THEN 1 ELSE 0 END) AS Missing_CUST_AGE,
    SUM(CASE WHEN GENDER IS NULL THEN 1 ELSE 0 END) AS Missing_GENDER,
    SUM(CASE WHEN ANNUAL_INCOME IS NULL THEN 1 ELSE 0 END) AS Missing_ANNUAL_INCOME,
    SUM(CASE WHEN TOTAL_SPEND IS NULL THEN 1 ELSE 0 END) AS Missing_TOTAL_SPEND,
    SUM(CASE WHEN YEARS_AS_CUSTOMER IS NULL THEN 1 ELSE 0 END) AS Missing_YEARS_AS_CUSTOMER,
    SUM(CASE WHEN NUM_OF_PURCHASES IS NULL THEN 1 ELSE 0 END) AS Missing_NUMBER_OF_PURCHASES,
    SUM(CASE WHEN AVERAGE_TRANSACTION_AMOUNT IS NULL THEN 1 ELSE 0 END) AS Missing_AVERAGE_TRANSACTION_AMOUNT,
    SUM(CASE WHEN NUMBER_OF_RETURNS IS NULL THEN 1 ELSE 0 END) AS Missing_NUMBER_OF_RETURNS,
    SUM(CASE WHEN NUM_OF_SUPPORT_CONTACTS IS NULL THEN 1 ELSE 0 END) AS Missing_NUM_OF_SUPPORT_CONTACTS,
    SUM(CASE WHEN SATISFACTION_SCORE IS NULL THEN 1 ELSE 0 END) AS Missing_SATISFACTION_SCORE,
    SUM(CASE WHEN LAST_PURCHASE_DAYS_AGO IS NULL THEN 1 ELSE 0 END) AS Missing_LAST_PURCHASE_DAYS_AGO,
    SUM(CASE WHEN EMAIL_OPT_IN IS NULL THEN 1 ELSE 0 END) AS Missing_EMAIL_OPT_IN,
    SUM(CASE WHEN PROMOTION_RESPONSE IS NULL THEN 1 ELSE 0 END) AS Missing_PROMOTION_RESPONSE,
    SUM(CASE WHEN TARGET_CHURN IS NULL THEN 1 ELSE 0 END) AS Missing_TARGET_CHURN
FROM CUSTOMERS ;
-- Find duplicate Customer_IDs
select customer_id , count(*) from customers group by customer_id having count(*) > 1 ;
-- Count how many customers churned vs. stayed
select target_churn, count(*) from customers group by TARGET_CHURN ;
-- Why Do We Check Churn Counts?
-- Understand customer retention trends before building a churn prediction model.
-- Check for data imbalance (if one category has significantly fewer records, we may need to adjust our model).
-- Plan business strategies (if many customers churn, investigate causes like high prices, poor service, etc.).

-- Check how different factors impact churn.
-- SQL Query (Churn Rate by Age Group)
SELECT 
    CASE 
        WHEN AGE < 25 THEN 'Under 25'
        WHEN AGE BETWEEN 25 AND 40 THEN '25-40'
        WHEN AGE BETWEEN 41 AND 60 THEN '41-60'
        ELSE '60+'
    END AS Age_Group,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN TARGET_CHURN = 'True' THEN 1 ELSE 0 END) AS Churned_Customers
FROM CUSTOMERS
GROUP BY Age_Group;  -- What this does? → Groups customers by age and counts how many churned.

-- See which variables are related to churn.
-- SQL Query (Correlation Between Total Spend & Churn)
select Target_Churn , Avg(Total_Spend) as Avg_spend
from customers
group by Target_churn ; -- By running this query we can check the avg_spend ,select Avg(Total_spend) from customers where Target_churn = 'True'

-- Label Encoding (for Binary Categories like Gender)
-- convert Gender into numerical value (male = 0 and Female = 1 and others = NULL)
-- so, Before converting we should add a column into a table
Alter Table customers add column GENDER_ENCODED INT;
-- after adding we should update our table
SET SQL_SAFE_UPDATES = 0;
update customers
set GENDER_ENCODED = 
CASE when GENDER = 'Male' then 0
when GENDER = 'Female' then 1
else null
end;
SET SQL_SAFE_UPDATES = 1;

select * from customers;
--  One-Hot Encoding (For Multi-Class Categories like Promotion_Response)
-- For categorical variables with more than two categories (e.g., Promotion_Response with values: Responded, Ignored, Unsubscribed), we create new columns.
alter table customers add column PROMOTION_RESPONSE_IGNORED int default 0,
ADD column PROMOTION_RESPONSE_RESPONDED INT default 0,
add column PROMOTION_RESPONSE_UNSUBSCRIBED INT default 0;

SET SQL_SAFE_UPDATES = 0;  -- this one is compulsory to run if we want to update the values in customers table
update customers
set PROMOTION_RESPONSE_RESPONDED = 
CASE when PROMOTION_RESPONSE = "Responded" then 1 else 0 end,
PROMOTION_RESPONSE_IGNORED = case when PROMOTION_RESPONSE="Ignored" then 1 else 0 end,
PROMOTION_RESPONSE_UNSUBSCRIBED = case when PROMOTION_RESPONSE = "Unsubscribed" then 1 else 0 end;

