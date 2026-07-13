CREATE OR REFRESH STREAMING LIVE TABLE bronze_customers_ingestion_cleaned
(
CONSTRAINT valid_customer_id EXPECT (customer_id IS NOT NULL) ON VIOLATION FAIL UPDATE,
CONSTRAINT valid_name EXPECT (name IS NOT NULL) ON VIOLATION DROP ROW,
CONSTRAINT valid_dob EXPECT (dob IS NOT NULL) ON VIOLATION DROP ROW,
CONSTRAINT valid_city EXPECT (city IS NOT NULL) ON VIOLATION DROP ROW,
CONSTRAINT valid_join_date EXPECT (join_date IS NOT NULL) ON VIOLATION DROP ROW,
CONSTRAINT valid_email EXPECT (email IS NOT NULL AND email RLIKE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') ON VIOLATION DROP ROW,
CONSTRAINT valid_phone EXPECT (phone_number IS NOT NULL) ON VIOLATION DROP ROW,
CONSTRAINT valid_channel EXPECT (preferred_channel IS NOT NULL) ON VIOLATION DROP ROW,
CONSTRAINT valid_occupation EXPECT (occupation IS NOT NULL) ON VIOLATION DROP ROW,
CONSTRAINT valid_income_range EXPECT (income_range IS NOT NULL) ON VIOLATION DROP ROW,
CONSTRAINT valid_risk_segment EXPECT (risk_segment IS NOT NULL) ON VIOLATION DROP ROW,
CONSTRAINT valid_gender EXPECT (gender IS NOT NULL),
CONSTRAINT valid_status EXPECT (status IS NOT NULL)
)
COMMENT 'cleaned customers data'
TBLPROPERTIES ('quality' = 'bronze')
AS
SELECT
    CAST(customer_id AS BIGINT) AS customer_id,
    UPPER(name) AS name,
    CASE
        WHEN UPPER(gender) = 'M' THEN 'MALE'
        WHEN UPPER(gender) = 'F' THEN 'FEMALE'
        ELSE 'UNKNOWN'
    END AS gender,
    UPPER(city) AS city,
    CAST(join_date AS DATE) AS join_date,
    CAST(dob AS DATE) AS dob,
    LOWER(CAST(email AS STRING)) AS email,
    CASE
        WHEN status IS NULL OR TRIM(status) = '' THEN 'UNKNOWN'
        ELSE UPPER(status)
    END AS status,
    CAST(phone_number AS STRING) AS phone_number,
    UPPER(preferred_channel) AS preferred_channel,
    UPPER(occupation) AS occupation,
    UPPER(income_range) AS income_range,
    UPPER(risk_segment) AS risk_segment,
    CAST(FROM_UNIXTIME(UNIX_TIMESTAMP()) AS TIMESTAMP) AS ingestion_timestamp
FROM STREAM(landing_customers_incremental);