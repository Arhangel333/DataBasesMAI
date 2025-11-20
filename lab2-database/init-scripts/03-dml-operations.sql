-- Вставка новой записи (новый пользователь)
INSERT INTO Users (email, password_hash, first_name, last_name, phone_number) 
VALUES ('new.user@email.com', 'hash6', 'Анна', 'Соколова', '+79166789012');

-- Вставка нового мероприятия
INSERT INTO Events (organizer_id, category_id, title, description, venue_type, venue_name, start_datetime, end_datetime, status) 
VALUES (2, 2, 'Data Science Bootcamp', 'Интенсив по Data Science для аналитиков', 'online', NULL, '2024-09-01 09:00:00', '2024-09-03 18:00:00', 'draft');

-- Обновление существующей записи (изменение статуса мероприятия)
UPDATE Events 
SET status = 'published', published_at = NOW() 
WHERE event_id = 4;

-- Обновление цены билета
UPDATE TicketTypes 
SET price = 1700.00 
WHERE ticket_type_id = 1 AND event_id = 1;

-- Удаление определенной записи (отмена неоплаченного заказа)
DELETE FROM Orders 
WHERE status = 'pending' AND created_at < NOW() - INTERVAL '1 HOUR';

-- Удаление пользователя (каскадное удаление связанных данных)
DELETE FROM Users 
WHERE email = 'new.user@email.com';