CREATE DATABASE "sports"

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

CREATE TABLE "TeamMember" (
  "athlete_id" INT NOT NULL,
  "team_id" INT NOT NULL,
  "role" VARCHAR(255),
  PRIMARY KEY ("athlete_id", "team_id"),
  FOREIGN KEY ("athlete_id") REFERENCES "Athlet"("id") ON DELETE CASCADE,
  FOREIGN KEY ("team_id") REFERENCES "Team"("id") ON DELETE CASCADE
);

CREATE TABLE "Team" (
  "id" INT NOT NULL,
  "name" VARCHAR(255),
  "country" VARCHAR(255),
  PRIMARY KEY ("id")
);

CREATE TABLE "AthletRegistration" (
  "id" INT NOT NULL,
  "athlet_id" INT NOT NULL,
  "matchup_id" INT NOT NULL,
  "payment_status" VARCHAR(255),
  "status" VARCHAR(255),
  PRIMARY KEY ("id"),
  FOREIGN KEY ("athlet_id") REFERENCES "Athlet"("id") ON DELETE CASCADE,
  FOREIGN KEY ("matchup_id") REFERENCES "Matchup"("id") ON DELETE CASCADE
);

CREATE TABLE "TeamRegistration" (
  "id" INT NOT NULL,
  "matchup_id" INT NOT NULL,
  "team_id" INT NOT NULL,
  "payment_status" VARCHAR(255),
  "status" VARCHAR(255),
  PRIMARY KEY ("id"),
  FOREIGN KEY ("matchup_id") REFERENCES "Matchup"("id") ON DELETE CASCADE,
  FOREIGN KEY ("team_id") REFERENCES "Team"("id") ON DELETE CASCADE
);

CREATE TABLE "Series" (
  "id" INT NOT NULL,
  "name" VARCHAR(255),
  "start_date" DATE,
  "end_date" DATE,
  PRIMARY KEY ("id")
);

CREATE TABLE "Discipline" (
  "id" INT NOT NULL,
  "name" VARCHAR(255),
  "unit" VARCHAR(255),
  "result_format" VARCHAR(255),
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
  FOREIGN KEY ("series_id") REFERENCES "Series"("id") ON DELETE CASCADE,
  FOREIGN KEY ("discipline_id") REFERENCES "Discipline"("id") ON DELETE RESTRICT
);

CREATE TABLE "Matchup" (
  "id" INT NOT NULL,
  "event_id" INT NOT NULL,
  "name" VARCHAR(255),
  "start_date" DATE,
  "end_date" DATE,
  "status" VARCHAR(255),
  PRIMARY KEY ("id"),
  FOREIGN KEY ("event_id") REFERENCES "Event"("id") ON DELETE CASCADE
);

CREATE TABLE "PrizeFund" (
  "id" INT NOT NULL,
  "event_id" INT NOT NULL,
  "total_amount" MONEY,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("event_id") REFERENCES "Event"("id") ON DELETE CASCADE
);

CREATE TABLE "Prize" (
  "id" INT NOT NULL,
  "prize_fund_id" INT NOT NULL,
  "place" SMALLINT,
  "amount" MONEY,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("prize_fund_id") REFERENCES "PrizeFund"("id") ON DELETE CASCADE
);

CREATE TABLE "SeriesPlanner" (
  "planner_id" INT NOT NULL,
  "series_id" INT NOT NULL,
  PRIMARY KEY ("planner_id", "series_id"),
  FOREIGN KEY ("planner_id") REFERENCES "Planner"("id") ON DELETE CASCADE,
  FOREIGN KEY ("series_id") REFERENCES "Series"("id") ON DELETE CASCADE
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
  FOREIGN KEY ("matchup_id") REFERENCES "Matchup"("id") ON DELETE CASCADE,
  FOREIGN KEY ("athlet_registration_id") REFERENCES "AthletRegistration"("id") ON DELETE CASCADE,
  FOREIGN KEY ("team_registration_id") REFERENCES "TeamRegistration"("id") ON DELETE CASCADE
);

