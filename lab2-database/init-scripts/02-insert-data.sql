-- Наполнение базы данных тестовыми данными
-- Категории мероприятий
INSERT INTO Categories (name, description, icon_url) VALUES
('Концерты', 'Музыкальные мероприятия и выступления', '/icons/concerts.png'),
('Воркшопы', 'Обучающие семинары и мастер-классы', '/icons/workshops.png'),
('Встречи', 'Нетворкинг и бизнес-встречи', '/icons/meetups.png'),
('Спорт', 'Спортивные мероприятия и соревнования', '/icons/sports.png'),
('Искусство', 'Выставки и культурные события', '/icons/art.png')
ON CONFLICT (name) DO NOTHING;

-- Пользователи
INSERT INTO Users (email, password_hash, first_name, last_name, phone_number, date_of_birth) VALUES
('ivan.petrov@email.com', 'hash1', 'Иван', 'Петров', '+79161234567', '1990-05-15'),
('maria.ivanova@email.com', 'hash2', 'Мария', 'Иванова', '+79162345678', '1985-08-22'),
('alex.smirnov@email.com', 'hash3', 'Алексей', 'Смирнов', '+79163456789', '1992-12-10'),
('olga.kuznetsova@email.com', 'hash4', 'Ольга', 'Кузнецова', '+79164567890', '1988-03-30'),
('dmitry.vorobev@email.com', 'hash5', 'Дмитрий', 'Воробьев', '+79165678901', '1995-07-18')
ON CONFLICT (email) DO NOTHING;

-- Организаторы
INSERT INTO Organizers (user_id, company_name, description, website_url, is_verified) VALUES
(1, 'MusicPro Events', 'Организация музыкальных мероприятий', 'https://musicpro.com', TRUE),
(2, 'LearnWorks', 'Проведение образовательных воркшопов', 'https://learnworks.ru', TRUE),
(3, 'ArtSpace', 'Культурный центр и галерея', 'https://artspace.org', FALSE);

-- Мероприятия
INSERT INTO Events (organizer_id, category_id, title, description, venue_type, venue_name, venue_address, start_datetime, end_datetime, status, is_public, max_attendees) VALUES
(1, 1, 'Rock Festival 2024', 'Ежегодный рок-фестиваль с участием лучших групп', 'physical', 'Стадион "АренА"', 'Москва, ул. Спортивная, 1', '2024-07-15 18:00:00', '2024-07-15 23:00:00', 'published', TRUE, 5000),
(2, 2, 'Digital Marketing Workshop', 'Интенсив по цифровому маркетингу для начинающих', 'online', NULL, NULL, '2024-06-10 10:00:00', '2024-06-10 17:00:00', 'published', TRUE, 100),
(3, 5, 'Современное искусство: Выставка', 'Выставка современных художников', 'physical', 'Галерея "Модерн"', 'Санкт-Петербург, Невский пр., 45', '2024-08-20 11:00:00', '2024-09-20 19:00:00', 'published', TRUE, 200),
(1, 1, 'Jazz Night', 'Вечер джазовой музыки', 'physical', 'Клуб "Джаз"', 'Москва, ул. Пушкинская, 8', '2024-07-20 20:00:00', '2024-07-20 23:00:00', 'draft', FALSE, 150);

-- Типы билетов
INSERT INTO TicketTypes (event_id, name, description, price, quantity_available, sales_start_datetime, sales_end_datetime) VALUES
(1, 'Ранняя пташка', 'Билет по специальной цене', 1500.00, 1000, '2024-01-01 00:00:00', '2024-05-01 23:59:59'),
(1, 'Стандартный', 'Стандартный билет', 2000.00, 3000, '2024-05-02 00:00:00', '2024-07-14 23:59:59'),
(1, 'VIP', 'VIP зона с обслуживанием', 5000.00, 200, '2024-01-01 00:00:00', '2024-07-14 23:59:59'),
(2, 'Участник', 'Доступ к онлайн-воркшопу', 3000.00, 100, '2024-01-01 00:00:00', '2024-06-09 23:59:59'),
(3, 'Стандартный', 'Вход на выставку', 500.00, 1000, '2024-01-01 00:00:00', '2024-09-19 23:59:59');

-- Заказы
INSERT INTO Orders (user_id, event_id, order_total, status, attendee_first_name, attendee_last_name, attendee_email, created_at) VALUES
(4, 1, 3000.00, 'completed', 'Ольга', 'Кузнецова', 'olga.kuznetsova@email.com', '2023-04-15 10:30:00'),
(5, 1, 5000.00, 'completed', 'Дмитрий', 'Воробьев', 'dmitry.vorobev@email.com', '2024-04-16 14:20:00'),
(4, 2, 3000.00, 'completed', 'Ольга', 'Кузнецова', 'olga.kuznetsova@email.com', '2024-05-01 09:15:00'),
(3, 3, 500.00, 'completed', 'Алексей', 'Смирнов', 'alex.smirnov@email.com', '2024-06-05 16:45:00');

-- Элементы заказов
INSERT INTO OrderItems (order_id, ticket_type_id, quantity, unit_price, line_total) VALUES
(1, 1, 2, 1500.00, 3000.00),
(2, 3, 1, 5000.00, 5000.00),
(3, 4, 1, 3000.00, 3000.00),
(4, 5, 1, 500.00, 500.00);

-- Элементы Оплаты
INSERT INTO Payments (order_id, amount, payment_method, status) VALUES
(1, 1000, 'card', 'succeeded'),
(2, 3000, 'card', 'succeeded'),
(3, 4000, 'card', 'succeeded'),
(4, 5000, 'card', 'succeeded')
ON CONFLICT (order_id) DO NOTHING;