CREATE OR REPLACE FUNCTION check_series_paid_registrations_on_delete()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM
            "Event" e
            JOIN "Matchup" m ON e.id = m.event_id
            JOIN "TeamRegistration" tr ON m.id = tr.matchup_id
        WHERE
            e.series_id = OLD.id
            AND tr.payment_status = 'Paid'
    ) THEN RAISE EXCEPTION 'Cannot delete Series "%" because it has paid team registrations.',
    OLD.name;

    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_series_paid_registrations_on_delete
    BEFORE DELETE ON "Series"
    FOR EACH ROW
    EXECUTE FUNCTION check_series_paid_registrations_on_delete();

DELETE FROM "Series" WHERE name = 'World Grand Prix';