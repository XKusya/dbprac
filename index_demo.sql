
-- запрос к одной таблице
EXPLAIN (ANALYZE)
SELECT
    count(*)
FROM
    Performance
WHERE
    prize_won = '1000.00'::MONEY
    AND has_won = TRUE
    AND registration_fee > '50.00'::MONEY;

CREATE INDEX pf_prize_won_idx ON performance(prize_won);
DROP INDEX pf_prize_won_idx;



-- Запрос с JOIN'ами + Фильтр по JSON
EXPLAIN (ANALYZE)
SELECT
    P.name AS participant_name,
    C.series
FROM
    Performance PF
JOIN
    Participant P ON PF.participant_id = P.id
JOIN
    Competition C ON PF.competition_id = C.id
JOIN
    Date D ON PF.date_id = D.id
JOIN
    Outcome O ON PF.outcome_id = O.id
WHERE
    P.meta @> '{"type": "Athlet"}'::jsonb
    AND O.outcome_status = 'Winner'
    AND D.year = 2025 
    AND PF.has_won = TRUE
;

CREATE INDEX participant_type_idx ON Participant USING GIN (
    (meta -> 'type')
);

-- CREATE INDEX date_year_idx ON Date (year);

-- CREATE INDEX outcome_status_idx ON Outcome (outcome_status);

/* 
CREATE INDEX pf_optimized_idx ON Performance (
    date_id,          
    outcome_id,       
    participant_id
);
 */
DROP INDEX participant_type_idx;
DROP INDEX pf_optimized_idx;
DROP INDEX date_year_idx;
DROP INDEX outcome_status_idx;



-- Фильтр по массиву
EXPLAIN (ANALYZE)
SELECT
    PF.performance_id,
    D.date,
    PF.final_score_value
FROM
    Performance PF
JOIN
    Date D ON PF.date_id = D.id
WHERE
    ARRAY['World Series 2025']::VARCHAR(255)[] <@ D.active_competitions
;

CREATE INDEX test_idx ON test_table(a, b, c);


CREATE INDEX active_competitions_idx ON Date USING GIN(active_competitions);
DROP INDEX active_competitions_idx;



EXPLAIN ANALYZE
SELECT
    C.series,
    C.event,
    C.venue,
    C.review
FROM
    Competition C
JOIN
    Performance P ON P.competition_id = C.id
JOIN
    Date D ON D.id = P.date_id
WHERE
    to_tsvector('english', C.review) 
        @@ plainto_tsquery('english', 'outstanding prestigious world-class');


CREATE INDEX rev_idx ON Competition USING GIN ( to_tsvector('english', review) );


UPDATE pg_index SET indisvalid = true WHERE indexrelid = 'rev_idx'::regclass;