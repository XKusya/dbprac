SET ROLE test;

-- доступ к Date
SELECT month_name, (week_day IN (6, 7)) is_weekend FROM date LIMIT 1;
UPDATE date SET month_name = 'TestMonth' WHERE id = 20250101;

-- доступ к participant
SELECT name, country, meta FROM participant LIMIT 1;
UPDATE participant SET country = 'TestCountry' WHERE id = 1;
UPDATE participant SET is_team = TRUE WHERE id = 1;

-- доступ к Competition
SELECT series, meta->'discipline' AS discipline FROM competition LIMIT 1;
INSERT INTO competition (id, series, event, matchup, venue) VALUES (99999999, 'Series X', 'Event Y', 'Match Z', 'Venue A');

-- Доступ к Performance
UPDATE performance SET final_score_value = '9999' WHERE performance_id = 1;
UPDATE performance SET prize_won = '1000.00'::MONEY WHERE performance_id = 1;

-- доступ к представлениям
SELECT name, discipline, final_score_value FROM v_PerformanceSummary LIMIT 1;
SELECT year, quarter, total_prize_payout FROM v_QuarterlyFinancials WHERE year = 2025;