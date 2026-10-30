-- Part 5: DATA QUALITY. dq_results always holds the latest run.
CREATE TABLE IF NOT EXISTS dq_results (
    check_name VARCHAR(100) NOT NULL,
    status     VARCHAR(4)   NOT NULL,
    checked_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

TRUNCATE TABLE dq_results;

INSERT INTO dq_results (check_name, status, checked_at)
SELECT '01_row_count_raw_equals_clean',
       CASE WHEN (SELECT COUNT(*) FROM raw_titanic) = (SELECT COUNT(*) FROM clean_passengers)
            THEN 'PASS' ELSE 'FAIL' END,
       NOW()
UNION ALL
SELECT '02_no_nulls_in_age_embarked',
       CASE WHEN (SELECT COUNT(*) FROM clean_passengers
                  WHERE age IS NULL OR embarked_port IS NULL) = 0
            THEN 'PASS' ELSE 'FAIL' END,
       NOW()
UNION ALL
SELECT '03_no_duplicate_passengers',
       CASE WHEN (SELECT COUNT(*) FROM clean_passengers)
               = (SELECT COUNT(DISTINCT passenger_id) FROM clean_passengers)
            THEN 'PASS' ELSE 'FAIL' END,
       NOW()
UNION ALL
SELECT '04_age_between_0_and_100',
       CASE WHEN (SELECT COUNT(*) FROM clean_passengers
                  WHERE age IS NULL OR age < 0 OR age > 100) = 0
            THEN 'PASS' ELSE 'FAIL' END,
       NOW()
UNION ALL
SELECT '05_sex_only_0_or_1',
       CASE WHEN (SELECT COUNT(*) FROM clean_passengers
                  WHERE sex IS NULL OR sex NOT IN (0, 1)) = 0
            THEN 'PASS' ELSE 'FAIL' END,
       NOW();
