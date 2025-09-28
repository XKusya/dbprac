CREATE DATABASE "sports";

CREATE TABLE "Planner" (
    "id" INT NOT NULL,
    "organization_name" VARCHAR(255),
    "contact_person" VARCHAR(255),
    "email" VARCHAR(255),
    "password_hash" VARCHAR(255),
    PRIMARY KEY ("id")
);

CREATE TABLE "Athlet" (
    "id" INT NOT NULL,
    "name" VARCHAR(255),
    "date_of_birth" DATE,
    "country" VARCHAR(255),
    "email" VARCHAR(255),
    "password_hash" VARCHAR(255),
    PRIMARY KEY ("id")
);

CREATE TABLE "Team" (
    "id" INT NOT NULL,
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
    "id" INT NOT NULL,
    "name" VARCHAR(255),
    "unit" VARCHAR(255),
    "result_format" VARCHAR(255),
    PRIMARY KEY ("id")
);

CREATE TABLE "Series" (
    "id" INT NOT NULL,
    "name" VARCHAR(255),
    "start_date" DATE,
    "end_date" DATE,
    PRIMARY KEY ("id")
);

CREATE TABLE "Event" (
    "id" INT NOT NULL,
    "series_id" INT NOT NULL,
    "discipline_id" INT NOT NULL,
    "name" VARCHAR(255),
    "start_date" DATE,
    "end_date" DATE,
    "status" VARCHAR(255),
    "venue" TEXT,
    "team_size_min" SMALLINT,
    "team_size_max" SMALLINT,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("series_id") REFERENCES "Series" ("id") ON DELETE CASCADE,
    FOREIGN KEY ("discipline_id") REFERENCES "Discipline" ("id") ON DELETE RESTRICT
);

CREATE TABLE "Matchup" (
    "id" INT NOT NULL,
    "event_id" INT NOT NULL,
    "name" VARCHAR(255),
    "start_date" DATE,
    "end_date" DATE,
    "status" VARCHAR(255),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("event_id") REFERENCES "Event" ("id") ON DELETE CASCADE
);

CREATE TABLE "AthletRegistration" (
    "id" INT NOT NULL,
    "athlet_id" INT NOT NULL,
    "matchup_id" INT NOT NULL,
    "payment_status" VARCHAR(255),
    "status" VARCHAR(255),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("athlet_id") REFERENCES "Athlet" ("id") ON DELETE CASCADE,
    FOREIGN KEY ("matchup_id") REFERENCES "Matchup" ("id") ON DELETE CASCADE
);

CREATE TABLE "TeamRegistration" (
    "id" INT NOT NULL,
    "matchup_id" INT NOT NULL,
    "team_id" INT NOT NULL,
    "payment_status" VARCHAR(255),
    "status" VARCHAR(255),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("matchup_id") REFERENCES "Matchup" ("id") ON DELETE CASCADE,
    FOREIGN KEY ("team_id") REFERENCES "Team" ("id") ON DELETE CASCADE
);

CREATE TABLE "PrizeFund" (
    "id" INT NOT NULL,
    "event_id" INT NOT NULL,
    "total_amount" MONEY,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("event_id") REFERENCES "Event" ("id") ON DELETE CASCADE
);

CREATE TABLE "Prize" (
    "id" INT NOT NULL,
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
    "id" INT NOT NULL,
    "matchup_id" INT NOT NULL,
    "athlet_registration_id" INT,
    "team_registration_id" INT,
    "result" VARCHAR(255),
    "place" SMALLINT,
    "status" VARCHAR(255),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("matchup_id") REFERENCES "Matchup" ("id") ON DELETE CASCADE,
    FOREIGN KEY ("athlet_registration_id") REFERENCES "AthletRegistration" ("id") ON DELETE CASCADE,
    FOREIGN KEY ("team_registration_id") REFERENCES "TeamRegistration" ("id") ON DELETE CASCADE
);


-- СТЕРЖНЕВЫЕ СУЩНОСТИ
INSERT INTO "Planner" ("id", "organization_name", "contact_person", "email", "password_hash") VALUES
(1, 'Global Sports Federation', 'John Doe', 'john.doe@gsf.com', 'hash1'),
(2, 'World Poker Series Org', 'Jane Smith', 'jane.smith@wpso.com', 'hash2'),
(3, 'Cyber Champions League', 'Alexey Ivanov', 'alex.i@ccl.com', 'hash3'),
(4, 'International Chess Union', 'Magnus Carlsen', 'contact@icu.com', 'hash4'),
(5, 'Major League Baseball Org', 'Mike Trout', 'mike.trout@mlb.com', 'hash5'),
(6, 'FIA', 'Mohammed Ben Sulayem', 'contact@fia.com', 'hash6'),
(7, 'International Biathlon Union', 'Olle Dahlin', 'info@ibu.com', 'hash7'),
(8, 'FIFA', 'Gianni Infantino', 'president@fifa.com', 'hash8'),
(9, 'International Hockey Federation', 'Luc Tardif', 'luc.tardif@iihf.com', 'hash9'),
(10, 'Universal Sports Events', 'Peter Parker', 'p.parker@use.com', 'hash10');

INSERT INTO "Discipline" ("id", "name", "unit", "result_format") VALUES
(1, 'Football', 'goals', 'score'),
(2, 'Ice Hockey', 'goals', 'score'),
(3, 'Texas Hold''em Poker', 'chips', 'place'),
(4, 'Dota 2', 'matches', 'score'),
(5, 'CS:GO', 'rounds', 'score'),
(6, 'Chess', 'points', 'win/loss/draw'),
(7, 'Baseball', 'runs', 'score'),
(8, 'Formula 1', 'time/laps', 'place/time'),
(9, 'Biathlon Sprint 10km', 'time', 'time/misses'),
(10, 'Triathlon', 'time', 'total_time');

-- Мультидисциплинарные турниры
INSERT INTO "Series" ("id", "name", "start_date", "end_date") VALUES
(1, 'World Athletic Games 2025', '2025-07-01', '2025-07-15'),
(2, 'Winter Sports Festival 2026', '2026-02-05', '2026-02-25'),
(3, 'Celebrity Poker Tour 2025', '2025-10-20', '2025-10-25'), 
-- Одиночные турниры
(4, 'Global Football Championship', '2025-06-10', '2025-07-10'),
(5, 'International Hockey League', '2025-09-15', '2026-04-20'),
(6, 'Esports Masters Series: Fall', '2025-11-01', '2025-11-15'),
(7, 'Grandmasters Chess Circuit', '2025-05-05', '2025-05-15'),
(8, 'American Baseball Classic', '2025-08-01', '2025-08-20'),
(9, 'F1 World Championship 2025', '2025-03-15', '2025-11-23'),
(10, 'Biathlon World Cup 25/26', '2025-11-29', '2026-03-22');

INSERT INTO "Event" ("id", "series_id", "discipline_id", "name", "start_date", "end_date", "status", "venue", "team_size_min", "team_size_max") VALUES
-- Событие для полностью организованного турнира по покеру
(1, 3, 3, 'Main Event - Texas Hold''em', '2025-10-20', '2025-10-25', 'Finished', 'Casino de Monte-Carlo, Monaco', 1, 1),
-- События для мультидисциплинарных турниров 
(2, 1, 1, 'Men''s Football Tournament', '2025-07-02', '2025-07-14', 'Preparing', 'Wembley Stadium, London', 11, 11),
(3, 1, 7, 'Baseball Championship', '2025-07-03', '2025-07-12', 'Preparing', 'Tokyo Dome, Tokyo', 9, 9),
(4, 2, 2, 'Men''s Ice Hockey', '2026-02-06', '2026-02-24', 'Preparing', 'Bell Centre, Montreal', 6, 22),
(5, 2, 9, 'Biathlon Men''s Sprint', '2026-02-10', '2026-02-10', 'Preparing', 'Holmenkollen, Oslo', 1, 1),
-- События для одиночных турниров 
(6, 4, 1, 'Group Stage', '2025-06-10', '2025-06-25', 'Preparing', 'Various stadiums', 11, 11),
(7, 5, 2, 'Regular Season', '2025-09-15', '2026-03-30', 'Preparing', 'Various arenas', 6, 22),
(8, 6, 4, 'Dota 2 Championship', '2025-11-01', '2025-11-08', 'Preparing', 'Avicii Arena, Stockholm', 5, 5),
(9, 6, 5, 'CS:GO Major', '2025-11-09', '2025-11-15', 'Preparing', 'Lanxess Arena, Cologne', 5, 5),
(10, 7, 6, 'World Chess Blitz Championship', '2025-05-08', '2025-05-10', 'Preparing', 'Dubai Exhibition Centre, Dubai', 1, 1),
(11, 9, 8, 'Monaco Grand Prix', '2025-05-22', '2025-05-25', 'Preparing', 'Circuit de Monaco', 1, 2);

INSERT INTO "Matchup" ("id", "event_id", "name", "start_date", "end_date", "status") VALUES
(1, 1, 'Main Event - Day 1', '2025-10-20', '2025-10-21', 'Finished'),
(2, 1, 'Main Event - Final Table', '2025-10-25', '2025-10-25', 'Finished'),
(3, 2, 'Final: Team A vs Team B', '2025-07-14', '2025-07-14', 'Scheduled'),
(4, 4, 'Gold Medal Match', '2026-02-24', '2026-02-24', 'Scheduled'),
(5, 8, 'Grand Final', '2025-11-08', '2025-11-08', 'Scheduled'),
(6, 9, 'Grand Final', '2025-11-15', '2025-11-15', 'Scheduled'),
(7, 11, 'Race Day', '2025-05-25', '2025-05-25', 'Scheduled'),
(8, 6, 'Group A: Team 1 vs Team 2', '2025-06-11', '2025-06-11', 'Scheduled'),
(9, 7, 'Game Day 1: Team X vs Team Y', '2025-09-15', '2025-09-15', 'Scheduled'),
(10, 3, 'Final Game', '2025-07-12', '2025-07-12', 'Scheduled');

INSERT INTO "Athlet" ("id", "name", "date_of_birth", "country", "email", "password_hash") VALUES
(1, 'Lionel Messi', '1987-06-24', 'Argentina', 'messi@email.com', 'hash_messi'),
(2, 'Cristiano Ronaldo', '1985-02-05', 'Portugal', 'ronaldo@email.com', 'hash_ronaldo'),
(3, 'Neymar Jr', '1992-02-05', 'Brazil', 'neymar@email.com', 'hash_neymar'),
(4, 'Kylian Mbappé', '1998-12-20', 'France', 'mbappe@email.com', 'hash_mbappe'),
(5, 'Alexander Ovechkin', '1985-09-17', 'Russia', 'ovechkin@email.com', 'hash_ovechkin'),
(6, 'Connor McDavid', '1997-01-13', 'Canada', 'mcdavid@email.com', 'hash_mcdavid'),
(7, 'Sidney Crosby', '1987-08-07', 'Canada', 'crosby@email.com', 'hash_crosby'),
(8, 'Magnus Carlsen', '1990-11-30', 'Norway', 'carlsen@email.com', 'hash_carlsen'),
(9, 'Max Verstappen', '1997-09-30', 'Netherlands', 'verstappen@email.com', 'hash_verstappen'),
(10, 'Lewis Hamilton', '1985-01-07', 'UK', 'hamilton@email.com', 'hash_hamilton'),
(11, 'Johannes Thingnes Bø', '1993-05-16', 'Norway', 'johannes.boe@email.com', 'hash_jboe'),
(12, 'Martin Fourcade', '1988-09-14', 'France', 'fourcade@email.com', 'hash_fourcade'),
(13, 'Shohei Ohtani', '1994-07-05', 'Japan', 'ohtani@email.com', 'hash_ohtani'),
(14, 'Mike Trout', '1991-08-07', 'USA', 'trout@email.com', 'hash_trout'),
(15, 'Oleksandr "s1mple" Kostyliev', '1997-10-02', 'Ukraine', 's1mple@email.com', 'hash_s1mple'),
(16, 'Mathieu "ZywOo" Herbaut', '2000-11-09', 'France', 'zywoo@email.com', 'hash_zywoo'),
(17, 'Johan "N0tail" Sundstein', '1993-10-08', 'Denmark', 'notail@email.com', 'hash_notail'),
(18, 'Clement "Puppey" Ivanov', '1990-03-06', 'Estonia', 'puppey@email.com', 'hash_puppey'),
(19, 'Phil Ivey', '1977-02-01', 'USA', 'ivey@email.com', 'hash_ivey'),
(20, 'Gerard Piqué', '1987-02-02', 'Spain', 'pique@email.com', 'hash_pique');

INSERT INTO "Team" ("id", "name", "country") VALUES
(1, 'Real Madrid', 'Spain'),
(2, 'PSG', 'France'),
(3, 'Washington Capitals', 'USA'),
(4, 'Edmonton Oilers', 'Canada'),
(5, 'Natus Vincere', 'Ukraine'),
(6, 'Team Vitality', 'France'),
(7, 'Team Secret', 'EU'),
(8, 'OG', 'EU'),
(9, 'Los Angeles Dodgers', 'USA'),
(10, 'New York Yankees', 'USA'),
(11, 'Red Bull Racing', 'Austria'),
(12, 'Mercedes-AMG Petronas F1 Team', 'Germany');

INSERT INTO "PrizeFund" ("id", "event_id", "total_amount") VALUES
(1, 1, 1000000.00);

INSERT INTO "Prize" ("id", "prize_fund_id", "place", "amount") VALUES
(1, 1, 1, 500000.00),
(2, 1, 2, 250000.00),
(3, 1, 3, 100000.00),
(4, 1, 4, 50000.00),
(5, 1, 5, 25000.00),
(6, 1, 6, 15000.00),
(7, 1, 7, 10000.00),
(8, 1, 8, 10000.00),
(9, 1, 9, 10000.00),
(10, 1, 10, 10000.00);


INSERT INTO "SeriesPlanner" ("planner_id", "series_id") VALUES
(2, 3), (1, 1), (1, 2), (8, 4), (9, 5), (3, 6), (4, 7), (5, 8), (6, 9), (7, 10),
(10, 1), (10, 2), (10, 3), (10, 4), (10, 5), (10, 6), (10, 7), (10, 8), (10, 9), (10, 10);

INSERT INTO "TeamMember" ("athlete_id", "team_id", "role") VALUES
(2, 1, 'Forward'), (4, 2, 'Forward'), (1, 2, 'Forward'),
(5, 3, 'Left Wing'), (6, 4, 'Center'), (7, 4, 'Center'),
(15, 5, 'AWPer'), (16, 6, 'AWPer'),
(18, 7, 'Captain'), (17, 8, 'Captain'),
(13, 9, 'Pitcher/Hitter'), (14, 10, 'Outfielder'),
(9, 11, 'Driver'), (10, 12, 'Driver'),
(1, 1, 'Captain'), (2, 2, 'Captain'), (5, 4, 'Forward'), (6, 3, 'Forward'),
(15, 6, 'Rifler'), (16, 5, 'Rifler'), (18, 8, 'Support'), (17, 7, 'Support');

INSERT INTO "AthletRegistration" ("id", "athlet_id", "matchup_id", "payment_status", "status") VALUES
(1, 1, 1, 'Paid', 'Confirmed'), (2, 2, 1, 'Paid', 'Confirmed'), (3, 3, 1, 'Paid', 'Confirmed'),
(4, 4, 1, 'Paid', 'Confirmed'), (5, 5, 1, 'Paid', 'Confirmed'), (6, 6, 1, 'Paid', 'Confirmed'),
(7, 7, 1, 'Paid', 'Confirmed'), (8, 8, 1, 'Paid', 'Confirmed'), (9, 9, 1, 'Paid', 'Confirmed'),
(10, 10, 1, 'Paid', 'Confirmed'), (11, 11, 1, 'Paid', 'Confirmed'), (12, 12, 1, 'Paid', 'Confirmed'),
(13, 13, 1, 'Paid', 'Confirmed'), (14, 14, 1, 'Paid', 'Confirmed'), (15, 15, 1, 'Paid', 'Confirmed'),
(16, 16, 1, 'Paid', 'Confirmed'), (17, 17, 1, 'Paid', 'Confirmed'), (18, 18, 1, 'Paid', 'Confirmed'),
(19, 19, 1, 'Paid', 'Confirmed'), (20, 20, 1, 'Paid', 'Confirmed');

INSERT INTO "TeamRegistration" ("id", "matchup_id", "team_id", "payment_status", "status") VALUES
(1, 3, 1, 'Pending', 'Registered'), (2, 3, 2, 'Pending', 'Registered'),
(3, 4, 3, 'Pending', 'Registered'), (4, 4, 4, 'Pending', 'Registered'),
(5, 5, 7, 'Pending', 'Registered'), (6, 5, 8, 'Pending', 'Registered'),
(7, 6, 5, 'Pending', 'Registered'), (8, 6, 6, 'Pending', 'Registered'),
(9, 10, 9, 'Pending', 'Registered'), (10, 10, 10, 'Pending', 'Registered'),
(11, 8, 1, 'Pending', 'Registered'), (12, 8, 2, 'Pending', 'Registered'),
(13, 9, 3, 'Pending', 'Registered'), (14, 9, 4, 'Pending', 'Registered'),
(15, 3, 5, 'Pending', 'Registered'), (16, 3, 6, 'Pending', 'Registered'),
(17, 4, 7, 'Pending', 'Registered'), (18, 4, 8, 'Pending', 'Registered'),
(19, 5, 9, 'Pending', 'Registered'), (20, 5, 10, 'Pending', 'Registered');

INSERT INTO "MatchupResult" ("id", "matchup_id", "athlet_registration_id", "team_registration_id", "result", "place", "status") VALUES
(1, 2, 19, NULL, 'Winner', 1, 'Official'), 
(2, 2, 8, NULL, 'Finalist', 2, 'Official'), 
(3, 2, 3, NULL, 'Finalist', 3, 'Official'), 
(4, 2, 20, NULL, 'Finalist', 4, 'Official'),
(5, 2, 5, NULL, 'Finalist', 5, 'Official'), 
(6, 2, 2, NULL, 'Finalist', 6, 'Official'), 
(7, 2, 9, NULL, 'Finalist', 7, 'Official'), 
(8, 2, 13, NULL, 'Finalist', 8, 'Official'), 
(9, 2, 17, NULL, 'Finalist', 9, 'Official'), 
(10, 2, 1, NULL, 'Eliminated', 10, 'Official'), 
(11, 2, 4, NULL, 'Eliminated', 11, 'Official'),
(12, 2, 6, NULL, 'Eliminated', 12, 'Official'),
(13, 2, 7, NULL, 'Eliminated', 13, 'Official'),
(14, 2, 10, NULL, 'Eliminated', 14, 'Official'),
(15, 2, 11, NULL, 'Eliminated', 15, 'Official'),
(16, 2, 12, NULL, 'Eliminated', 16, 'Official'),
(17, 2, 14, NULL, 'Eliminated', 17, 'Official'),
(18, 2, 15, NULL, 'Eliminated', 18, 'Official'),
(19, 2, 16, NULL, 'Eliminated', 19, 'Official'),
(20, 2, 18, NULL, 'Eliminated', 20, 'Official');