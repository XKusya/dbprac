CREATE OR REPLACE FUNCTION prevent_registration_on_finished_event()
RETURNS TRIGGER AS $$
BEGIN
    IF (
        SELECT e.status
        FROM "Matchup" m
            JOIN "Event" e ON m.event_id = e.id
        WHERE
            m.id = NEW.matchup_id
    ) = 'Finished' THEN 
        RAISE EXCEPTION 'Cannot register athlete on matchup "%" because the event is already finished.',
            (
                SELECT name
                FROM "Matchup"
                WHERE
                    id = NEW.matchup_id
            )
    ;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_prevent_registration_on_finished_event
    BEFORE INSERT ON "AthletRegistration"
    FOR EACH ROW
    EXECUTE FUNCTION prevent_registration_on_finished_event();

INSERT INTO "AthletRegistration" (
    "athlet_id",
    "matchup_id",
    "payment_status",
    "status"
)
VALUES (
    (SELECT id FROM "Athlet" WHERE name = 'Lightning McQueen'),
    (SELECT id FROM "Matchup" WHERE name = 'Race in Tokyo'),
    'Paid',
    'Confirmed'
);