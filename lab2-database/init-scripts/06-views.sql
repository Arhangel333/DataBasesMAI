-- 1. Представление "Топ-10 самых прибыльных мероприятий"
CREATE VIEW TopRevenueEvents AS
SELECT 
    e.event_id,
    e.title,
    c.name as category,
    org.company_name as organizer,
    e.start_datetime,
    COUNT(DISTINCT o.order_id) as orders_count,
    COUNT(t.ticket_id) as tickets_sold,
    SUM(o.order_total) as total_revenue,
    ROUND(SUM(o.order_total) / COUNT(t.ticket_id), 2) as revenue_per_ticket
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
CREATE VIEW RecentUserActivity AS
SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) as user_name,
    u.email,
    u.created_at as registration_date,
    COUNT(o.order_id) as recent_orders,
    SUM(o.order_total) as recent_spending,
    MAX(o.created_at) as last_order_date,
    GROUP_CONCAT(DISTINCT c.name) as recent_categories
FROM Users u
LEFT JOIN Orders o ON u.user_id = o.user_id 
    AND o.status = 'completed' 
    AND o.created_at >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
LEFT JOIN Events e ON o.event_id = e.event_id
LEFT JOIN Categories c ON e.category_id = c.category_id
GROUP BY u.user_id, user_name, u.email, u.created_at
HAVING recent_orders > 0
ORDER BY recent_spending DESC;

-- 3. Представление "Сводка по категориям мероприятий"
CREATE VIEW CategorySummary AS
SELECT 
    c.category_id,
    c.name as category_name,
    c.description,
    COUNT(e.event_id) as total_events,
    COUNT(CASE WHEN e.status = 'published' THEN 1 END) as active_events,
    COUNT(CASE WHEN e.start_datetime > NOW() THEN 1 END) as upcoming_events,
    SUM(tt.quantity_sold) as total_tickets_sold,
    COALESCE(SUM(o.order_total), 0) as total_revenue,
    ROUND(AVG(tt.price), 2) as avg_ticket_price,
    COUNT(DISTINCT e.organizer_id) as unique_organizers
FROM Categories c
LEFT JOIN Events e ON c.category_id = e.category_id
LEFT JOIN TicketTypes tt ON e.event_id = tt.event_id
LEFT JOIN Orders o ON e.event_id = o.event_id AND o.status = 'completed'
GROUP BY c.category_id, c.name, c.description
ORDER BY total_revenue DESC;

-- Примеры использования представлений
SELECT * FROM TopRevenueEvents;
SELECT * FROM RecentUserActivity;
SELECT * FROM CategorySummary;

-- Дополнительный запрос к представлениям с фильтрацией
SELECT * FROM CategorySummary WHERE total_revenue > 0;
SELECT * FROM RecentUserActivity WHERE recent_spending > 5000;