-- We don't need CREATE DATABASE since db is initialised in docker-compose.yml
-- CREATE DATABASE "sports";
CREATE TYPE EventStatus AS ENUM ('Preparing', 'Scheduled', 'InProgress', 'Finished', 'Canceled', 'Postponed');

CREATE TYPE PaymentStatus AS ENUM ('Pending', 'Paid', 'Failed', 'Refunded');

CREATE TYPE RegistrationStatus AS ENUM ('Confirmed', 'Registered', 'PendingApproval', 'Withdrawn', 'Disqualified');

CREATE TYPE ResultStatus AS ENUM ('Provisional', 'Official', 'Disputed', 'Canceled');

CREATE TYPE OutcomeStatus AS ENUM ('Winner', 'Loser', 'Draw', 'Eliminated', 'Retired', 'DNF');

CREATE TABLE "Planner" (
    "id" SERIAL NOT NULL,
    "organization_name" VARCHAR(255),
    "contact_person" VARCHAR(255),
    "email" VARCHAR(255),
    "password_hash" VARCHAR(255),
    PRIMARY KEY ("id")
);

CREATE TABLE "Athlet" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255),
    "date_of_birth" DATE,
    "country" VARCHAR(255),
    "email" VARCHAR(255),
    "password_hash" VARCHAR(255),
    PRIMARY KEY ("id")
);

CREATE TABLE "Team" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255),
    "country" VARCHAR(255),
    PRIMARY KEY ("id")
);

CREATE TABLE "TeamMember" (
    "athlete_id" INT NOT NULL,
    "team_id" INT NOT NULL,
    "role" VARCHAR(255),
    PRIMARY KEY ("athlete_id", "team_id"),
    FOREIGN KEY ("athlete_id") REFERENCES "Athlet" ("id") ON DELETE CASCADE,
    FOREIGN KEY ("team_id") REFERENCES "Team" ("id") ON DELETE CASCADE
);

CREATE TABLE "Discipline" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255),
    "unit" VARCHAR(255),
    "result_format" VARCHAR(255),
    PRIMARY KEY ("id")
);

CREATE TABLE "Series" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255),
    "start_date" DATE,
    "end_date" DATE,
    PRIMARY KEY ("id")
);

CREATE TABLE "Event" (
    "id" SERIAL NOT NULL,
    "series_id" INT NOT NULL,
    "discipline_id" INT NOT NULL,
    "name" VARCHAR(255),
    "start_date" DATE,
    "end_date" DATE,
    "status" EventStatus, 
    "venue" TEXT,
    "team_size_min" SMALLINT,
    "team_size_max" SMALLINT,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("series_id") REFERENCES "Series" ("id") ON DELETE CASCADE,
    FOREIGN KEY ("discipline_id") REFERENCES "Discipline" ("id") ON DELETE RESTRICT
);

CREATE TABLE "Matchup" (
    "id" SERIAL NOT NULL,
    "event_id" INT NOT NULL,
    "name" VARCHAR(255),
    "start_date" DATE,
    "end_date" DATE,
    "status" EventStatus, 
    PRIMARY KEY ("id"),
    FOREIGN KEY ("event_id") REFERENCES "Event" ("id") ON DELETE CASCADE
);

CREATE TABLE "AthletRegistration" (
    "id" SERIAL NOT NULL,
    "athlet_id" INT NOT NULL,
    "matchup_id" INT NOT NULL,
    "payment_status" PaymentStatus,
    "status" RegistrationStatus, 
    PRIMARY KEY ("id"),
    FOREIGN KEY ("athlet_id") REFERENCES "Athlet" ("id") ON DELETE CASCADE,
    FOREIGN KEY ("matchup_id") REFERENCES "Matchup" ("id") ON DELETE CASCADE
);

CREATE TABLE "TeamRegistration" (
    "id" SERIAL NOT NULL,
    "matchup_id" INT NOT NULL,
    "team_id" INT NOT NULL,
    "payment_status" PaymentStatus, 
    "status" RegistrationStatus, 
    PRIMARY KEY ("id"),
    FOREIGN KEY ("matchup_id") REFERENCES "Matchup" ("id") ON DELETE CASCADE,
    FOREIGN KEY ("team_id") REFERENCES "Team" ("id") ON DELETE CASCADE
);

CREATE TABLE "PrizeFund" (
    "id" SERIAL NOT NULL,
    "event_id" INT NOT NULL,
    "total_amount" MONEY,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("event_id") REFERENCES "Event" ("id") ON DELETE CASCADE
);

CREATE TABLE "Prize" (
    "id" SERIAL NOT NULL,
    "prize_fund_id" INT NOT NULL,
    "place" SMALLINT,
    "amount" MONEY,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("prize_fund_id") REFERENCES "PrizeFund" ("id") ON DELETE CASCADE
);

CREATE TABLE "SeriesPlanner" (
    "planner_id" INT NOT NULL,
    "series_id" INT NOT NULL,
    PRIMARY KEY ("planner_id", "series_id"),
    FOREIGN KEY ("planner_id") REFERENCES "Planner" ("id") ON DELETE CASCADE,
    FOREIGN KEY ("series_id") REFERENCES "Series" ("id") ON DELETE CASCADE
);

CREATE TABLE "MatchupResult" (
    "id" SERIAL NOT NULL,
    "matchup_id" INT NOT NULL,
    "athlet_registration_id" INT,
    "team_registration_id" INT,
    "result" VARCHAR(255),
    "place" SMALLINT,
    "status" ResultStatus, 
    "outcome" OutcomeStatus,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("matchup_id") REFERENCES "Matchup" ("id") ON DELETE CASCADE,
    FOREIGN KEY ("athlet_registration_id") REFERENCES "AthletRegistration" ("id") ON DELETE CASCADE,
    FOREIGN KEY ("team_registration_id") REFERENCES "TeamRegistration" ("id") ON DELETE CASCADE
);

ALTER TABLE "Planner"
ADD CONSTRAINT planner_email_unique UNIQUE (email);

ALTER TABLE "Athlet"
ADD CONSTRAINT athlet_email_unique UNIQUE (email);

ALTER TABLE "AthletRegistration"
ADD CONSTRAINT unique_athlet_matchup UNIQUE (athlet_id, matchup_id);

ALTER TABLE "TeamRegistration"
ADD CONSTRAINT unique_team_matchup UNIQUE (team_id, matchup_id);

ALTER TABLE "MatchupResult"
ADD CONSTRAINT unique_matchup_place UNIQUE (matchup_id, place),
ADD CONSTRAINT check_athlet_or_team CHECK (
    (athlet_registration_id IS NOT NULL AND team_registration_id IS NULL)
    OR
    (athlet_registration_id IS NULL AND team_registration_id IS NOT NULL)
);

ALTER TABLE "Series"
ADD CONSTRAINT check_date CHECK (start_date <= end_date);

ALTER TABLE "Event"
ADD CONSTRAINT check_date CHECK (start_date <= end_date);

ALTER TABLE "Matchup"
ADD CONSTRAINT check_date CHECK (start_date <= end_date);

INSERT INTO "Planner" ("organization_name", "contact_person", "email", "password_hash") VALUES
('Global Sports Federation', 'John Doe', 'john.doe@gsf.com', 'hash1'),
('World Poker Series Org', 'Jane Smith', 'jane.smith@wpso.com', 'hash2'),
('Cyber Champions League', 'Alexey Ivanov', 'alex.i@ccl.com', 'hash3'),
('International Chess Union', 'Magnus Carlsen', 'contact@icu.com', 'hash4'),
('Major League Baseball Org', 'Mike Trout', 'mike.trout@mlb.com', 'hash5'),
('FIA', 'Mohammed Ben Sulayem', 'contact@fia.com', 'hash6'),
('International Biathlon Union', 'Olle Dahlin', 'info@ibu.com', 'hash7'),
('FIFA', 'Gianni Infantino', 'president@fifa.com', 'hash8'),
('International Hockey Federation', 'Luc Tardif', 'luc.tardif@iihf.com', 'hash9'),
('Universal Sports Events', 'Peter Parker', 'p.parker@use.com', 'hash10');

INSERT INTO "Discipline" ("name", "unit", "result_format") VALUES
('Football', 'goals', 'score'),
('Ice Hockey', 'goals', 'score'),
('Texas Hold''em Poker', 'chips', 'place'),
('Dota 2', 'matches', 'score'),
('CS:GO', 'rounds', 'score'),
('Chess', 'points', 'win/loss/draw'),
('Baseball', 'runs', 'score'),
('Formula 1', 'time/laps', 'place/time'),
('Biathlon Sprint 10km', 'time', 'time/misses'),
('Triathlon', 'time', 'total_time');

INSERT INTO "Series" ("name", "start_date", "end_date") VALUES
('World Athletic Games 2025', '2025-07-01', '2025-07-15'),
('Winter Sports Festival 2026', '2026-02-05', '2026-02-25'),
('Celebrity Poker Tour 2025', '2025-10-20', '2025-10-25'), 
('Global Football Championship', '2025-06-10', '2025-07-10'),
('International Hockey League', '2025-09-15', '2026-04-20'),
('Esports Masters Series: Fall', '2025-11-01', '2025-11-15'),
('Grandmasters Chess Circuit', '2025-05-05', '2025-05-15'),
('American Baseball Classic', '2025-08-01', '2025-08-20'),
('F1 World Championship 2025', '2025-03-15', '2025-11-23'),
('Biathlon World Cup 25/26', '2025-11-29', '2026-03-22');

INSERT INTO "Event" ("series_id", "discipline_id", "name", "start_date", "end_date", "status", "venue", "team_size_min", "team_size_max") VALUES
(3, 3, 'Main Event - Texas Hold''em', '2025-10-20', '2025-10-25', 'Finished', 'Casino de Monte-Carlo, Monaco', 1, 1),
(1, 1, 'Men''s Football Tournament', '2025-07-02', '2025-07-14', 'Preparing', 'Wembley Stadium, London', 11, 11),
(1, 7, 'Baseball Championship', '2025-07-03', '2025-07-12', 'Preparing', 'Tokyo Dome, Tokyo', 9, 9),
(2, 2, 'Men''s Ice Hockey', '2026-02-06', '2026-02-24', 'Preparing', 'Bell Centre, Montreal', 6, 22),
(2, 9, 'Biathlon Men''s Sprint', '2026-02-10', '2026-02-10', 'Preparing', 'Holmenkollen, Oslo', 1, 1),
(4, 1, 'Group Stage', '2025-06-10', '2025-06-25', 'Preparing', 'Various stadiums', 11, 11),
(5, 2, 'Regular Season', '2025-09-15', '2026-03-30', 'Preparing', 'Various arenas', 6, 22),
(6, 4, 'Dota 2 Championship', '2025-11-01', '2025-11-08', 'Preparing', 'Avicii Arena, Stockholm', 5, 5),
(6, 5, 'CS:GO Major', '2025-11-09', '2025-11-15', 'Preparing', 'Lanxess Arena, Cologne', 5, 5),
(7, 6, 'World Chess Blitz Championship', '2025-05-08', '2025-05-10', 'Preparing', 'Dubai Exhibition Centre, Dubai', 1, 1),
(9, 8, 'Monaco Grand Prix', '2025-05-22', '2025-05-25', 'Preparing', 'Circuit de Monaco', 1, 2);

INSERT INTO "Matchup" ("event_id", "name", "start_date", "end_date", "status") VALUES
(1, 'Main Event - Day 1', '2025-10-20', '2025-10-21', 'Finished'),
(1, 'Main Event - Final Table', '2025-10-25', '2025-10-25', 'Finished'),
(2, 'Final: Team A vs Team B', '2025-07-14', '2025-07-14', 'Scheduled'),
(4, 'Gold Medal Match', '2026-02-24', '2026-02-24', 'Scheduled'),
(8, 'Grand Final', '2025-11-08', '2025-11-08', 'Scheduled'),
(9, 'Grand Final', '2025-11-15', '2025-11-15', 'Scheduled'),
(11, 'Race Day', '2025-05-25', '2025-05-25', 'Scheduled'),
(6, 'Group A: Team 1 vs Team 2', '2025-06-11', '2025-06-11', 'Scheduled'),
(7, 'Game Day 1: Team X vs Team Y', '2025-09-15', '2025-09-15', 'Scheduled'),
(3, 'Final Game', '2025-07-12', '2025-07-12', 'Scheduled');

INSERT INTO "Athlet" ("name", "date_of_birth", "country", "email", "password_hash") VALUES
('Lionel Messi', '1987-06-24', 'Argentina', 'messi@email.com', 'hash_messi'),
('Cristiano Ronaldo', '1985-02-05', 'Portugal', 'ronaldo@email.com', 'hash_ronaldo'),
('Neymar Jr', '1992-02-05', 'Brazil', 'neymar@email.com', 'hash_neymar'),
('Kylian Mbappé', '1998-12-20', 'France', 'mbappe@email.com', 'hash_mbappe'),
('Alexander Ovechkin', '1985-09-17', 'Russia', 'ovechkin@email.com', 'hash_ovechkin'),
('Connor McDavid', '1997-01-13', 'Canada', 'mcdavid@email.com', 'hash_mcdavid'),
('Sidney Crosby', '1987-08-07', 'Canada', 'crosby@email.com', 'hash_crosby'),
('Magnus Carlsen', '1990-11-30', 'Norway', 'carlsen@email.com', 'hash_carlsen'),
('Max Verstappen', '1997-09-30', 'Netherlands', 'verstappen@email.com', 'hash_verstappen'),
('Lewis Hamilton', '1985-01-07', 'UK', 'hamilton@email.com', 'hash_hamilton'),
('Johannes Thingnes Bø', '1993-05-16', 'Norway', 'johannes.boe@email.com', 'hash_jboe'),
('Martin Fourcade', '1988-09-14', 'France', 'fourcade@email.com', 'hash_fourcade'),
('Shohei Ohtani', '1994-07-05', 'Japan', 'ohtani@email.com', 'hash_ohtani'),
('Mike Trout', '1991-08-07', 'USA', 'trout@email.com', 'hash_trout'),
('Oleksandr "s1mple" Kostyliev', '1997-10-02', 'Ukraine', 's1mple@email.com', 'hash_s1mple'),
('Mathieu "ZywOo" Herbaut', '2000-11-09', 'France', 'zywoo@email.com', 'hash_zywoo'),
('Johan "N0tail" Sundstein', '1993-10-08', 'Denmark', 'notail@email.com', 'hash_notail'),
('Clement "Puppey" Ivanov', '1990-03-06', 'Estonia', 'puppey@email.com', 'hash_puppey'),
('Phil Ivey', '1977-02-01', 'USA', 'ivey@email.com', 'hash_ivey'),
('Gerard Piqué', '1987-02-02', 'Spain', 'pique@email.com', 'hash_pique');

INSERT INTO "Team" ("name", "country") VALUES
('Real Madrid', 'Spain'),
('PSG', 'France'),
('Washington Capitals', 'USA'),
('Edmonton Oilers', 'Canada'),
('Natus Vincere', 'Ukraine'),
('Team Vitality', 'France'),
('Team Secret', 'EU'),
('OG', 'EU'),
('Los Angeles Dodgers', 'USA'),
('New York Yankees', 'USA'),
('Red Bull Racing', 'Austria'),
('Mercedes-AMG Petronas F1 Team', 'Germany');

INSERT INTO "PrizeFund" ("event_id", "total_amount") VALUES
(1, 1000000.00);

INSERT INTO "Prize" ("prize_fund_id", "place", "amount") VALUES
(1, 1, 500000.00),
(1, 2, 250000.00),
(1, 3, 100000.00),
(1, 4, 50000.00),
(1, 5, 25000.00),
(1, 6, 15000.00),
(1, 7, 10000.00),
(1, 8, 10000.00),
(1, 9, 10000.00),
(1, 10, 10000.00);

INSERT INTO "SeriesPlanner" ("planner_id", "series_id") VALUES
(2, 3), (1, 1), (1, 2), (8, 4), (9, 5), (3, 6), (4, 7), (5, 8), (6, 9), (7, 10),
(10, 1), (10, 2), (10, 3), (10, 4), (10, 5), (10, 6), (10, 7), (10, 8), (10, 9), (10, 10);

INSERT INTO "TeamMember" ("athlete_id", "team_id", "role")
VALUES
(
    (SELECT id FROM "Athlet" WHERE name = 'Lionel Messi'),
    (SELECT id FROM "Team" WHERE name = 'Real Madrid'),
    'Forward'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Kylian Mbappé'),
    (SELECT id FROM "Team" WHERE name = 'PSG'),
    'Forward'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Lionel Messi'),
    (SELECT id FROM "Team" WHERE name = 'PSG'),
    'Forward'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Alexander Ovechkin'),
    (SELECT id FROM "Team" WHERE name = 'Washington Capitals'),
    'Left Wing'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Connor McDavid'),
    (SELECT id FROM "Team" WHERE name = 'Edmonton Oilers'),
    'Center'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Sidney Crosby'),
    (SELECT id FROM "Team" WHERE name = 'Edmonton Oilers'),
    'Center'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Oleksandr "s1mple" Kostyliev'),
    (SELECT id FROM "Team" WHERE name = 'Natus Vincere'),
    'AWPer'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Mathieu "ZywOo" Herbaut'),
    (SELECT id FROM "Team" WHERE name = 'Team Vitality'),
    'AWPer'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Clement "Puppey" Ivanov'),
    (SELECT id FROM "Team" WHERE name = 'Team Secret'),
    'Captain'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Johan "N0tail" Sundstein'),
    (SELECT id FROM "Team" WHERE name = 'OG'),
    'Captain'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Shohei Ohtani'),
    (SELECT id FROM "Team" WHERE name = 'Los Angeles Dodgers'),
    'Pitcher/Hitter'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Mike Trout'),
    (SELECT id FROM "Team" WHERE name = 'New York Yankees'),
    'Outfielder'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Max Verstappen'),
    (SELECT id FROM "Team" WHERE name = 'Red Bull Racing'),
    'Driver'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Lewis Hamilton'),
    (SELECT id FROM "Team" WHERE name = 'Mercedes-AMG Petronas F1 Team'),
    'Driver'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Cristiano Ronaldo'),
    (SELECT id FROM "Team" WHERE name = 'PSG'),
    'Captain'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Alexander Ovechkin'),
    (SELECT id FROM "Team" WHERE name = 'Edmonton Oilers'),
    'Forward'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Connor McDavid'),
    (SELECT id FROM "Team" WHERE name = 'Washington Capitals'),
    'Forward'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Oleksandr "s1mple" Kostyliev'),
    (SELECT id FROM "Team" WHERE name = 'Team Vitality'),
    'Rifler'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Mathieu "ZywOo" Herbaut'),
    (SELECT id FROM "Team" WHERE name = 'Natus Vincere'),
    'Rifler'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Clement "Puppey" Ivanov'),
    (SELECT id FROM "Team" WHERE name = 'OG'),
    'Support'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Johan "N0tail" Sundstein'),
    (SELECT id FROM "Team" WHERE name = 'Team Secret'),
    'Support'
);

INSERT INTO "AthletRegistration" ("athlet_id", "matchup_id", "payment_status", "status")
VALUES
(
    (SELECT id FROM "Athlet" WHERE name = 'Lionel Messi'),
    (SELECT id FROM "Matchup" WHERE name = 'Main Event - Day 1' AND event_id = (SELECT id FROM "Event" WHERE name = 'Main Event - Texas Hold''em')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Cristiano Ronaldo'),
    (SELECT id FROM "Matchup" WHERE name = 'Main Event - Final Table' AND event_id = (SELECT id FROM "Event" WHERE name = 'Main Event - Texas Hold''em')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Neymar Jr'),
    (SELECT id FROM "Matchup" WHERE name = 'Final: Team A vs Team B' AND event_id = (SELECT id FROM "Event" WHERE name = 'Men''s Football Tournament')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Kylian Mbappé'),
    (SELECT id FROM "Matchup" WHERE name = 'Gold Medal Match' AND event_id = (SELECT id FROM "Event" WHERE name = 'Men''s Ice Hockey')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Alexander Ovechkin'),
    (SELECT id FROM "Matchup" WHERE name = 'Grand Final' AND event_id = (SELECT id FROM "Event" WHERE name = 'Dota 2 Championship')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Connor McDavid'),
    (SELECT id FROM "Matchup" WHERE name = 'Grand Final' AND event_id = (SELECT id FROM "Event" WHERE name = 'CS:GO Major')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Sidney Crosby'),
    (SELECT id FROM "Matchup" WHERE name = 'Race Day' AND event_id = (SELECT id FROM "Event" WHERE name = 'Monaco Grand Prix')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Magnus Carlsen'),
    (SELECT id FROM "Matchup" WHERE name = 'Group A: Team 1 vs Team 2' AND event_id = (SELECT id FROM "Event" WHERE name = 'Group Stage')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Max Verstappen'),
    (SELECT id FROM "Matchup" WHERE name = 'Game Day 1: Team X vs Team Y' AND event_id = (SELECT id FROM "Event" WHERE name = 'Regular Season')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Lewis Hamilton'),
    (SELECT id FROM "Matchup" WHERE name = 'Final Game' AND event_id = (SELECT id FROM "Event" WHERE name = 'Baseball Championship')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Johannes Thingnes Bø'),
    (SELECT id FROM "Matchup" WHERE name = 'Main Event - Day 1' AND event_id = (SELECT id FROM "Event" WHERE name = 'Main Event - Texas Hold''em')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Martin Fourcade'),
    (SELECT id FROM "Matchup" WHERE name = 'Main Event - Final Table' AND event_id = (SELECT id FROM "Event" WHERE name = 'Main Event - Texas Hold''em')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Shohei Ohtani'),
    (SELECT id FROM "Matchup" WHERE name = 'Final: Team A vs Team B' AND event_id = (SELECT id FROM "Event" WHERE name = 'Men''s Football Tournament')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Mike Trout'),
    (SELECT id FROM "Matchup" WHERE name = 'Gold Medal Match' AND event_id = (SELECT id FROM "Event" WHERE name = 'Men''s Ice Hockey')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Oleksandr "s1mple" Kostyliev'),
    (SELECT id FROM "Matchup" WHERE name = 'Grand Final' AND event_id = (SELECT id FROM "Event" WHERE name = 'Dota 2 Championship')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Mathieu "ZywOo" Herbaut'),
    (SELECT id FROM "Matchup" WHERE name = 'Grand Final' AND event_id = (SELECT id FROM "Event" WHERE name = 'CS:GO Major')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Johan "N0tail" Sundstein'),
    (SELECT id FROM "Matchup" WHERE name = 'Race Day' AND event_id = (SELECT id FROM "Event" WHERE name = 'Monaco Grand Prix')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Clement "Puppey" Ivanov'),
    (SELECT id FROM "Matchup" WHERE name = 'Group A: Team 1 vs Team 2' AND event_id = (SELECT id FROM "Event" WHERE name = 'Group Stage')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Phil Ivey'),
    (SELECT id FROM "Matchup" WHERE name = 'Game Day 1: Team X vs Team Y' AND event_id = (SELECT id FROM "Event" WHERE name = 'Regular Season')),
    'Paid',
    'Confirmed'
),
(
    (SELECT id FROM "Athlet" WHERE name = 'Gerard Piqué'),
    (SELECT id FROM "Matchup" WHERE name = 'Final Game' AND event_id = (SELECT id FROM "Event" WHERE name = 'Baseball Championship')),
    'Paid',
    'Confirmed'
);

INSERT INTO "TeamRegistration" ("matchup_id", "team_id", "payment_status", "status")
VALUES
-- Команды регистрируются на матчах
(
    (SELECT id FROM "Matchup" WHERE name = 'Main Event - Day 1' AND event_id = (SELECT id FROM "Event" WHERE name = 'Main Event - Texas Hold''em')),
    (SELECT id FROM "Team" WHERE name = 'Washington Capitals'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Main Event - Final Table' AND event_id = (SELECT id FROM "Event" WHERE name = 'Main Event - Texas Hold''em')),
    (SELECT id FROM "Team" WHERE name = 'Washington Capitals'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Final: Team A vs Team B' AND event_id = (SELECT id FROM "Event" WHERE name = 'Men''s Football Tournament')),
    (SELECT id FROM "Team" WHERE name = 'Edmonton Oilers'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Gold Medal Match' AND event_id = (SELECT id FROM "Event" WHERE name = 'Men''s Ice Hockey')),
    (SELECT id FROM "Team" WHERE name = 'Edmonton Oilers'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Grand Final' AND event_id = (SELECT id FROM "Event" WHERE name = 'Dota 2 Championship')),
    (SELECT id FROM "Team" WHERE name = 'Natus Vincere'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Grand Final' AND event_id = (SELECT id FROM "Event" WHERE name = 'CS:GO Major')),
    (SELECT id FROM "Team" WHERE name = 'Natus Vincere'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Race Day' AND event_id = (SELECT id FROM "Event" WHERE name = 'Monaco Grand Prix')),
    (SELECT id FROM "Team" WHERE name = 'Team Vitality'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Group A: Team 1 vs Team 2' AND event_id = (SELECT id FROM "Event" WHERE name = 'Group Stage')),
    (SELECT id FROM "Team" WHERE name = 'Team Vitality'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Game Day 1: Team X vs Team Y' AND event_id = (SELECT id FROM "Event" WHERE name = 'Regular Season')),
    (SELECT id FROM "Team" WHERE name = 'Los Angeles Dodgers'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Final Game' AND event_id = (SELECT id FROM "Event" WHERE name = 'Baseball Championship')),
    (SELECT id FROM "Team" WHERE name = 'Los Angeles Dodgers'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Main Event - Day 1' AND event_id = (SELECT id FROM "Event" WHERE name = 'Main Event - Texas Hold''em')),
    (SELECT id FROM "Team" WHERE name = 'Team Secret'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Main Event - Final Table' AND event_id = (SELECT id FROM "Event" WHERE name = 'Main Event - Texas Hold''em')),
    (SELECT id FROM "Team" WHERE name = 'Team Secret'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Final: Team A vs Team B' AND event_id = (SELECT id FROM "Event" WHERE name = 'Men''s Football Tournament')),
    (SELECT id FROM "Team" WHERE name = 'OG'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Gold Medal Match' AND event_id = (SELECT id FROM "Event" WHERE name = 'Men''s Ice Hockey')),
    (SELECT id FROM "Team" WHERE name = 'OG'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Grand Final' AND event_id = (SELECT id FROM "Event" WHERE name = 'Dota 2 Championship')),
    (SELECT id FROM "Team" WHERE name = 'Washington Capitals'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Grand Final' AND event_id = (SELECT id FROM "Event" WHERE name = 'CS:GO Major')),
    (SELECT id FROM "Team" WHERE name = 'Washington Capitals'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Race Day' AND event_id = (SELECT id FROM "Event" WHERE name = 'Monaco Grand Prix')),
    (SELECT id FROM "Team" WHERE name = 'Edmonton Oilers'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Group A: Team 1 vs Team 2' AND event_id = (SELECT id FROM "Event" WHERE name = 'Group Stage')),
    (SELECT id FROM "Team" WHERE name = 'Edmonton Oilers'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Game Day 1: Team X vs Team Y' AND event_id = (SELECT id FROM "Event" WHERE name = 'Regular Season')),
    (SELECT id FROM "Team" WHERE name = 'Natus Vincere'),
    'Pending',
    'Registered'
),
(
    (SELECT id FROM "Matchup" WHERE name = 'Final Game' AND event_id = (SELECT id FROM "Event" WHERE name = 'Baseball Championship')),
    (SELECT id FROM "Team" WHERE name = 'Natus Vincere'),
    'Pending',
    'Registered'
);



INSERT INTO "MatchupResult" ("matchup_id", "athlet_registration_id", "team_registration_id", "result", "place", "status") VALUES
(1, (SELECT id FROM "AthletRegistration" WHERE athlet_id = 1 AND matchup_id = 1), NULL, '15000 chips', 1, 'Official'),
(1, (SELECT id FROM "AthletRegistration" WHERE athlet_id = 11 AND matchup_id = 1), NULL, '5000 chips', 2, 'Official'),

(2, (SELECT id FROM "AthletRegistration" WHERE athlet_id = 2 AND matchup_id = 2), NULL, '200000 chips', 1, 'Official'),
(2, (SELECT id FROM "AthletRegistration" WHERE athlet_id = 12 AND matchup_id = 2), NULL, '150000 chips', 2, 'Official'),

(3, NULL, (SELECT id FROM "TeamRegistration" WHERE team_id = 4 AND matchup_id = 4), '2-1', 1, 'Official'),
(3, NULL, (SELECT id FROM "TeamRegistration" WHERE team_id = 8 AND matchup_id = 4), '1-2', 2, 'Official'),

(4, NULL, (SELECT id FROM "TeamRegistration" WHERE team_id = 4 AND matchup_id = 3), '4-3', 1, 'Official'),
(4, NULL, (SELECT id FROM "TeamRegistration" WHERE team_id = 8 AND matchup_id = 3), '3-4', 2, 'Official'),

(5, NULL, (SELECT id FROM "TeamRegistration" WHERE team_id = 5 AND matchup_id = 5), '3-2', 1, 'Official'),
(5, NULL, (SELECT id FROM "TeamRegistration" WHERE team_id = 3 AND matchup_id = 5), '2-3', 2, 'Official');