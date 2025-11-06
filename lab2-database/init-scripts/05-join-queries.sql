-- 1. Детальная информация о заказах с JOIN
SELECT 
    o.order_id,
    CONCAT(u.first_name, ' ', u.last_name) as customer_name,
    u.email as customer_email,
    e.title as event_name,
    c.name as category,
    o.order_total,
    o.status as order_status,
    o.created_at as order_date,
    p.status as payment_status,
    p.payment_method
FROM Orders o
INNER JOIN Users u ON o.user_id = u.user_id
INNER JOIN Events e ON o.event_id = e.event_id
INNER JOIN Categories c ON e.category_id = c.category_id
LEFT JOIN Payments p ON o.order_id = p.order_id
WHERE o.status = 'completed'
ORDER BY o.created_at DESC;

-- 2. Билеты с информацией о событиях и пользователях
SELECT 
    t.ticket_uuid,
    CONCAT(t.attendee_first_name, ' ', t.attendee_last_name) as attendee_name,
    t.attendee_email,
    e.title as event_name,
    tt.name as ticket_type,
    tt.price as ticket_price,
    e.start_datetime,
    e.venue_name,
    t.status as ticket_status,
    CONCAT(u.first_name, ' ', u.last_name) as purchased_by
FROM Tickets t
INNER JOIN Events e ON t.event_id = e.event_id
INNER JOIN TicketTypes tt ON t.ticket_type_id = tt.ticket_type_id
LEFT JOIN Users u ON t.user_id = u.user_id
WHERE t.status = 'active'
ORDER BY e.start_datetime;

-- 3. LEFT JOIN: Все организаторы и их мероприятия (даже если мероприятий нет)
SELECT 
    o.organizer_id,
    o.company_name,
    o.is_verified,
    COUNT(e.event_id) as events_count,
    COALESCE(SUM(ord.order_total), 0) as total_revenue
FROM Organizers o
LEFT JOIN Events e ON o.organizer_id = e.organizer_id AND e.status = 'published'
LEFT JOIN Orders ord ON e.event_id = ord.event_id AND ord.status = 'completed'
GROUP BY o.organizer_id, o.company_name, o.is_verified
ORDER BY total_revenue DESC;

-- 4. Мероприятия с количеством проданных билетов и выручкой
SELECT 
    e.event_id,
    e.title,
    e.start_datetime,
    c.name as category,
    org.company_name as organizer,
    COUNT(t.ticket_id) as tickets_sold,
    SUM(oi.line_total) as total_revenue,
    e.max_attendees,
    ROUND((COUNT(t.ticket_id) * 100.0 / e.max_attendees), 2) as occupancy_rate
FROM Events e
INNER JOIN Categories c ON e.category_id = c.category_id
INNER JOIN Organizers org ON e.organizer_id = org.organizer_id
LEFT JOIN Orders o ON e.event_id = o.event_id AND o.status = 'completed'
LEFT JOIN OrderItems oi ON o.order_id = oi.order_id
LEFT JOIN Tickets t ON oi.order_item_id = t.order_item_id
WHERE e.status = 'published'
GROUP BY e.event_id, e.title, e.start_datetime, c.name, org.company_name, e.max_attendees
ORDER BY total_revenue DESC;

-- 5. Пользователи с их покупками и предпочтениями по категориям
SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) as user_name,
    u.email,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT e.category_id) as categories_count,
    GROUP_CONCAT(DISTINCT c.name) as preferred_categories,
    SUM(o.order_total) as lifetime_value
FROM Users u
LEFT JOIN Orders o ON u.user_id = o.user_id AND o.status = 'completed'
LEFT JOIN Events e ON o.event_id = e.event_id
LEFT JOIN Categories c ON e.category_id = c.category_id
GROUP BY u.user_id, user_name, u.email
HAVING total_orders > 0
ORDER BY lifetime_value DESC;