CREATE USER test WITH PASSWORD 'test_password'

GRANT CONNECT ON DATABASE sports_olap TO test;
GRANT SELECT, INSERT, UPDATE ON Date TO test;
GRANT SELECT (id, name, country, is_team, meta) ON participant TO test;
GRANT UPDATE (country) ON participant TO test;
GRANT SELECT ON Competition TO test;
GRANT SELECT ON v_PerformanceSummary TO test;


CREATE ROLE score_editor;
GRANT UPDATE (final_score_value, has_won) ON performance TO score_editor;
GRANT score_editor TO test;
GRANT SELECT ON v_QuarterlyFinancials TO score_editor;
