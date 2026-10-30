-- Part 2: STAGING. Rename, lowercase text, cast types. raw_titanic is only read.
DROP TABLE IF EXISTS stg_titanic;

CREATE TABLE stg_titanic AS
SELECT
    CAST(row_id AS UNSIGNED)                      AS passenger_id,
    CAST(survived AS UNSIGNED)                    AS survived,
    CAST(pclass AS UNSIGNED)                      AS passenger_class,
    LOWER(NULLIF(TRIM(sex), ''))                  AS sex,
    CAST(age AS DECIMAL(5,2))                     AS age,
    CAST(sibsp AS UNSIGNED)                       AS siblings_spouses_aboard,
    CAST(parch AS UNSIGNED)                       AS parents_children_aboard,
    CAST(fare AS DECIMAL(10,4))                   AS fare,
    LOWER(NULLIF(TRIM(embarked), ''))             AS embarked_port,
    LOWER(NULLIF(TRIM(`class`), ''))              AS ticket_class,
    LOWER(NULLIF(TRIM(who), ''))                  AS passenger_type,
    CAST(adult_male AS UNSIGNED)                  AS is_adult_male,
    LOWER(NULLIF(TRIM(deck), ''))                 AS deck,
    LOWER(NULLIF(TRIM(embark_town), ''))          AS embark_town,
    LOWER(NULLIF(TRIM(alive), ''))                AS survival_status,
    CAST(alone AS UNSIGNED)                       AS is_alone_original,
    batch_id,
    load_timestamp
FROM raw_titanic;

ALTER TABLE stg_titanic ADD PRIMARY KEY (passenger_id);
