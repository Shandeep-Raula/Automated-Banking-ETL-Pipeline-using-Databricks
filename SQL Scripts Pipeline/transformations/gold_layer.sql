CREATE LIVE TABLE gold_cust_acc_trans_mv
COMMENT 'Customer Account Transactions Materialized View'
AS
SELECT
    c.customer_id,
    c.name,
    c.dob,
    c.gender,
    c.city,
    c.join_date,
    c.status,
    c.email,
    c.phone_number,
    c.preferred_channel,
    c.occupation,
    c.income_range,
    c.risk_segment,
    c.customer_age,
    c.tenure_days,
    c.dob_out_of_range_flag,
    c.transformation_date,
    a.account_id,
    a.account_type,
    a.balance,
    a.txn_id,
    a.txn_date,
    a.txn_type,
    a.txn_amount,
    a.txn_channel,
    a.channel_type,
    a.txn_direction,
    a.txn_year,
    a.txn_month,
    a.txn_dayofweek,
    a.acc_transformation_date
FROM LIVE.silver_customers_transformed c
JOIN LIVE.silver_accounts_transactions_transformed a
    ON c.customer_id = a.customer_id;




CREATE LIVE TABLE gold_cust_acc_trans_agg
COMMENT 'Gold aggregated metrics per customer'
AS
SELECT
    customer_id,
    name,
    gender,
    city,
    status,
    income_range,
    risk_segment,
    customer_age,
    tenure_days,

    COUNT(DISTINCT account_id) AS accounts_count,
    COUNT(*) AS txn_count,

    SUM(
        CASE
            WHEN txn_type = 'CREDIT' THEN txn_amount
            ELSE 0.0
        END
    ) AS total_credits,

    SUM(
        CASE
            WHEN txn_type = 'DEBIT' THEN txn_amount
            ELSE 0.0
        END
    ) AS total_debits,

    AVG(txn_amount) AS avg_txn_amount,
    MIN(txn_date) AS first_txn_date,
    MAX(txn_date) AS last_txn_date,
    COUNT(txn_channel) AS channels_used

FROM LIVE.gold_cust_acc_trans_mv

GROUP BY
    customer_id,
    name,
    gender,
    city,
    status,
    income_range,
    risk_segment,
    customer_age,
    tenure_days;


