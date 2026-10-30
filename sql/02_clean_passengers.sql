-- Part 3: TRANSFORMATION. All cleaning happens here, in SQL.
DROP TABLE IF EXISTS clean_passengers;

CREATE TABLE clean_passengers AS
WITH port_mode AS (                -- most common embarked value
    SELECT embarked_port AS mode_port
    FROM stg_titanic
    WHERE embarked_port IS NOT NULL
    GROUP BY embarked_port
    ORDER BY COUNT(*) DESC, embarked_port
    LIMIT 1
),
filled AS (
    SELECT
        s.passenger_id,
        s.survived,
        s.passenger_class,
        s.sex                                            AS sex_text,
        -- missing age -> average age of same class + same sex
        COALESCE(
            s.age,
            ROUND(AVG(s.age) OVER (PARTITION BY s.passenger_class, s.sex), 2)
        )                                                AS age,
        (s.age IS NULL)                                  AS age_was_imputed,
        s.siblings_spouses_aboard,
        s.parents_children_aboard,
        s.fare,
        COALESCE(s.embarked_port, p.mode_port)           AS embarked_port,
        s.ticket_class,
        s.passenger_type,
        s.is_adult_male,
        s.survival_status,
        s.batch_id,
        s.load_timestamp
        -- deck and embark_town are intentionally NOT selected (dropped)
        -- is_alone_original is replaced by the recomputed is_alone below
    FROM stg_titanic s
    CROSS JOIN port_mode p
)
SELECT
    passenger_id,
    survived,
    passenger_class,
    CASE sex_text WHEN 'male' THEN 0 WHEN 'female' THEN 1 END   AS sex,   -- male=0, female=1
    age,
    age_was_imputed,
    CASE
        WHEN age < 13 THEN 'Child'
        WHEN age < 20 THEN 'Teen'
        WHEN age < 60 THEN 'Adult'
        ELSE 'Senior'
    END                                                          AS age_group,
    siblings_spouses_aboard,
    parents_children_aboard,
    siblings_spouses_aboard + parents_children_aboard + 1        AS family_size,
    CASE WHEN siblings_spouses_aboard + parents_children_aboard + 1 = 1
         THEN 1 ELSE 0 END                                       AS is_alone,
    fare,
    CASE NTILE(4) OVER (ORDER BY fare, passenger_id)
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'High'
        WHEN 4 THEN 'Premium'
    END                                                          AS fare_category,
    embarked_port,
    ticket_class,
    passenger_type,
    is_adult_male,
    survival_status,
    batch_id,
    load_timestamp
FROM filled;

ALTER TABLE clean_passengers ADD PRIMARY KEY (passenger_id);
