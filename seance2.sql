-- Active: 1759126997707@@127.0.0.1@5432@sports@public
-- грязное чтение (невозможно в PostgreSQL)
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- 2
SELECT payment_status
FROM "AthletRegistration"
WHERE
    id = (
        SELECT ar.id
        FROM
            "AthletRegistration" ar
            JOIN "Athlet" a ON a.id = ar.athlet_id
            JOIN "Matchup" m ON m.id = ar.matchup_id
        WHERE
            a.name = 'Neymar Jr' m.name = 'Final: Team A vs Team B'
    );

-- 4
SELECT payment_status
FROM "AthletRegistration"
WHERE
    id = (
        SELECT ar.id
        FROM
            "AthletRegistration" ar
            JOIN "Athlet" a ON a.id = ar.athlet_id
            JOIN "Matchup" m ON m.id = ar.matchup_id
        WHERE
            a.name = 'Neymar Jr' m.name = 'Final: Team A vs Team B'
    );

-- 5
COMMIT;

-- неповторяющееся чтение
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT COUNT(*) AS confirmed_registrations
FROM
    "AthletRegistration" ar
    JOIN "Matchup" m ON ar.matchup_id = m.id
    JOIN "Event" e ON m.event_id = e.id
WHERE
    e.name = 'Men''s Football Tournament'
    AND ar.status = 'Confirmed';

SELECT COUNT(*) AS confirmed_registrations
FROM
    "AthletRegistration" ar
    JOIN "Matchup" m ON ar.matchup_id = m.id
    JOIN "Event" e ON m.event_id = e.id
WHERE
    e.name = 'Men''s Football Tournament'
    AND ar.status = 'Confirmed';

COMMIT;

-- фантомное чтение
BEGIN;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT COUNT(*) AS pending_registrations
FROM
    "AthletRegistration" ar
    JOIN "Matchup" m ON ar.matchup_id = m.id
    JOIN "Event" e ON m.event_id = e.id
WHERE
    e.name = 'World Chess Blitz Championship'
    AND ar.status = 'PendingApproval';

SELECT COUNT(*) AS pending_registrations
FROM
    "AthletRegistration" ar
    JOIN "Matchup" m ON ar.matchup_id = m.id
    JOIN "Event" e ON m.event_id = e.id
WHERE
    e.name = 'World Chess Blitz Championship'
    AND ar.status = 'PendingApproval';

COMMIT;

BEGIN;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

INSERT INTO
    "Prize" (
        "prize_fund_id",
        "place",
        "amount"
    )
VALUES (
        (
            SELECT SUM(amount)
            FROM "Prize"
            WHERE
                prize_fund_id = (
                    SELECT pf.id
                    FROM "PrizeFund" pf
                        JOIN Event e ON e.id = pf.event_id
                    WHERE
                        e.name = 'Main Event - Texas Hold''em'
                )
        ),
        4,
        100000::MONEY
    );

COMMIT;