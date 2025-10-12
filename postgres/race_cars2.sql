-- Active: 1754635811164@@127.0.0.1@5432@sports@public
INSERT INTO "Athlet" (
        "name",
        "date_of_birth",
        "country",
        "email",
        "password_hash"
    )
VALUES (
        'Francesco Bernoulli',
        '1998-07-14',
        'Italy',
        'francesco@scuderia.it',
        'hash_francesco'
    ),
    (
        'Miguel Camino',
        '1996-09-25',
        'Spain',
        'miguel@spainracing.es',
        'hash_miguel'
    ),
    (
        'Raoul ÇaRoule',
        '1994-05-18',
        'France',
        'raoul@parismotors.fr',
        'hash_raoul'
    ),
    (
        'Shu Todoroki',
        '2000-03-22',
        'Japan',
        'shu@tokyoracing.jp',
        'hash_shu'
    ),
    (
        'Carla Veloso',
        '1997-11-30',
        'Brazil',
        'carla@brasilia-motors.br',
        'hash_carla'
    ),
    (
        'Nigel Gearsley',
        '1995-08-12',
        'UK',
        'nigel@britishmotors.uk',
        'hash_nigel'
    ),
    (
        'Rip Clutchgoneski',
        '1999-01-01',
        'Republic of New Rearendia',
        'rip@gmail.com',
        'rip_hash'
    ),
    (
        'Jeff Corvette',
        '1993-12-03',
        'USA',
        'jeffcorvette@gmail.com',
        'hash_jeff'
    ),
    (
        'Lightning McQueen',
        '1999-01-01',
        'USA',
        'mcqueen@rusteze.com',
        'hash_mcqueen'
    );

INSERT INTO "Planner" (
        "organization_name",
        "contact_person",
        "email",
        "password_hash"
    )
VALUES (
        'Allinol',
        'Sir Miles Axlerod',
        'axlerod@gmail.com',
        'axlerod_hash'
    );

INSERT INTO "Discipline" ("name", "unit", "result_format")
VALUES ('Auto Racing', 'time/laps', 'place/time');

INSERT INTO "Series" ("name", "start_date", "end_date")
VALUES (
        'World Grand Prix',
        '2011-06-24',
        '2011-07-24'
    );
    
INSERT INTO "Event" (
        "series_id",
        "discipline_id",
        "name",
        "start_date",
        "end_date",
        "status",
        "venue",
        "team_size_min",
        "team_size_max"
    )
VALUES (
        (
            SELECT id
            FROM "Series"
            WHERE name = 'World Grand Prix'
        ),
        (
            SELECT id
            FROM "Discipline"
            WHERE name = 'Auto Racing'
        ),
        'World Grand Prix',
        (
            SELECT start_date
            FROM "Series"
            WHERE name = 'World Grand Prix'
        ),
        (
            SELECT end_date
            FROM "Series"
            WHERE name = 'World Grand Prix'
        ),
        'Finished',
        '',
        1,
        1
    );

INSERT INTO "Matchup" ("event_id", "name", "start_date", "end_date", "status")
VALUES (
        (
            SELECT id
            FROM "Event"
            WHERE name = 'World Grand Prix'
        ),
        'Race in Tokyo',
        (
            SELECT start_date
            FROM "Series"
            WHERE name = 'World Grand Prix'
        ) + 1,
        (
            SELECT start_date
            FROM "Series"
            WHERE name = 'World Grand Prix'
        ) + 1,
        'Finished'
    ),
    (
        (
            SELECT id
            FROM "Event"
            WHERE name = 'World Grand Prix'
        ),
        'Race in Porta Corsa',
        (
            SELECT start_date
            FROM "Series"
            WHERE name = 'World Grand Prix'
        ) + 7,
        (
            SELECT start_date
            FROM "Series"
            WHERE name = 'World Grand Prix'
        ) + 7,
        'Finished'
    ),
    (
        (
            SELECT id
            FROM "Event"
            WHERE name = 'World Grand Prix'
        ),
        'Race in London',
        (
            SELECT start_date
            FROM "Series"
            WHERE name = 'World Grand Prix'
        ) + 14,
        (
            SELECT start_date
            FROM "Series"
            WHERE name = 'World Grand Prix'
        ) + 14,
        'Finished'
    );


INSERT INTO "AthletRegistration" ("athlet_id", "matchup_id", "payment_status", "status")
SELECT A.id, M.id, 'Paid', 'Confirmed'
FROM "Athlet" A, "Matchup" M
WHERE A.name IN (
    'Lightning McQueen', 'Francesco Bernoulli', 'Carla Veloso',
    'Shu Todoroki', 'Nigel Gearsley', 'Lewis Hamilton',
    'Jeff Corvette', 'Raoul ÇaRoule', 'Rip Clutchgoneski'
)
AND M.name = 'Race in Tokyo';

INSERT INTO "AthletRegistration" ("athlet_id", "matchup_id", "payment_status", "status")
SELECT A.id, M.id, 'Paid', 'Confirmed'
FROM "Athlet" A, "Matchup" M
WHERE A.name IN (
    'Lightning McQueen', 'Francesco Bernoulli', 'Carla Veloso',
    'Nigel Gearsley', 'Lewis Hamilton', 'Jeff Corvette',
    'Miguel Camino', 'Raoul ÇaRoule', 'Rip Clutchgoneski'
)
AND M.name = 'Race in Porta Corsa';

INSERT INTO "AthletRegistration" ("athlet_id", "matchup_id", "payment_status", "status")
SELECT A.id, M.id, 'Paid', 'Confirmed'
FROM "Athlet" A, "Matchup" M
WHERE A.name IN (
    'Lightning McQueen', 'Francesco Bernoulli', 'Carla Veloso',
    'Shu Todoroki', 'Nigel Gearsley', 'Lewis Hamilton',
    'Jeff Corvette', 'Miguel Camino', 'Raoul ÇaRoule', 'Rip Clutchgoneski'
)
AND M.name = 'Race in London';

INSERT INTO "MatchupResult" ("matchup_id", "athlet_registration_id", "result", "place", "status", "outcome")
SELECT
    m.id as matchup_id,
    ar.id as athlet_registration_id,
    CASE a.name
        WHEN 'Francesco Bernoulli' THEN '1:22.45'
        WHEN 'Lightning McQueen' THEN '1:22.80'
        WHEN 'Carla Veloso' THEN '1:23.10'
        WHEN 'Shu Todoroki' THEN '1:23.50'
        WHEN 'Nigel Gearsley' THEN '1:24.00'  
        WHEN 'Lewis Hamilton' THEN '1:24.30'  
        WHEN 'Jeff Corvette' THEN 'DNF'
        WHEN 'Raoul ÇaRoule' THEN '1:25.10'
        WHEN 'Rip Clutchgoneski' THEN 'DNF'
    END,
    CASE a.name
        WHEN 'Francesco Bernoulli' THEN 1
        WHEN 'Lightning McQueen' THEN 2
        WHEN 'Carla Veloso' THEN 3
        WHEN 'Shu Todoroki' THEN 4
        WHEN 'Nigel Gearsley' THEN 5   
        WHEN 'Jeff Corvette' THEN 99
        WHEN 'Raoul ÇaRoule' THEN 8
        WHEN 'Rip Clutchgoneski' THEN 100
    END,
    CASE WHEN a.name IN ('Jeff Corvette', 'Rip Clutchgoneski') THEN 'Canceled'::resultstatus ELSE 'Official'::resultstatus END,
    CASE 
        WHEN a.name = 'Francesco Bernoulli' THEN 'Winner'
        WHEN a.name IN ('Jeff Corvette', 'Rip Clutchgoneski') THEN 'DNF'::outcomestatus
        ELSE 'Loser'::outcomestatus
    END
FROM "Athlet" a
JOIN "AthletRegistration" ar ON a.id = ar.athlet_id
JOIN "Matchup" m ON ar.matchup_id = m.id
WHERE m.name = 'Race in Tokyo';

INSERT INTO "MatchupResult" ("matchup_id", "athlet_registration_id", "result", "place", "status", "outcome")
SELECT
    m.id as matchup_id,
    ar.id as athlet_registration_id,
    CASE a.name
        WHEN 'Lightning McQueen' THEN '1:18.90'
        WHEN 'Francesco Bernoulli' THEN '1:19.20'
        WHEN 'Nigel Gearsley' THEN '1:20.00'
        WHEN 'Lewis Hamilton' THEN 'DNF'
        WHEN 'Jeff Corvette' THEN 'DNF'
        WHEN 'Carla Veloso' THEN 'DNF'
        WHEN 'Miguel Camino' THEN 'DNF'
        WHEN 'Raoul ÇaRoule' THEN 'DNF'
        WHEN 'Rip Clutchgoneski' THEN 'DNF'
    END,
    CASE a.name
        WHEN 'Lightning McQueen' THEN 1
        WHEN 'Francesco Bernoulli' THEN 2
        WHEN 'Jeff Corvette' THEN 101
        WHEN 'Carla Veloso' THEN 102
        WHEN 'Miguel Camino' THEN 103
        WHEN 'Raoul ÇaRoule' THEN 104
        WHEN 'Rip Clutchgoneski' THEN 105
    END,
    CASE WHEN a.name IN ('Lewis Hamilton', 'Jeff Corvette', 'Carla Veloso', 'Miguel Camino', 'Raoul ÇaRoule', 'Rip Clutchgoneski') THEN 'Canceled'::resultstatus ELSE 'Official'::resultstatus END,
    CASE 
        WHEN a.name = 'Lightning McQueen' THEN 'Winner'
        WHEN a.name IN ('Lewis Hamilton', 'Jeff Corvette', 'Carla Veloso', 'Miguel Camino', 'Raoul ÇaRoule', 'Rip Clutchgoneski') THEN 'DNF'::outcomestatus
        ELSE 'Loser'::outcomestatus
    END
FROM "Athlet" a
JOIN "AthletRegistration" ar ON a.id = ar.athlet_id
JOIN "Matchup" m ON ar.matchup_id = m.id
WHERE m.name = 'Race in Porta Corsa';

INSERT INTO "MatchupResult" ("matchup_id", "athlet_registration_id", "result", "place", "status", "outcome")
SELECT
    m.id as matchup_id,
    ar.id as athlet_registration_id,
    CASE a.name
        WHEN 'Lightning McQueen' THEN '1:15.30'
        WHEN 'Francesco Bernoulli' THEN '1:15.75'
        WHEN 'Lewis Hamilton' THEN '1:16.10'
        ELSE 'DNF'
    END,
    CASE a.name
        WHEN 'Lightning McQueen' THEN 1
        WHEN 'Francesco Bernoulli' THEN 2
    END,
    CASE WHEN a.name NOT IN ('Lightning McQueen', 'Francesco Bernoulli', 'Lewis Hamilton') THEN 'Canceled'::resultstatus ELSE 'Official'::resultstatus END,
    CASE 
        WHEN a.name = 'Lightning McQueen' THEN 'Winner'
        WHEN a.name IN ('Carla Veloso', 'Shu Todoroki', 'Nigel Gearsley', 'Jeff Corvette', 'Miguel Camino', 'Raoul ÇaRoule', 'Rip Clutchgoneski') THEN 'DNF'::outcomestatus
        ELSE 'Loser'::outcomestatus
    END
FROM "Athlet" a
JOIN "AthletRegistration" ar ON a.id = ar.athlet_id
JOIN "Matchup" m ON ar.matchup_id = m.id
WHERE m.name = 'Race in London';