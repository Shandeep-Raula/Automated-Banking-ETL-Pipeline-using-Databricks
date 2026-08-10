CREATE STREAMING LIVE TABLE silver_customers_transformed
COMMENT 'Transformed Data'
AS
SELECT
    c.*,
    FLOOR(MONTHS_BETWEEN(CURRENT_DATE(), dob) / 12) AS customer_age,
    DATEDIFF(CURRENT_DATE(), join_date) AS tenure_days,
    (dob < DATE '1900-01-01') OR dob > CURRENT_DATE() AS dob_out_of_range_flag,
    CURRENT_TIMESTAMP() AS transformation_date
FROM STREAM(live.bronze_customers_ingestion_cleaned) c;

-- SCD 1

CREATE STREAMING LIVE TABLE silver_customers_transformed_scd1;

APPLY CHANGES INTO live.silver_customers_transformed_scd1
FROM STREAM(live.silver_customers_transformed)
KEYS(customer_id)
SEQUENCE BY transformation_date
COLUMNS * EXCEPT (transformation_date)
STORED AS SCD TYPE 1;


-- View

CREATE OR REFRESH LIVE VIEW silver_customers_transformed_view
AS
SELECT *
FROM live.silver_customers_transformed;


---------------- ACCOUNTS & TRANSACTIONS ----------------

CREATE STREAMING LIVE TABLE silver_accounts_transactions_transformed
COMMENT 'Transformed Data'
AS
SELECT
    a.*,
    CASE
        WHEN UPPER(txn_channel) IN ('ATM', 'BRANCH') THEN 'PHYSICAL'
        ELSE 'DIGITAL'
    END AS channel_type,
    CASE
        WHEN UPPER(txn_type) = 'CREDIT' THEN 'IN'
        ELSE 'OUT'
    END AS txn_direction,
    YEAR(txn_date) AS txn_year,
    MONTH(txn_date) AS txn_month,
    DAYOFWEEK(txn_date) AS txn_dayofweek,
    CURRENT_TIMESTAMP() AS acc_transformation_date
FROM STREAM(live.bronze_accounts_transaction_ingestion_cleaned) a;


-- SCD 2

CREATE STREAMING LIVE TABLE silver_accounts_transactions_transformed_scd2;

CREATE FLOW silver_accounts_transactions_transformed_scd2_flow
AS AUTO CDC INTO
    live.silver_accounts_transactions_transformed_scd2
FROM STREAM(live.silver_accounts_transactions_transformed)
KEYS(txn_id)
SEQUENCE BY acc_transformation_date
COLUMNS * EXCEPT (acc_transformation_date)
STORED AS SCD TYPE 2;


-- View

CREATE OR REFRESH LIVE VIEW silver_accounts_transactions_transformed_view
AS
SELECT *
FROM live.silver_accounts_transactions_transformed;
