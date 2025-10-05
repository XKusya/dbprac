-- Задача - вывести результаты финального стола в турнире Celebrity Poker Tour 2025
-- Может использоваться в случаях, когда нужны конкретные результаты конкретных игр,
-- например для букмекерских контор или просто для людей, которым интересно
SELECT MR.place, A.name AS player, MR.result
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

-- Задача - показать всех спортсменов, зарегистрированных на завершённые мероприяти, включая название мероприятия и статус оплаты.
-- Может быть полезным для отчётности о проведённых мероприятиях для организаторов,
-- а также для мониторинга работоспособности сервиса для разработчиков в тестах
SELECT
    A.name AS athlet_name,
    S.name AS series,
    E.name AS event,
    M.name AS matchup,
    D.name AS discipline,
    AR.payment_status
FROM
    "Athlet" A
    JOIN "AthletRegistration" AR ON AR.athlet_id = A.id
    JOIN "Matchup" M ON M.id = AR.matchup_id
    JOIN "Event" E ON E.id = M.event_id
    JOIN "Discipline" D ON D.id = E.discipline_id
    JOIN "Series" S ON S.id = E.series_id
WHERE
    E.status = 'Finished'


SELECT
    T.name AS team,
    T.country,
    E.name AS event
FROM
    "Team" T
    JOIN "TeamRegistration" TR ON TR.team_id = T.id
    JOIN "Matchup" M ON M.id = TR.matchup_id
    JOIN "Event" E ON E.id = M.event_id
    JOIN "Discipline" D ON D.id = E.discipline_id
WHERE
    D.name = 'Formula 1';

-- Задача - Вывести общее количество зарегистрированных индивидуальных участников и команд, 
-- средний статус оплаты (в условных единицах) по завершённым событиям.
-- Может быть полезным оценки популярности дисциплин и их планирования новых мероприятих по ним
SELECT
    D.name AS discipline,
    count(AR.id) AS count_athlet_registrations,
    count(TR.id) AS count_team_registrations,
    avg(
        CASE AR.payment_status
            WHEN 'Paid'      THEN 1.0
            WHEN 'Pending'   THEN 0.5
            WHEN 'Refunded'  THEN 0.2
            ELSE 0.0
        END
    ) AS avg_payment_score
FROM
    "Discipline" D
    JOIN "Event" E ON E.discipline_id = D.id
    LEFT JOIN "Matchup" M ON M.event_id = E.id
    LEFT JOIN "AthletRegistration" AR ON AR.matchup_id = M.id AND E.status = 'Finished'
    LEFT JOIN "TeamRegistration" TR ON TR.matchup_id = M.id AND E.status = 'Finished'
GROUP BY
    D.id
ORDER BY
    count_athlet_registrations DESC,
    count_team_registrations DESC;