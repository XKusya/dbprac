-- Active: 1759126997707@@127.0.0.1@5432@sports@public
-- грязное чтение (невозможно в PostgreSQL)
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- 1
UPDATE "AthletRegistration"
SET
    payment_status = 'Paid'
WHERE
    id = (
        SELECT ar.id
        FROM
            "AthletRegistration" ar
            JOIN "Athlet" a ON a.id = ar.athlet_id
            JOIN "Matchup" m ON m.id = ar.matchup_id
        WHERE
            a.name = 'Neymar Jr' AND m.name = 'Final: Team A vs Team B'
    );

-- 3
COMMIT;

-- неповторяющееся чтение
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

UPDATE "AthletRegistration"
SET
    status = 'Confirmed',
    payment_status = 'Paid'
WHERE
    id = (
        SELECT ar.id
        FROM
            "AthletRegistration" ar
            JOIN "Athlet" a ON a.id = ar.athlet_id
            JOIN "Matchup" m ON m.id = ar.matchup_id
        WHERE
            a.name = 'Kylian Mbappé' m.name = 'Final: Team A vs Team B'
    );

COMMIT;

-- фантомное чтение
BEGIN;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

INSERT INTO
    "AthletRegistration" (
        "athlet_id",
        "matchup_id",
        "payment_status",
        "status"
    )
VALUES (
        (
            SELECT id
            FROM "Athlet"
            WHERE
                name = 'Magnus Carlsen'
        ),
        (
            SELECT id
            FROM "Matchup"
            WHERE
                name = 'World Chess Blitz Championship'
        ),
        'Pending',
        'Pending'
    );

COMMIT;

-- фантомное чтение и ошибка сериализации
BEGIN;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

WITH TargetPrizeFund AS (
    SELECT pf.id
    FROM "PrizeFund" pf
    JOIN "Event" e ON e.id = pf.event_id
    WHERE e.name = 'Main Event - Texas Hold''em'
)
SELECT SUM(amount) AS total_prize_amount
FROM "Prize"
WHERE prize_fund_id = (SELECT id FROM TargetPrizeFund);

UPDATE "PrizeFund"
SET total_amount = (
    SELECT SUM(amount)
    FROM "Prize"
    WHERE prize_fund_id = (SELECT id FROM TargetPrizeFund)
)
WHERE id = (SELECT id FROM TargetPrizeFund);
-- если cеанс 2 в это время тоже обновляет - возможна ошибка сериализации
COMMIT;