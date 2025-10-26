SELECT
    P.country,
    SUM(F.prize_won) AS total_prize_money
FROM
    Performance F
JOIN
    Participant P ON F.participant_id = P.id
WHERE
    F.date_id >= 20250101
    AND P.is_team = TRUE
GROUP BY
    P.country
ORDER BY
    total_prize_money DESC
LIMIT 100;

SELECT
    D.year,
    D.quarter,
    AVG(F.prize_won::NUMERIC) AS avg_prize_per_quarter
FROM
    Performance F
JOIN
    Date D ON F.date_id = D.id
JOIN
    Competition C ON F.competition_id = C.id
WHERE
    C.series = 'Opening Series 2023'
GROUP BY
    D.year, D.quarter
ORDER BY
    D.year, D.quarter;


SELECT
    C.series,
    C.event,
    C.venue
FROM
    Competition C
WHERE
    C.venue LIKE '%Indoor%' OR C.venue LIKE '%Stadium%';


SELECT
    P.is_team,
    COUNT(*) AS total_performances,
    SUM(CASE WHEN F.has_won THEN 1 ELSE 0 END) AS total_wins,
    (SUM(CASE WHEN F.has_won THEN 1 ELSE 0 END)::NUMERIC / COUNT(*)) * 100 AS win_rate_percent
FROM
    Performance F
JOIN
    Participant P ON F.participant_id = P.id
GROUP BY
    P.is_team
LIMIT 10;

SELECT
    P.country,
    COUNT(*) AS disq_count
FROM
    Performance F
JOIN
    Participant P ON F.participant_id = P.id
JOIN
    Outcome O ON F.outcome_id = O.id
WHERE
    O.outcome_status = 'Disqualified'
GROUP BY
    P.country
ORDER BY
    disq_count DESC
LIMIT 10;

SELECT count(*) FROM performance;

SELECT
    P.name,
    P.country,
    COUNT(*) AS wins
FROM
    Performance F
JOIN
    Participant P ON F.participant_id = P.id
WHERE
    P.is_team = TRUE
    AND F.has_won = TRUE
GROUP BY
    P.id, P.name, P.country
ORDER BY
    wins DESC
LIMIT 20;