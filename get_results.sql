-- Задача - вывести результаты финального стола в турнире Celebrity Poker Tour 2025

-- SELECT * FROM "MatchupResult" JOIN "Athlet"

SELECT
    MR.place,
    A.name AS player,
    MR.result
FROM
    "Series" S
    JOIN "Event" E ON S.id = E.series_id
    JOIN "Matchup" M ON E.id = M.event_id
    JOIN "MatchupResult" MR ON M.id = MR.matchup_id
    JOIN "AthletRegistration" AR ON AR.id = MR.athlet_registration_id
    JOIN "Athlet" A ON A.id = AR.athlet_id
WHERE
    S.name = 'Celebrity Poker Tour 2025'
    AND M.name = 'Main Event - Final Table'
ORDER BY MR.place
LIMIT 10