--Триггер для обновления времени последнего обновления
CREATE OR REPLACE FUNCTION update_event_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    old_json JSONB;
    new_json JSONB;
    arr TEXT[] := ARRAY['event_id', 'updated_at'];

BEGIN
    old_json := row_to_json(OLD)::jsonb - arr;
    new_json := row_to_json(NEW)::jsonb - arr;

    IF old_json IS DISTINCT FROM new_json THEN
        NEW.updated_at := CURRENT_TIMESTAMP;
        RAISE NOTICE 'Данные изменились, обновляем updated_at';
    ELSE
        RAISE NOTICE 'Данные не изменились, updated_at не трогаем';
    END IF;
    
    RETURN NEW;
END;
$$;



DROP TRIGGER IF EXISTS trg_update_event_timestamp ON Events;

CREATE TRIGGER trg_update_event_timestamp
    BEFORE UPDATE ON Events
    FOR EACH ROW
    EXECUTE FUNCTION update_event_timestamp();

--Не началось ли уже мероприятие ТРИГГЕР
CREATE OR REPLACE FUNCTION trg_add_func()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE


BEGIN
    IF NEW.start_datetime <= CURRENT_TIMESTAMP THEN
        RAISE EXCEPTION 'Event has already started at %',
                     NEW.start_datetime;
    END IF;

     IF NEW.end_datetime <= NEW.start_datetime THEN
        RAISE EXCEPTION 'Event end time (%) must be after start time (%)', 
                        NEW.end_datetime, NEW.start_datetime;
    END IF;


RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_add_event_timestamp ON Events;

CREATE TRIGGER trg_add_event_timestamp
BEFORE INSERT OR UPDATE ON Events
FOR EACH ROW
EXECUTE FUNCTION trg_add_func();

