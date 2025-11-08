CREATE OR REPLACE FUNCTION get_participants_from_country(country_name VARCHAR)
RETURNS TABLE (id BIGINT, name VARCHAR) AS $$
DECLARE
    rec RECORD;
    counter INTEGER := 0;
    country_cursor REFCURSOR;
BEGIN
    OPEN country_cursor FOR
        SELECT p.id, p.name
        FROM Participant p
        WHERE p.country = country_name;

    LOOP
        FETCH country_cursor INTO rec;
        EXIT WHEN NOT FOUND;
        
        counter := counter + 1;
        
        id := rec.id;
        name := rec.name;
        RETURN NEXT;
    END LOOP;

    CLOSE country_cursor;

    IF counter = 0 THEN
        RAISE EXCEPTION 'Участники из страны "%" не найдены.', country_name;
    END IF; 
    RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_competitions_in_year(target_year SMALLINT)
RETURNS TABLE (
    competition_id BIGINT,
    event_name VARCHAR,
    held_on DATE
) AS $$
DECLARE
    rec RECORD;
    counter INTEGER := 0;
    comp_cursor CURSOR FOR
        SELECT c.id, c.event, d.date
        FROM Competition c
        JOIN Performance p ON c.id = p.competition_id
        JOIN Date d ON p.date_id = d.id
        WHERE d.year = target_year;
BEGIN
    OPEN comp_cursor;
    LOOP
        FETCH comp_cursor INTO rec;
        EXIT WHEN NOT FOUND;

        counter := counter + 1;
        competition_id := rec.id;
        event_name := rec.event;
        held_on := rec.date;
        RETURN NEXT;
    END LOOP;
    CLOSE comp_cursor;

    IF counter = 0 THEN
        RAISE EXCEPTION 'В % году не проведено ни одного соревнования.', target_year;
    END IF;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_participants_from_country('Russia'::VARCHAR);
SELECT * FROM get_participants_from_country('Atlantis'::VARCHAR);

SELECT * FROM get_competitions_in_year(2025::SMALLINT);
SELECT * FROM get_competitions_in_year(1900::SMALLINT); 