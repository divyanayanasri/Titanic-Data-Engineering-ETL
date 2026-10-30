-- Part 4: ANALYTICS views
CREATE OR REPLACE VIEW v_survival_by_class_sex AS
SELECT
    passenger_class,
    CASE sex WHEN 0 THEN 'male' ELSE 'female' END   AS sex,
    COUNT(*)                                        AS passengers,
    SUM(survived)                                   AS survivors,
    ROUND(AVG(survived) * 100, 2)                   AS survival_rate_pct
FROM clean_passengers
GROUP BY passenger_class, sex
ORDER BY passenger_class, sex;

CREATE OR REPLACE VIEW v_survival_by_age_group AS
SELECT
    age_group,
    COUNT(*)                                        AS passengers,
    SUM(survived)                                   AS survivors,
    ROUND(AVG(survived) * 100, 2)                   AS survival_rate_pct
FROM clean_passengers
GROUP BY age_group
ORDER BY FIELD(age_group, 'Child', 'Teen', 'Adult', 'Senior');

CREATE OR REPLACE VIEW v_top3_fares_per_class AS
SELECT passenger_class, fare_rank, passenger_id, fare, sex, age, survived
FROM (
    SELECT
        passenger_class, passenger_id, fare, sex, age, survived,
        ROW_NUMBER() OVER (PARTITION BY passenger_class
                           ORDER BY fare DESC, passenger_id) AS fare_rank
    FROM clean_passengers
) ranked
WHERE fare_rank <= 3
ORDER BY passenger_class, fare_rank;
