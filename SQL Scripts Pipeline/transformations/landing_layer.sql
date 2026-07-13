CREATE OR REFRESH STREAMING LIVE TABLE landing_customers_incremental
COMMENT 'Incremental ingestion from the volume-customers'
AS

SELECT *
FROM cloud_files(
    '/Volumes/dlt_bank_sql_catalog/dlt_bank_sql_schema/dlt_bank_sql_volume/customers/',
    'csv',
    map(
        'header', 'true',
        'cloudFiles.inferColumnTypes', 'true'
    )
);


CREATE OR REFRESH STREAMING LIVE TABLE landing_accounts_transactions_incremental
COMMENT 'Incremental ingestion from the volume-customers'
AS

SELECT *
FROM cloud_files(
    '/Volumes/dlt_bank_sql_catalog/dlt_bank_sql_schema/dlt_bank_sql_volume/accounts/',
    'csv',
    map(
        'header', 'true',
        'cloudFiles.inferColumnTypes', 'true'
    )
);