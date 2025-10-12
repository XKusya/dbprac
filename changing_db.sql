-- Организатор захотел перенести начало турнира по хоккею на день позже,
-- но по неосторожности перепутал день начала с днём конца
-- Благодаря констрейнту check_date не получилось так сделать
UPDATE "Series"
SET
    start_date = end_date + 1
WHERE
    name = 'International Hockey League'

-- правильная версия запроса
UPDATE "Series"
SET
    start_date = start_date + 1
WHERE
    name = 'International Hockey League'

-- CS:GO обновилась, надо поменять название киберспортивной дисциплины
UPDATE "Discipline"
SET
    name = 'Counter-Strike 2'
WHERE
    name = 'CS:GO';

-- организатор передумал проводить мероприятие
DELETE FROM "Series" WHERE name = 'American Baseball Classic'

DELETE FROM "MatchupResult"
WHERE
    id = (
        SELECT id
        FROM "Athlet"
        WHERE
            name = 'Lionel Messi'
    )
    AND result = '5000 chips'

DELETE FROM "MatchupResult"
WHERE
    id = (
        SELECT id
        FROM "Athlet"
        WHERE
            name = 'Johannes Thingnes Bø'
    )
    AND result = '15000 chips'




INSERT INTO "Team" ("name", "country") 
VALUES ('Rust-eze Racing Team', 'USA');

INSERT INTO "TeamMember" ("athlete_id", "team_id", "role")
SELECT 
    a.id,
    (SELECT id FROM "Team" WHERE name = 'Rust-eze Racing Team'),
    'Driver'
FROM "Athlet" a
WHERE a.name IN (
    'Lightning McQueen',
    'Miguel Camino',
    'Nigel Gearsley'
);

SELECT 
    t.name as team_name,
    a.name as athlete_name,
    tm.role
FROM "Team" t
JOIN "TeamMember" tm ON t.id = tm.team_id
JOIN "Athlet" a ON tm.athlete_id = a.id
WHERE t.name = 'Rust-eze Racing Team';

INSERT INTO "Team" ("name", "country") 
VALUES ('British Racing Team', 'UK');


INSERT INTO "TeamMember" ("athlete_id", "team_id", "role")
SELECT 
    a.id,
    (SELECT id FROM "Team" WHERE name = 'British Racing Team'),
    'Driver'
FROM "Athlet" a
WHERE a.name = 'Lewis Hamilton';

SELECT * FROM "Athlet" WHERE name = 'Lewis Hamilton'

UPDATE "TeamMember"
SET team_id = (SELECT id FROM "Team" WHERE name = 'British Racing Team')
WHERE athlete_id = (SELECT id FROM "Athlet" WHERE name = 'Nigel Gearsley')
  AND team_id = (SELECT id FROM "Team" WHERE name = 'Rust-eze Racing Team');


SELECT 
    t.name as team_name,
    a.name as athlete_name,
    tm.role
FROM "Team" t
JOIN "TeamMember" tm ON t.id = tm.team_id
JOIN "Athlet" a ON tm.athlete_id = a.id
WHERE t.name = 'British Racing Team';

