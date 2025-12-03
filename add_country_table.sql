-- Active: 1764616324464@@127.0.0.1@5432@sports
-- Задача: нужно, не потеряв данные и не уронив приложение, которое работает с базой данных,
-- сделать "справочник" стран. "справочник" это просто таблица со странами.
-- Вместо поля country у участников (Athlet, Team) добавить поле country_id,
-- которое бы указывало на соответсвующую запись в таблице со странами

BEGIN;

CREATE TABLE "Country" (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

INSERT INTO
    "Country" (name) (
        SELECT DISTINCT
            country
        FROM "Athlet"
        WHERE
            country IS NOT NULL
    )
UNION
(
    SELECT DISTINCT
        country
    FROM "Team"
    WHERE
        country IS NOT NULL
) ON CONFLICT (name) DO NOTHING;

ALTER TABLE "Athlet" ADD COLUMN country_id INT;
ALTER TABLE "Team" ADD COLUMN country_id INT;

UPDATE "Athlet" p
SET
    country_id = c.id
FROM "Country" c
WHERE
    p.country = c.name;

UPDATE "Team" p
SET
    country_id = c.id
FROM "Country" c
WHERE
    p.country = c.name;

ALTER TABLE "Athlet" RENAME TO "Athlet_real";
ALTER TABLE "Team" RENAME TO "Team_real";

CREATE VIEW "Athlet" AS
SELECT ar.id, ar.name, ar.date_of_birth, c.name AS country, ar.email, ar.password_hash
FROM "Athlet_real" ar
    JOIN "Country" c ON ar.country_id = c.id;

CREATE VIEW "Team" AS
SELECT tr.id, tr.name, c.name AS country
FROM "Team_real" tr
    JOIN "Country" c ON tr.country_id = c.id;


CREATE OR REPLACE FUNCTION translate_operations_on_athlet_team()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.country NOT IN (SELECT DISTINCT name FROM "Country")) THEN 
        INSERT INTO "Country" (name) VALUES (NEW.country);
    END IF;
        

    CASE TG_OP
        WHEN 'INSERT' THEN
            IF TG_TABLE_NAME = 'Athlet' THEN
                INSERT INTO "Athlet_real" (
                    name,
                    date_of_birth,
                    email,
                    password_hash,
                    country_id
                ) VALUES (
                    NEW.name,
                    NEW.date_of_birth,
                    NEW.email,
                    NEW.password_hash,
                    (SELECT id FROM "Country" WHERE name = NEW.country)
                );

            ELSIF TG_TABLE_NAME = 'Team' THEN
                INSERT INTO "Team_real" (
                    name,
                    country_id
                ) VALUES (
                    NEW.name,
                    (SELECT id FROM "Country" WHERE name = NEW.country)
                );
            END IF;

        WHEN 'UPDATE' THEN
            IF TG_TABLE_NAME = 'Athlet' THEN
                UPDATE "Athlet_real"
                SET
                    name = NEW.name,
                    date_of_birth = NEW.date_of_birth,
                    email = NEW.email,
                    password_hash = NEW.password_hash,
                    country_id = (SELECT id FROM "Country" WHERE name = NEW.country)
                WHERE id = OLD.id;  

            ELSIF TG_TABLE_NAME = 'Team' THEN
                UPDATE "Team_real"
                SET
                    name = NEW.name,
                    country_id = (SELECT id FROM "Country" WHERE name = NEW.country)
                WHERE id = OLD.id;

            END IF;

        WHEN 'DELETE' THEN
            IF TG_TABLE_NAME = 'Athlet' THEN
                DELETE FROM "Athlet_real" WHERE id = OLD.id;

            ELSIF TG_TABLE_NAME = 'Team' THEN
                DELETE FROM "Team_real" WHERE id = OLD.id;

            END IF;

    END CASE;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER insert_update_delete_on_athlet
INSTEAD OF INSERT OR UPDATE OR DELETE ON "Athlet"
FOR EACH ROW
EXECUTE FUNCTION translate_operations_on_athlet_team();

CREATE OR REPLACE TRIGGER insert_update_delete_on_athlet
INSTEAD OF INSERT OR UPDATE OR DELETE ON "Team"
FOR EACH ROW
EXECUTE FUNCTION translate_operations_on_athlet_team();


ALTER TABLE "Athlet_real" DROP COLUMN country;
ALTER TABLE "Team_real" DROP COLUMN country;

COMMIT;




INSERT INTO "Athlet" (name, date_of_birth, country, email, password_hash) VALUES (
    'Jackson Storm',
    '1991-08-10',
    'USA',
    'storm@gmail.com',
    'hash_storm'
)

INSERT INTO "Athlet" (name, date_of_birth, country, email, password_hash) VALUES (
    'Cruz Ramirez',
    '1991-08-10',
    'USA',
    'ramirez@gmail.com',
    'hash_ramirez'
)


INSERT INTO "Athlet" (name, date_of_birth, country, email, password_hash) VALUES (
    'Hudson Hornet',
    '1991-08-10',
    'USA',
    'hudson@gmail.com',
    'hash_hudson'
)


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

INSERT INTO "Team" ("name", "country") 
VALUES ('British Racing Team', 'UK');


INSERT INTO "TeamMember" ("athlete_id", "team_id", "role")
SELECT 
    a.id,
    (SELECT id FROM "Team" WHERE name = 'British Racing Team'),
    'Driver'
FROM "Athlet" a
WHERE a.name = 'Lewis Hamilton';

UPDATE "TeamMember"
SET team_id = (SELECT id FROM "Team" WHERE name = 'British Racing Team')
WHERE athlete_id = (SELECT id FROM "Athlet" WHERE name = 'Nigel Gearsley')
  AND team_id = (SELECT id FROM "Team" WHERE name = 'Rust-eze Racing Team');


INSERT INTO "Athlet" (name, date_of_birth, country, email, password_hash) VALUES (
    'Jack not storm',
    '1991-08-10',
    'USL',
    'stom@gmail.com',
    'hash_storm'
);

UPDATE "Athlet"
SET name = 'Jackie Chang', country = 'China', email = 'jackie@gmail.com', password_hash = 'jackie_hash'
WHERE id = (SELECT id FROM "Athlet" WHERE name = 'Jack not storm')

DELETE FROM "Athlet" WHERE id = (SELECT id FROM "Athlet" WHERE name = 'Jackie Chang')