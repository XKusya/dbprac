-- зарегистрировали Макса Ферстаппена на гонку
INSERT INTO
    "AthletRegistration" (
        "athlet_id",
        "matchup_id",
        "payment_status",
        "status"
    )
VALUES (
        (
            SELECT A.id
            FROM "Athlet" A
            WHERE
                A.name = 'Max Verstappen'
        ), -- athlet_id
        (
            SELECT M.id 
            FROM
                "Series" S
                JOIN "Event" E ON S.id = E.series_id
                JOIN "Matchup" M ON E.id = M.event_id
                JOIN "Discipline" D ON E.discipline_id = D.id
            WHERE
                S.name = 'F1 World Championship 2025'
                AND E.name = 'Monaco Grand Prix'
                AND M.name = 'Race Day'
                AND D.name = 'Formula 1'
        ), -- matchup_id
        'Pending', -- payment_status
        'PendingApproval' -- status
    );