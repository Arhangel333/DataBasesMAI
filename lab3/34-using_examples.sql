--Проверим функцию просмотра доступных билетов
SELECT * FROM check_ticket_availability(1, 1);


--Не вставится изза ошибки в дате(мероприятие из прошлого)
INSERT INTO Events (
    organizer_id, title, description, venue_type,
    start_datetime, end_datetime, status
) VALUES (
    1, 'Draft Event', 'Description', 'online',
    '2023-01-01 10:00:00', '2023-01-01 12:00:00', 'draft'
);



--Проверяем триггер времени должен обновить дату обновления записи
INSERT INTO Events (
    organizer_id, title, description, venue_type,
    start_datetime, end_datetime, status
) VALUES (
    1, 'Draft Event', 'Description', 'online',
    NOW() + INTERVAL '24 hours',  -- Завтра в это же время
    NOW() + INTERVAL '26 hours',  -- Через 26 часов
    'draft'
);

SELECT  event_id, organizer_id, title, description, venue_type,
    start_datetime, end_datetime, status FROM Events
    ORDER BY start_datetime ASC;

UPDATE Events 
SET status = 'published', published_at = NOW() + INTERVAL '25 hours'
WHERE event_id = 35;

SELECT  event_id, organizer_id, title, description, venue_type,
    start_datetime, end_datetime, status FROM Events
    ORDER BY start_datetime ASC;