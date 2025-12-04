--Функция, которая возвращает количество активных 
--(статус = 'published') мероприятий для указанного организатора.
CREATE OR REPLACE FUNCTION get_organizer_active_events_count(p_organizer_id INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
events_count INTEGER;
BEGIN
IF EXISTS(SELECT 1 FROM Organizers o WHERE organizer_id = p_organizer_id ) THEN
    SELECT COUNT(*) INTO events_count FROM events e
    WHERE e.organizer_id = p_organizer_id AND 
    e.status = 'published';

RETURN events_count;
ELSE
    RETURN 0;
    END IF;
END;
$$;

DROP FUNCTION IF EXISTS check_ticket_availability(integer, integer);
-- Функция для проверки доступности билетов на мероприятие
CREATE OR REPLACE FUNCTION check_ticket_availability(
    p_event_id INTEGER,
    p_ticket_type_id INTEGER DEFAULT NULL
)
RETURNS TABLE(
    event_id INTEGER,
    organizer_id INTEGER,
    category_name VARCHAR(100),
    title VARCHAR(255),
    description TEXT,
    venue_type VARCHAR(20),
    venue_name VARCHAR(255),
    venue_address TEXT,
    start_datetime TIMESTAMP,
    status VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    event_row RECORD;
    cat_id INTEGER;
    cat_name VARCHAR(100);
BEGIN
    IF EXISTS (SELECT 1 FROM Events e WHERE e.event_id = p_event_id) THEN

    SELECT e.category_id INTO cat_id
    FROM Events e WHERE e.event_id = p_event_id;
    
    SELECT c.name INTO cat_name
    FROM Categories c WHERE c.category_id = cat_id; 

        FOR event_row IN SELECT * FROM Events e WHERE e.event_id = p_event_id LOOP
            event_id := event_row.event_id;
            organizer_id := event_row.organizer_id;
            category_name := cat_name;
            title := event_row.title;
            description := event_row.description;
            venue_type := event_row.venue_type;
            venue_name := event_row.venue_name;
            venue_address := event_row.venue_address;
            start_datetime := event_row.start_datetime;
            status := event_row.status;
            RETURN NEXT;
        END LOOP; 
    

    ELSE
        RAISE EXCEPTION 'No such Event %', p_event_id;
    END IF;



END;
$$;
