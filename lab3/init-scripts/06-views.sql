-- 6. Создание представлений

-- 1. Представление "Топ-10 самых прибыльных мероприятий"
CREATE OR REPLACE VIEW TopRevenueEvents AS
SELECT 
    e.event_id,
    e.title,
    c.name as category,
    org.company_name as organizer,
    e.start_datetime,
    COUNT(DISTINCT o.order_id) as orders_count,
    COUNT(t.ticket_id) as tickets_sold,
    COALESCE(SUM(o.order_total), 0) as total_revenue,
    CASE 
        WHEN COUNT(t.ticket_id) > 0 THEN ROUND(SUM(o.order_total) / COUNT(t.ticket_id), 2)
        ELSE 0 
    END as revenue_per_ticket
FROM Events e
INNER JOIN Categories c ON e.category_id = c.category_id
INNER JOIN Organizers org ON e.organizer_id = org.organizer_id
LEFT JOIN Orders o ON e.event_id = o.event_id AND o.status = 'completed'
LEFT JOIN OrderItems oi ON o.order_id = oi.order_id
LEFT JOIN Tickets t ON oi.order_item_id = t.order_item_id
WHERE e.status = 'published'
GROUP BY e.event_id, e.title, c.name, org.company_name, e.start_datetime
ORDER BY total_revenue DESC
LIMIT 10;

-- 2. Представление "Активность пользователей за последний месяц"
CREATE OR REPLACE VIEW RecentUserActivity AS
SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) as user_name,
    u.email,
    u.created_at as registration_date,
    COUNT(o.order_id) as recent_orders,
    COALESCE(SUM(o.order_total), 0) as recent_spending,
    MAX(o.created_at) as last_order_date,
    STRING_AGG(DISTINCT c.name, ', ') as recent_categories
FROM Users u
LEFT JOIN Orders o ON u.user_id = o.user_id 
    AND o.status = 'completed' 
    AND o.created_at >= (NOW() - INTERVAL '1 MONTH')
LEFT JOIN Events e ON o.event_id = e.event_id
LEFT JOIN Categories c ON e.category_id = c.category_id
GROUP BY u.user_id, user_name, u.email, u.created_at
HAVING COUNT(o.order_id) > 0
ORDER BY recent_spending DESC;

-- 3. Представление "Сводка по категориям мероприятий"
CREATE OR REPLACE VIEW CategorySummary AS
SELECT 
    c.category_id,
    c.name as category_name,
    c.description,
    COUNT(e.event_id) as total_events,
    COUNT(CASE WHEN e.status = 'published' THEN 1 END) as active_events,
    COUNT(CASE WHEN e.start_datetime > NOW() THEN 1 END) as upcoming_events,
    COALESCE(SUM(tt.quantity_sold), 0) as total_tickets_sold,
    COALESCE(SUM(o.order_total), 0) as total_revenue,
    CASE 
        WHEN COUNT(tt.ticket_type_id) > 0 THEN ROUND(AVG(tt.price), 2)
        ELSE 0 
    END as avg_ticket_price,
    COUNT(DISTINCT e.organizer_id) as unique_organizers
FROM Categories c
LEFT JOIN Events e ON c.category_id = e.category_id
LEFT JOIN TicketTypes tt ON e.event_id = tt.event_id
LEFT JOIN Orders o ON e.event_id = o.event_id AND o.status = 'completed'
GROUP BY c.category_id, c.name, c.description
ORDER BY total_revenue DESC;

CREATE OR REPLACE VIEW TopTENEvents AS
SELECT e.event_id, e.organizer_id, e.title, SUM(o.order_total) as total_revenue
FROM Events e
JOIN Orders o ON e.event_id = o.event_id
JOIN Payments p ON o.order_id = p.order_id
WHERE 
p.status = 'succeeded' AND
o.status = 'completed' AND 
e.status = 'completed'
GROUP BY  e.event_id, e.title
HAVING SUM(o.order_total) > 0
ORDER by SUM(o.order_total) DESC
LIMIT 10;

CREATE OR REPLACE VIEW Top10Events AS
SELECT e.event_id, e.organizer_id, e.title, SUM(o.order_total) as total_revenue
FROM Events e
JOIN Orders o ON e.event_id = o.event_id
JOIN Payments p ON o.order_id = p.order_id
WHERE 
p.status = 'succeeded' AND
o.status = 'completed' AND 
e.status = 'completed'
GROUP BY  e.event_id, e.title, e.organizer_id
HAVING SUM(o.order_total) > 0
ORDER by SUM(o.order_total) DESC
LIMIT 10;


-- Примеры использования представлений
SELECT * FROM TopRevenueEvents;
SELECT * FROM RecentUserActivity;
SELECT * FROM CategorySummary;
SELECT * FROM Top10Events;
SELECT * FROM TopTENEvents;

-- Дополнительный запрос к представлениям с фильтрацией
--SELECT * FROM CategorySummary WHERE total_revenue > 0;
--SELECT * FROM RecentUserActivity WHERE recent_spending > 5000;