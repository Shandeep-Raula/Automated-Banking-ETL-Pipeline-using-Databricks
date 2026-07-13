CREATE OR REFRESH STREAMING LIVE TABLE bronze_accounts_transaction_ingestion_cleaned
(
CONSTRAINT valid_account_id EXPECT(account_id IS NOT NULL) ON VIOLATION FAIL UPDATE,
CONSTRAINT valid_customer_id EXPECT(customer_id IS NOT NULL) ON VIOLATION DROP ROW,
CONSTRAINT valid_account_type EXPECT(UPPER(account_type) IN('LOAN','SAVINGS','CURRENT')) ON VIOLATION DROP ROW,
CONSTRAINT valid_balance EXPECT(balance IS NOT NULL) ON VIOLATION DROP ROW,
CONSTRAINT valid_txn_id EXPECT(txn_id IS NOT NULL) ON VIOLATION DROP ROW,
CONSTRAINT valid_txn_date EXPECT(txn_date IS NOT NULL) ON VIOLATION DROP ROW,
CONSTRAINT valid_type EXPECT(txn_type IS NOT NULL) ON VIOLATION DROP ROW,
CONSTRAINT valid_amount EXPECT(txn_amount IS NOT NULL) ON VIOLATION DROP ROW,
CONSTRAINT valid_txn_channel EXPECT(txn_channel IS NOT NULL) ON VIOLATION DROP ROW
)
COMMENT 'cleaned accounts-transactions data'
TBLPROPERTIES ('quality'='bronze')
AS
SELECT 
CAST(account_id AS BIGINT) AS account_id,
CAST(customer_id AS BIGINT) AS customer_id,
UPPER(account_type) AS account_type,
CAST(balance AS DOUBLE) AS balance,
CAST(txn_id AS BIGINT) AS txn_id,
CAST(txn_date AS DATE) AS txn_date,
CASE
    WHEN UPPER(txn_type) IN('DEBITT','DEBIT') THEN 'DEBIT'
    WHEN UPPER(txn_type) IN('CREDIT','CREDIIT') THEN 'CREDIT'
    ELSE 'UNKNOWN'
END AS txn_type,
CAST(txn_amount AS DOUBLE) AS txn_amount,
UPPER(txn_channel) AS txn_channel
FROM STREAM(LIVE.landing_accounts_transactions_incremental);